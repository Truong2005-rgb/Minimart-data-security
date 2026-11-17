"""Secure role-specific portal pages for the existing MFA application.

V1 is read-only. Every route checks the authenticated server-side SID and live
SQL role membership; every business query uses that account's SQL credentials.
"""
from datetime import date
from functools import wraps
import math
import time

import pyodbc
from flask import abort, g, redirect, render_template, request, session, url_for

import config
import db
import portal_data as data


NAV = [
    {'id': 'dashboard', 'label': 'Tổng quan', 'icon': 'layout-dashboard', 'endpoint': 'portal_dashboard', 'roles': ('manager', 'admin')},
    {'id': 'transactions', 'label': 'Giao dịch', 'icon': 'receipt-text', 'endpoint': 'portal_transactions', 'roles': ('manager', 'admin')},
    {'id': 'revenue', 'label': 'Doanh thu', 'icon': 'chart-no-axes-combined', 'endpoint': 'portal_revenue', 'roles': ('manager', 'admin')},
    {'id': 'products', 'label': 'Sản phẩm', 'icon': 'package', 'endpoint': 'portal_products', 'roles': ('manager', 'admin')},
    {'id': 'customers', 'label': 'Khách hàng', 'icon': 'users', 'endpoint': 'portal_customers', 'roles': ('staff', 'admin')},
    {'id': 'audit', 'label': 'Nhật ký kiểm toán', 'icon': 'shield-check', 'endpoint': 'portal_audit', 'roles': ('auditor', 'admin')},
    {'id': 'admin', 'label': 'Quản trị', 'icon': 'settings-2', 'endpoint': 'portal_admin', 'roles': ('admin',)},
    {'id': 'profile', 'label': 'Tài khoản', 'icon': 'user-round', 'endpoint': 'portal_profile', 'roles': ('manager', 'staff', 'auditor', 'admin')},
]
STORE_LABELS = {1: 'Thanh Hóa', 2: 'Nghệ An', 3: 'Hà Tĩnh'}


def parse_date(raw):
    if not raw:
        return None
    try:
        return int(date.fromisoformat(raw).strftime('%Y%m%d'))
    except (ValueError, TypeError):
        abort(400, 'Ngày không hợp lệ. Vui lòng dùng YYYY-MM-DD.')


def register(app, registry, lifecycle, log_session_event):
    """Attach routes after app's legacy login/MFA routes have been defined."""
    # MINIMART_AUDIT_AUTO_EVENTS_V1
    # MINIMART_AUDIT_FOCUS_AND_PAGING_V1: ghi truy cập dữ liệu, nhật ký và từ chối quyền; bỏ log điều hướng.
    # Ghi nhật ký sau khi Flask đã tạo phản hồi. Không ghi mật khẩu, OTP, PII.
    # Không ghi nhật ký cho điều hướng Tổng quan thông thường.
    _audit_events = {
        'portal_transactions': ('VIEW_TRANSACTIONS', 'dbo.Fact_Sales', 'Xem danh sách giao dịch'),
        'portal_revenue': ('VIEW_REVENUE', 'dbo.Fact_Sales', 'Xem báo cáo doanh thu'),
        'portal_customers': ('VIEW_CUSTOMERS', 'dbo.Dim_Customer', 'Xem thông tin khách hàng'),
        'portal_audit': ('VIEW_AUDIT', 'Security.AuditLog', 'Xem nhật ký kiểm toán'),
    }

    @app.after_request
    def audit_portal_response(response):
        # Bỏ qua đăng nhập, tài nguyên tĩnh, POST, redirect và phiên chưa hợp lệ.
        if request.method != 'GET' or not request.path.startswith('/portal/'):
            return response
        person = getattr(g, 'portal_identity', None)
        if person is None:
            return response

        if response.status_code == 403:
            # Lấy đường dẫn, KHÔNG lấy query string hoặc giá trị người dùng nhập.
            action = 'ACCESS_DENIED'
            status = 'DENIED'
            object_name = (request.endpoint or 'portal')[:200]
            detail = 'Bị từ chối truy cập: ' + request.path[:180]
        else:
            info = _audit_events.get(request.endpoint)
            if info is None:
                return response
            action, object_name, detail = info
            if response.status_code == 200:
                status = 'SUCCESS'
            elif response.status_code == 503:
                status = 'FAILED'
                detail = 'Không thể tải dữ liệu: ' + request.path[:180]
            else:
                return response

        try:
            # Chỉ Portal_Service ghi qua SP; quyền dữ liệu vẫn dùng SQL login gốc.
            db.log_portal_action(
                username=person['login'], action=action,
                status=status, object_name=object_name, detail=detail)
        except Exception:
            # Không để sự cố dịch vụ log phá hỏng trang nghiệp vụ.
            app.logger.exception('Không thể ghi nhật ký: %s', action)
        return response

    @app.template_filter('vnd')
    def vnd(value):
        return f'{int(value or 0):,}'.replace(',', '.') + ' ₫'

    @app.template_filter('num')
    def num(value):
        return f'{int(value or 0):,}'.replace(',', '.')

    admin_logins = tuple(x.strip() for x in
                         getattr(config, 'PORTAL_ADMIN_LOGINS', '').split(',') if x.strip())

    def whoami():
        cached = getattr(g, 'portal_identity', None)
        if cached is not None:
            return cached
        sid = session.get('sid')
        s, reason = lifecycle.inspect(registry, sid,
                idle_seconds=config.SESSION_IDLE,
                absolute_seconds=config.SESSION_ABSOLUTE)
        if reason != 'ok':
            if sid or reason != 'missing':
                session.clear()
            if s and reason in ('idle', 'absolute'):
                evt = 'SESSION_IDLE_EXPIRED' if reason == 'idle' else 'SESSION_MAX_EXPIRED'
                log_session_event(evt, s['user'])
            return None
        try:
            identity = data.get_identity(s['user'], s['password'], admin_logins)
        except pyodbc.Error as ex:
            app.logger.warning('SQL session no longer valid: %s', ex)
            lifecycle.revoke(registry, sid)
            session.clear()
            log_session_event('SESSION_ACCESS_FAIL', s['user'])
            return None
        identity['password'] = s['password']
        identity['created'] = s['created']
        identity['remaining_absolute'] = max(0, math.ceil(
            config.SESSION_ABSOLUTE - (time.monotonic() - s['created'])))
        g.portal_identity = identity
        return identity

    def protected(*allowed_roles):
        def deco(func):
            @wraps(func)
            def wrapped(*args, **kwargs):
                person = whoami()
                if person is None:
                    return redirect(url_for('login', reason='invalid'))
                if not person['roles'].intersection(allowed_roles):
                    abort(403)
                return func(person, *args, **kwargs)
            return wrapped
        return deco

    def ctx(person, page, **kwargs):
        scope = None
        if person['is_manager'] or person['is_admin']:
            try:
                stores = data.store_scope(person['login'], person['password'])
                scope = ', '.join(STORE_LABELS.get(s, f'Chi nhánh #{s}') for s in stores) or 'Chưa có giao dịch'
            except pyodbc.Error:
                scope = 'Theo phân quyền SQL'
        menu = [x for x in NAV if set(x['roles']).intersection(person['roles'])]
        return dict(person=person, page=page, menu=menu,
                    user_scope=scope, store_labels=STORE_LABELS,
                    idle_seconds=config.SESSION_IDLE,
                    remaining_seconds=person['remaining_absolute'], **kwargs)

    # MINIMART_MANAGER_GLOBAL_SCOPE_V1
    def manager_store_selection(person):
        # SQL login cua Manager + RLS quyet dinh cac StoreKey duoc phep xem.
        # Lua chon tren Dashboard duoc giu trong Flask session va rang voi SID.
        # Query 'store' tren cac trang khac KHONG duoc thay doi lua chon chung.
        if person['is_admin'] or not person['is_manager']:
            return None, []
        authorized = sorted(set(int(s) for s in data.store_scope(
            person['login'], person['password']) if int(s) in STORE_LABELS))

        state = session.get('mm_manager_global_scope')
        current_sid = session.get('sid')
        if (not isinstance(state, dict) or state.get('login') != person['login']
                or state.get('sid') != current_sid):
            option = 'all'
        else:
            option = state.get('store', 'all')

        # Dashboard la noi DUY NHAT duoc doi chi nhanh trong giao dien Manager.
        if request.endpoint == 'portal_dashboard' and 'store' in request.args:
            requested = request.args['store']
            if requested != 'all' and requested not in ('1', '2', '3'):
                abort(400, 'Chi nhanh khong hop le.')
            if requested != 'all' and int(requested) not in authorized:
                abort(403, 'Khong duoc phep xem chi nhanh nay.')
            option = requested

        # Neu Admin da thu hoi chi nhanh thi tu dong ve pham vi con duoc cap.
        if option not in ('all', '1', '2', '3'):
            option = 'all'
        if option != 'all' and int(option) not in authorized:
            option = 'all'
        expected = {'login': person['login'], 'sid': current_sid, 'store': option}
        if session.get('mm_manager_global_scope') != expected:
            session['mm_manager_global_scope'] = expected
        return (int(option) if option != 'all' else None), authorized

    @app.route('/portal')
    @protected('manager','staff','auditor','admin')
    def portal_index(person):
        if person['is_admin'] or person['is_manager']:
            return redirect(url_for('portal_dashboard'))
        if person['is_staff']:
            return redirect(url_for('portal_customers'))
        return redirect(url_for('portal_audit'))

    @app.route('/portal/dashboard')
    @protected('manager', 'admin')
    def portal_dashboard(person):
        try:
            store_key, manager_stores = manager_store_selection(person)
            stats = data.summary(person['login'], person['password'], store_key=store_key)
            trend = data.day_series(person['login'], person['password'], 14, store_key=store_key)
            products = data.top_products(person['login'], person['password'], 5, store_key=store_key)
            latest = data.transactions(person['login'], person['password'], per_page=6, store_key=store_key)
        except pyodbc.Error as e:
            app.logger.warning('Portal read failed on dashboard: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'dashboard', error='Không đọc được dữ liệu theo quyền hiện tại.')), 503
        # Render first: a template error is not a successful page view.
        response = render_template('portal_dashboard.html',
                                   **ctx(person, 'dashboard', stats=stats,
                                         trend=trend, products=products, latest=latest['items'],
                                         selected_store=str(store_key) if store_key else 'all',
                                         manager_stores=manager_stores))
        return response

    @app.route('/portal/transactions')
    @protected('manager', 'admin')
    def portal_transactions(person):
        search_query = request.args.get('q', '').strip()[:80]
        start_raw = request.args.get('from', '')
        end_raw = request.args.get('to', '')
        start, end = parse_date(start_raw), parse_date(end_raw)
        if start is not None and end is not None and start > end:
            abort(400, 'Ngày bắt đầu không được sau ngày kết thúc.')
        try:
            page = min(max(int(request.args.get('page', '1')), 1), 10000)
        except ValueError:
            abort(400, 'Số trang không hợp lệ.')
        try:
            store_key, manager_stores = manager_store_selection(person)
            result = data.transactions(person['login'], person['password'], page=page,
                                       date_start=start, date_end=end, search=search_query,
                                       store_key=store_key)
        except pyodbc.Error as e:
            app.logger.warning('Portal transactions read denied: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'transactions', error='Không có quyền đọc giao dịch.')), 503
        return render_template('portal_transactions.html',
                               **ctx(person, 'transactions', result=result,
                                     start_raw=start_raw, end_raw=end_raw, search_query=search_query,
                                     selected_store=str(store_key) if store_key else 'all',
                                     manager_stores=manager_stores))

    @app.route('/portal/revenue')
    @protected('manager', 'admin')
    def portal_revenue(person):
        try:
            store_key, manager_stores = manager_store_selection(person)
            stats = data.summary(person['login'], person['password'], store_key=store_key)
            trend = data.day_series(person['login'], person['password'], 91, store_key=store_key)
            products = data.top_products(person['login'], person['password'], 10, store_key=store_key)
        except pyodbc.Error as e:
            app.logger.warning('Portal revenue read denied: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'revenue', error='Không có quyền đọc doanh thu.')), 503
        return render_template('portal_revenue.html',
                               **ctx(person, 'revenue', stats=stats, trend=trend, products=products,
                                     selected_store=str(store_key) if store_key else 'all',
                                     manager_stores=manager_stores))

    @app.route('/portal/products')
    @protected('manager', 'admin')
    def portal_products(person):
        try:
            store_key, manager_stores = manager_store_selection(person)
            products = data.top_products(person['login'], person['password'], 50, store_key=store_key)
        except pyodbc.Error as e:
            app.logger.warning('Portal products read denied: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'products', error='Không có quyền đọc số liệu sản phẩm.')), 503
        return render_template('portal_products.html', **ctx(person, 'products', products=products,
                                      selected_store=str(store_key) if store_key else 'all',
                                      manager_stores=manager_stores))

    @app.route('/portal/customers')
    @protected('staff', 'admin')
    def portal_customers(person):
        customer_search = request.args.get('q', '').strip()[:100]
        try:
            # Only server-verified Admin identities may request Phone/Email.
            # Staff continues to use the original four-column CLS query.
            customer_kwargs = {
    'include_contact': person['is_admin'],
    'limit': 200
}
            if customer_search:
                items = data.search_customers(
                    person['login'], person['password'], customer_search, **customer_kwargs)
            else:
                items = data.basic_customers(
                    person['login'], person['password'], **customer_kwargs)
        except pyodbc.Error as e:
            app.logger.warning('Portal customers read denied: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'customers', error='Không có quyền đọc các cột khách hàng.')), 503
        return render_template('portal_customers.html', **ctx(person, 'customers', items=items, search_query=customer_search))

    @app.route('/portal/audit')
    @protected('auditor', 'admin')
    def portal_audit(person):
        audit_query = request.args.get('q', '').strip()[:100]
        audit_scope = request.args.get('scope', 'important')
        if audit_scope not in ('important', 'all'):
            abort(400, 'Bộ lọc nhật ký không hợp lệ.')
        try:
            audit_page_num = max(1, int(request.args.get('page', '1')))
        except (TypeError, ValueError):
            abort(400, 'Số trang nhật ký không hợp lệ.')
        try:
            result = data.audit_page(
                person['login'], person['password'],
                query=audit_query, page=audit_page_num,
                per_page=50, scope=audit_scope)
        except pyodbc.Error as e:
            app.logger.warning('Portal audit read denied: %s', e)
            return render_template('portal_error.html',
                                   **ctx(person, 'audit', error='Không có quyền đọc Security.AuditLog.')), 503
        columns = ['AuditID', 'EventTime', 'DatabaseUser', 'ActionName',
                   'ObjectName', 'ActionStatus', 'Details']
        return render_template('portal_audit.html',
                               **ctx(person, 'audit', rows=result['rows'], columns=columns,
                                     search_query=audit_query, audit_scope=audit_scope,
                                     audit_total=result['count'], audit_page=result['page'],
                                     audit_pages=result['pages']))

    @app.route('/portal/profile')
    @protected('manager', 'staff', 'auditor', 'admin')
    def portal_profile(person):
        return render_template('portal_profile.html', **ctx(person, 'profile'))

    @app.route('/portal/admin')
    @protected('admin')
    def portal_admin(person):
        # MINIMART_ADMIN_BRANCH_FILTER_TOP10_TX50_V2
        # The Admin identity and its SQL credentials are verified server-side.
        store_option = request.args.get('store', 'all')
        allowed_stores = {'all': None, '1': 1, '2': 2, '3': 3}
        if store_option not in allowed_stores:
            abort(400, 'Chi nhánh không hợp lệ.')
        selected_store_key = allowed_stores[store_option]
        from_raw = request.args.get('from_date', '').strip()
        to_raw = request.args.get('to_date', '').strip()
        date_start, date_end = parse_date(from_raw), parse_date(to_raw)
        if date_start is not None and date_end is not None and date_start > date_end:
            abort(400, 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.')
        rank_by = request.args.get('sort', 'revenue')
        if rank_by not in ('revenue', 'quantity'):
            abort(400, 'Tiêu chí xếp hạng không hợp lệ.')
        search_query = request.args.get('q', '').strip()[:80]
        try:
            page = max(1, int(request.args.get('page', '1')))
        except (TypeError, ValueError):
            abort(400, 'Số trang không hợp lệ.')
        try:
            manager_access = data.admin_manager_access(person['login'], person['password'])
            branch = data.admin_branch_report(
                person['login'], person['password'], selected_store_key,
                date_start=date_start, date_end=date_end, rank_by=rank_by,
                page=page, search=search_query)
        except pyodbc.Error as e:
            app.logger.warning('Admin branch report denied: %s', e)
            return render_template('portal_error.html',
                **ctx(person, 'admin', error='Không có quyền đọc dữ liệu chi nhánh.')), 503
        # RBAC read is independent: an unavailable procedure must not take down reports.
        role_assignments = None
        try:
            role_assignments = data.admin_business_role_assignments(
                person['login'], person['password'])
        except (pyodbc.Error, RuntimeError) as exc:
            app.logger.warning('Admin RBAC list unavailable: %s', exc)
        response = render_template('portal_admin.html', **ctx(
            person, 'admin', role_assignments=role_assignments,
            branch=branch, selected_store=store_option,
            from_date=from_raw, to_date=to_raw, rank_by=rank_by,
            search_query=search_query, manager_access=manager_access,
            access_status=request.args.get('access_status', ''),
            role_transfer_status=session.pop('mm_role_transfer_notice', '')))
        # Keep the existing business-view audit behavior. Never log passwords or PII.
        try:
            db.log_portal_action(
                username=person['login'], action='VIEW_REVENUE',
                status='SUCCESS', object_name='dbo.Fact_Sales',
                detail='Admin xem doanh thu: ' + (
                    STORE_LABELS[selected_store_key] if selected_store_key is not None
                    else 'Toàn hệ thống'))
        except Exception:
            app.logger.exception('Không thể ghi AuditLog khi Admin xem chi nhánh')
        return response


    # MINIMART_ADMIN_STORE_ACCESS_WEB_V1
    # Tien xu ly CSRF cho POST da duoc app.py ap dung tren TOAN bo POST request.
    @app.route('/portal/admin/access', methods=['POST'])
    @protected('admin')
    def portal_admin_access(person):
        manager = request.form.get('manager', '')
        action = request.form.get('action', '')
        store_raw = request.form.get('store', '')
        if (manager not in ('Manager_ThanhHoa', 'Manager_NgheAn', 'Manager_HaTinh')
                or action not in ('GRANT', 'REVOKE')
                or store_raw not in ('1', '2', '3')
                or request.form.get('confirm') != 'yes'):
            abort(400, 'Yeu cau thay doi quyen khong hop le.')
        store_key = int(store_raw)

        try:
            result = data.admin_set_manager_access(
                person['login'], person['password'], manager, store_key, action)
        except (pyodbc.Error, RuntimeError) as exc:
            app.logger.warning('SQL denied store access change: %s', exc)
            try:
                db.log_portal_action(
                    username=person['login'], action='STORE_ACCESS_FAILED',
                    status='FAILED', object_name='Security.UserStoreAccess',
                    detail='That bai khi thao tac phan cong Manager')
            except Exception:
                app.logger.exception('Khong ghi duoc AuditLog thay doi phan cong that bai')
            return render_template('portal_error.html',
                **ctx(person, 'admin', error='SQL Server khong the cap nhat phan cong. Kiem tra vai tro va thu tuc SQL.')), 503

        # Security.StoreAccessChangeLog da duoc ghi dong bo trong cung SQL transaction.
        # AuditLog nghiep vu la ban ghi bo sung, khong thay the lich su SQL.
        try:
            db.log_portal_action(
                username=person['login'],
                action='STORE_ACCESS_GRANT' if action == 'GRANT' else 'STORE_ACCESS_REVOKE',
                status='SUCCESS', object_name='Security.UserStoreAccess',
                detail=('Manager=' + manager + '; StoreKey=' + store_raw +
                        '; Changed=' + str(int(result['changed']))))
        except Exception:
            app.logger.exception('SQL cap nhat thanh cong nhung khong ghi duoc AuditLog nghiep vu')

        return redirect(url_for('portal_admin',
            access_status='changed' if result['changed'] else 'unchanged'), code=303)

    # MINIMART_RBAC_3_7_SAFE_TRANSFER
    # SQL stored procedure applies the final permission check and writes AccountLog.
    @app.route('/portal/admin/role-transfer', methods=['POST'])
    @protected('admin')
    def portal_admin_role_transfer(person):
        target_user = request.form.get('target_user', '')
        old_role = request.form.get('old_role', '')
        new_role = request.form.get('new_role', '')
        if (request.form.get('confirm') != 'yes' or
                old_role not in ('CustomerStaffRole', 'AuditAdminRole') or
                new_role not in ('CustomerStaffRole', 'AuditAdminRole') or
                old_role == new_role or not target_user or len(target_user) > 128
                or not target_user.startswith('RBAC_Test_')):
            abort(400, 'Yêu cầu chuyển vai trò không hợp lệ.')
        try:
            # Prevent acting on stale forms, even before SQL procedure rechecks.
            assignments = data.admin_business_role_assignments(person['login'], person['password'])
            matches = [r for r in assignments if r['username'] == target_user]
            if len(matches) != 1 or matches[0]['role'] != old_role:
                abort(409, 'Vai trò tài khoản đã thay đổi. Vui lòng tải lại trang.')
            data.admin_transfer_business_role(person['login'], person['password'],
                                              target_user, old_role, new_role)
        except (pyodbc.Error, RuntimeError, ValueError) as exc:
            app.logger.warning('RBAC transfer rejected: %s', exc)
            try:
                db.log_portal_action(
                    username=person['login'], action='RBAC_ROLE_TRANSFER',
                    status='FAILED', object_name='Security.usp_PortalTransferBusinessRole',
                    detail='Target=' + target_user[:128] + '; From=' + old_role + '; To=' + new_role)
            except Exception:
                app.logger.exception('Cannot log failed RBAC transfer')
            # AccountLog is written inside SQL transaction only on success.
            return render_template('portal_error.html', **ctx(
                person, 'admin', error='Không thể chuyển vai trò. Quyền hoặc điều kiện an toàn chưa đáp ứng.')), 503
        try:
            db.log_portal_action(
                username=person['login'], action='RBAC_ROLE_TRANSFER',
                status='SUCCESS', object_name='Security.usp_PortalTransferBusinessRole',
                detail='Target=' + target_user + '; From=' + old_role + '; To=' + new_role)
        except Exception:
            app.logger.exception('RBAC changed but supplemental AuditLog failed; AccountLog remains authoritative')
        session['mm_role_transfer_notice'] = 'changed'
        return redirect(url_for('portal_admin'), code=303)

    @app.errorhandler(403)
    def forbidden(error):
        person = getattr(g, 'portal_identity', None)
        if person:
            return render_template('portal_forbidden.html', **ctx(person, '', reason=str(error))), 403
        return render_template('portal_forbidden.html', person=None, menu=[], page='', reason=str(error)), 403

 
# MINIMART_SEARCH_V1: role-specific search routes use parameterized queries.
