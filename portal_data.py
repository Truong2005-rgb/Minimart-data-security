"""Read-only business queries. Each call uses the *authenticated user's* SQL credential.

Never use Portal_Service, dbo, a shared admin login, or a server-side StoreKey
parameter for manager reports. RLS on Fact_Sales is the security boundary.
"""
import math
from datetime import date, datetime

import pyodbc
import db


def as_dicts(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_identity(username, password, admin_logins=()):
    with db.connect_user(username, password) as cn:
        row = cn.cursor().execute("""
            SELECT SUSER_SNAME(), USER_NAME(),
              IS_MEMBER('StoreManagerRole'), IS_MEMBER('CustomerStaffRole'),
              IS_MEMBER('AuditAdminRole'), IS_MEMBER('PortalServiceRole'),
              IS_MEMBER('db_owner'), IS_MEMBER('PortalAdminRole')
        """).fetchone()
        if row is None:
            raise ValueError('No identity returned')
        roles = set()
        for role, flag in zip(('manager', 'staff', 'auditor', 'service', 'db_owner', 'portal_admin'), row[2:]):
            if flag == 1:
                roles.add(role)
        # Both conditions are mandatory: SQL PortalAdminRole + explicit allowlist.
        # db_owner is deliberately NOT an Admin Portal substitute.
        is_admin = ('portal_admin' in roles and row[0].casefold() in
                    {x.casefold() for x in admin_logins})
        roles.discard('portal_admin')  # internal signal, not a route role
        if is_admin:
            roles.add('admin')
        if 'db_owner' in roles and not is_admin:
            # Do not accidentally treat dbo as a business user.
            roles.discard('db_owner')
        return {'login': row[0], 'db_user': row[1], 'roles': roles,
                'is_admin': is_admin, 'is_manager': 'manager' in roles,
                'is_staff': 'staff' in roles, 'is_auditor': 'auditor' in roles}


def summary(username, password, *, store_key=None):
    # Manager data remains protected by SQL Server RLS; StoreKey is an EXTRA filter.
    store_sql, store_params = _mm_safe_store_predicate(store_key)
    with db.connect_user(username, password) as cn:
        row = cn.cursor().execute("""
            SELECT COUNT(*) AS cnt,
                COALESCE(SUM(TotalAmount),0) AS revenue,
                COALESCE(SUM(Quantity),0) AS quantity,
                COUNT(DISTINCT ProductKey) AS products,
                COUNT(DISTINCT CustomerKey) AS customers
            FROM dbo.Fact_Sales
        """ + store_sql, *store_params).fetchone()
        return {'count': int(row[0]), 'revenue': int(row[1]),
                'quantity': int(row[2]), 'products': int(row[3]),
                'customers': int(row[4]),
                'avg': int(row[1] / row[0]) if row[0] else 0}

def day_series(username, password, limit=14, *, store_key=None):
    store_sql, store_params = _mm_safe_store_predicate(store_key)
    with db.connect_user(username, password) as cn:
        cursor = cn.cursor().execute("""
            SELECT TOP (?) DateKey, COUNT(*) AS Deals,
                COALESCE(SUM(TotalAmount),0) AS Revenue
            FROM dbo.Fact_Sales
        """ + store_sql + """
            GROUP BY DateKey ORDER BY DateKey DESC
        """, min(max(int(limit), 1), 91), *store_params)
        rows = as_dicts(cursor)
        rows.reverse()
        return [{'label': format_date_key(x['DateKey']),
                 'count': int(x['Deals']), 'revenue': int(x['Revenue'])} for x in rows]

def format_date_key(key):
    value = str(key)
    if len(value) == 8 and value.isdigit():
        return f'{value[6:8]}/{value[4:6]}/{value[:4]}'
    return value


def top_products(username, password, limit=8, *, store_key=None):
    store_sql, store_params = _mm_safe_store_predicate(store_key)
    with db.connect_user(username, password) as cn:
        cursor = cn.cursor().execute("""
            SELECT TOP (?) ProductKey, SUM(Quantity) AS Quantity,
                SUM(TotalAmount) AS Revenue, COUNT(*) AS Deals
            FROM dbo.Fact_Sales
        """ + store_sql + """
            GROUP BY ProductKey ORDER BY Revenue DESC, ProductKey
        """, min(max(int(limit), 1), 50), *store_params)
        rows = as_dicts(cursor)
        # No privileged fallback; dimension names are optional, per SQL permissions.
        ids = [int(r['ProductKey']) for r in rows]
        names = {}
        if ids:
            try:
                marks = ','.join(['?'] * len(ids))
                cur = cn.cursor().execute(
                    f'SELECT ProductKey, ProductName, Category FROM dbo.Dim_Product '
                    f'WHERE ProductKey IN ({marks})', *ids)
                names = {int(r[0]): (r[1], r[2]) for r in cur.fetchall()}
            except pyodbc.Error:
                pass
        return [{'key': int(x['ProductKey']),
                 'name': names.get(int(x['ProductKey']), (f'Sản phẩm #{x["ProductKey"]}', '—'))[0],
                 'category': names.get(int(x['ProductKey']), ('', '—'))[1],
                 'qty': int(x['Quantity']), 'revenue': int(x['Revenue']),
                 'count': int(x['Deals'])} for x in rows]

def transactions(username, password, *, page=1, date_start=None, date_end=None,
                 per_page=16, search=None, store_key=None):
    page = min(max(int(page), 1), 100000)
    per_page = min(max(int(per_page), 1), 30)
    store_sql, store_params = _mm_safe_store_predicate(store_key)
    conditions = ['StoreKey = ?'] if store_params else []
    params = list(store_params)
    if date_start is not None:
        conditions.append('DateKey >= ?')
        params.append(date_start)
    if date_end is not None:
        conditions.append('DateKey <= ?')
        params.append(date_end)
    if search and str(search).strip():
        term = str(search).strip()[:80]
        if term.upper().startswith('SP-'):
            conditions.append("CONVERT(NVARCHAR(30), ProductKey) LIKE ? ESCAPE N'~'")
            params.append(_mm_like(term[3:]))
        elif term.startswith('#'):
            conditions.append("CONVERT(NVARCHAR(30), SalesKey) LIKE ? ESCAPE N'~'")
            params.append(_mm_like(term[1:]))
        else:
            conditions.append("""(
                CONVERT(NVARCHAR(30), SalesKey) LIKE ? ESCAPE N'~'
                OR CONVERT(NVARCHAR(30), ProductKey) LIKE ? ESCAPE N'~'
                OR (CASE StoreKey WHEN 1 THEN N'Thanh Hóa'
                     WHEN 2 THEN N'Nghệ An' WHEN 3 THEN N'Hà Tĩnh'
                     ELSE N'' END) COLLATE Latin1_General_100_CI_AI
                   LIKE ? ESCAPE N'~'
            )""")
            params.extend((_mm_like(term), _mm_like(term), _mm_like(term)))
    where = (' WHERE ' + ' AND '.join(conditions)) if conditions else ''
    with db.connect_user(username, password) as cn:
        cnt = cn.cursor().execute('SELECT COUNT(*) FROM dbo.Fact_Sales' + where,
                                  *params).fetchone()[0]
        pages = max(1, math.ceil(cnt / per_page))
        page = min(page, pages)
        offset = (page - 1) * per_page
        cursor = cn.cursor().execute('''
            SELECT SalesKey, DateKey, StoreKey, ProductKey, Quantity, TotalAmount
            FROM dbo.Fact_Sales''' + where + '''
            ORDER BY DateKey DESC, SalesKey DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        ''', *(params + [offset, per_page]))
        rows = as_dicts(cursor)
        for x in rows:
            x['date_label'] = format_date_key(x['DateKey'])
            x['TotalAmount'] = int(x['TotalAmount'])
        return {'items': rows, 'count': int(cnt), 'page': page, 'pages': pages}

def store_scope(username, password):
    with db.connect_user(username, password) as cn:
        rows = cn.cursor().execute('SELECT DISTINCT StoreKey FROM dbo.Fact_Sales ORDER BY StoreKey').fetchall()
        return [int(x[0]) for x in rows]


def basic_customers(username, password, limit=25, *, include_contact=False):
    """Staff: original 4 CLS columns. Admin: SQL decrypts encrypted columns."""
    # MINIMART_ENC_ADMIN_DECRYPT_V1: no cleartext Phone/Email source for Admin.
    with db.connect_user(username, password) as cn:
        if include_contact:
            return as_dicts(cn.cursor().execute(
                'EXEC Security.usp_PortalGetDecryptedCustomers @MaxRows=?, @SearchPattern=?',
                min(max(int(limit), 1), 200), None))
        sql = """
            SELECT TOP (?) CustomerKey, CustomerID, CustomerName, Address
            FROM dbo.Dim_Customer ORDER BY CustomerKey
        """
        return as_dicts(cn.cursor().execute(sql, min(max(int(limit), 1), 200)))


def audit_rows(username, password, limit=30):
    with db.connect_user(username, password) as cn:
        cur = cn.cursor().execute('SELECT TOP (?) * FROM Security.AuditLog ORDER BY AuditID DESC',
                                  min(max(int(limit), 1), 50))
        result = as_dicts(cur)
        for r in result:
            for k, value in r.items():
                if isinstance(value, (datetime, date)):
                    r[k] = value.strftime('%d/%m/%Y %H:%M:%S')
                elif isinstance(value, bytes):
                    r[k] = '[dữ liệu nhị phân]'
                elif value is not None and not isinstance(value, (int, float, str)):
                    r[k] = str(value)
        return result


# MINIMART_SEARCH_V1: parameterized user-scope search. No shared admin connection.
import unicodedata

def _mm_like(value):
    """Escape LIKE metacharacters; user text remains a bound SQL parameter."""
    clean = str(value).strip()[:100]
    for special in ('~', '%', '_', '['):
        clean = clean.replace(special, '~' + special)
    return '%' + clean + '%'


def search_customers(username, password, query, limit=200, *, include_contact=False):
    """Staff uses original 4-column CLS query; Admin searches decrypted rows."""
    if not query or not str(query).strip():
        return basic_customers(username, password, limit, include_contact=include_contact)
    pattern = _mm_like(query)
    if include_contact:
        with db.connect_user(username, password) as cn:
            return as_dicts(cn.cursor().execute(
                'EXEC Security.usp_PortalGetDecryptedCustomers @MaxRows=?, @SearchPattern=?',
                min(max(int(limit), 1), 200), pattern))
    # Original Staff permissions and search semantics stay unchanged.
    cols = 'CustomerKey, CustomerID, CustomerName, Address'
    sql = f"""SELECT TOP (?) {cols} FROM dbo.Dim_Customer
        WHERE REPLACE(REPLACE(CustomerName, N'Đ', N'D'), N'đ', N'd')
              COLLATE Latin1_General_100_CI_AI LIKE ? ESCAPE N'~'
           OR CustomerID COLLATE Latin1_General_100_CI_AI LIKE ? ESCAPE N'~'
        ORDER BY CustomerKey"""
    with db.connect_user(username, password) as cn:
        return as_dicts(cn.cursor().execute(sql,
            min(max(int(limit), 1), 200), pattern, pattern))


def search_audit_rows(username, password, query, limit=100):
    """Audit search is read-only and runs as the actual signed-in SQL user."""
    if not query or not str(query).strip():
        return audit_rows(username, password)
    pattern = _mm_like(query)
    with db.connect_user(username, password) as cn:
        cursor = cn.cursor().execute("""
            SELECT TOP (?) * FROM Security.AuditLog
            WHERE DatabaseUser LIKE ? ESCAPE N'~'
               OR ActionName LIKE ? ESCAPE N'~'
               OR ActionStatus LIKE ? ESCAPE N'~'
               OR ObjectName LIKE ? ESCAPE N'~'
               OR Details LIKE ? ESCAPE N'~'
            ORDER BY AuditID DESC
        """, min(max(int(limit), 1), 100),
             pattern, pattern, pattern, pattern, pattern)
        rows = as_dicts(cursor)
        for r in rows:
            for key, value in r.items():
                if isinstance(value, (datetime, date)):
                    r[key] = value.strftime('%d/%m/%Y %H:%M:%S')
                elif isinstance(value, bytes):
                    r[key] = '[dữ liệu nhị phân]'
                elif value is not None and not isinstance(value, (int, float, str)):
                    r[key] = str(value)
        return rows

# MINIMART_AUDIT_FOCUS_AND_PAGING_V1
# Không giới hạn số bản ghi có thể xem; chỉ phân trang 50 bản ghi/lần tải.
# Luôn dùng SQL Login của chính tài khoản đã xác thực (Audit_Admin/Portal_Admin).
def audit_page(username, password, *, query='', page=1, per_page=50, scope='important'):
    if scope not in ('important', 'all'):
        raise ValueError('Invalid audit scope')
    page = max(1, int(page))
    per_page = max(1, int(per_page))
    conditions = []
    params = []
    if scope == 'important':
        # Bản ghi cũ vẫn còn nguyên trong SQL và xem được khi chọn Toàn bộ lịch sử.
        conditions.append("ActionName NOT IN (N'VIEW_DASHBOARD', N'VIEW_PRODUCTS', N'VIEW_ADMIN')")
    if query and str(query).strip():
        pattern = _mm_like(query)
        conditions.append("""(
            DatabaseUser LIKE ? ESCAPE N'~'
            OR ActionName LIKE ? ESCAPE N'~'
            OR ActionStatus LIKE ? ESCAPE N'~'
            OR ObjectName LIKE ? ESCAPE N'~'
            OR Details LIKE ? ESCAPE N'~'
        )""")
        params.extend([pattern] * 5)
    where = (' WHERE ' + ' AND '.join(conditions)) if conditions else ''
    with db.connect_user(username, password) as cn:
        count = int(cn.cursor().execute(
            'SELECT COUNT_BIG(*) FROM Security.AuditLog' + where, *params
        ).fetchone()[0])
        pages = max(1, math.ceil(count / per_page))
        page = min(page, pages)
        offset = (page - 1) * per_page
        sql = """
            SELECT AuditID, EventTime, DatabaseUser, ActionName,
                   ObjectName, ActionStatus, Details
            FROM Security.AuditLog
        """ + where + """
            ORDER BY AuditID DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        rows = as_dicts(cn.cursor().execute(sql, *(params + [offset, per_page])))
    for row in rows:
        for key, value in row.items():
            if isinstance(value, (datetime, date)):
                row[key] = value.strftime('%d/%m/%Y %H:%M:%S')
            elif isinstance(value, bytes):
                row[key] = '[dữ liệu nhị phân]'
            elif value is not None and not isinstance(value, (int, float, str)):
                row[key] = str(value)
    return {'rows': rows, 'count': count, 'page': page, 'pages': pages}

# MINIMART_ADMIN_BRANCH_FILTER_TOP10_TX50_V2
# SQL Server RLS applies to the *signed-in* Portal_Admin SQL login.
# No changes to the Manager queries and no elevated service reads.
def admin_branch_report(username, password, store_key=None, *,
                        date_start=None, date_end=None, rank_by='revenue',
                        page=1, search=''):
    if store_key is not None and store_key not in (1, 2, 3):
        raise ValueError('Chi nhánh không hợp lệ')
    if rank_by not in ('revenue', 'quantity'):
        raise ValueError('Tiêu chí xếp hạng không hợp lệ')
    if date_start is not None and date_end is not None and date_start > date_end:
        raise ValueError('Khoảng thời gian không hợp lệ')

    # All conditions are fixed server-side strings. Client values are bound parameters.
    period_conditions, period_params = [], []
    if date_start is not None:
        period_conditions.append('DateKey >= ?')
        period_params.append(date_start)
    if date_end is not None:
        period_conditions.append('DateKey <= ?')
        period_params.append(date_end)
    period_where = (' WHERE ' + ' AND '.join(period_conditions)) if period_conditions else ''

    selected_conditions, selected_params = list(period_conditions), list(period_params)
    if store_key is not None:
        selected_conditions.insert(0, 'StoreKey = ?')
        selected_params.insert(0, store_key)
    selected_where = (' WHERE ' + ' AND '.join(selected_conditions)) if selected_conditions else ''

    # Search applies ONLY to the transaction table, not the KPI and product ranking.
    transaction_conditions = list(selected_conditions)
    transaction_params = list(selected_params)
    term = str(search or '').strip()[:80]
    if term:
        if term.startswith('#') and term[1:].isdigit():
            transaction_conditions.append('SalesKey = ?')
            transaction_params.append(int(term[1:]))
        elif term.lower().startswith('sp-') and term[3:].isdigit():
            transaction_conditions.append('ProductKey = ?')
            transaction_params.append(int(term[3:]))
        elif term.isdigit():
            transaction_conditions.append('(SalesKey = ? OR ProductKey = ?)')
            transaction_params.extend((int(term), int(term)))
        else:
            transaction_conditions.append("""(
                CONVERT(NVARCHAR(30), SalesKey) LIKE ? ESCAPE N'~'
                OR CONVERT(NVARCHAR(30), ProductKey) LIKE ? ESCAPE N'~'
                OR (CASE StoreKey WHEN 1 THEN N'Thanh Hóa'
                     WHEN 2 THEN N'Nghệ An' WHEN 3 THEN N'Hà Tĩnh'
                     ELSE N'' END) COLLATE Latin1_General_100_CI_AI
                   LIKE ? ESCAPE N'~'
            )""")
            safe_pattern = _mm_like(term)
            transaction_params.extend((safe_pattern, safe_pattern, safe_pattern))
    transaction_where = (' WHERE ' + ' AND '.join(transaction_conditions)) if transaction_conditions else ''

    with db.connect_user(username, password) as cn:
        all_store_rows = cn.cursor().execute("""
            SELECT StoreKey, COUNT_BIG(*) AS Transactions,
                   COALESCE(SUM(TotalAmount),0) AS Revenue,
                   COALESCE(SUM(Quantity),0) AS Quantity,
                   COUNT(DISTINCT ProductKey) AS Products,
                   COUNT(DISTINCT CustomerKey) AS Customers
            FROM dbo.Fact_Sales""" + period_where + """
            GROUP BY StoreKey ORDER BY StoreKey
        """, *period_params).fetchall()
        stores = [{
            'key': int(x[0]), 'transactions': int(x[1]), 'revenue': int(x[2]),
            'quantity': int(x[3]), 'products': int(x[4]), 'customers': int(x[5])
        } for x in all_store_rows]
        if store_key is None:
            selected = {
                'transactions': sum(x['transactions'] for x in stores),
                'revenue': sum(x['revenue'] for x in stores),
                'quantity': sum(x['quantity'] for x in stores),
                'products': 0, 'customers': 0,
            }
            # Distinct counts must NOT be summed across branch rows.
            total_distinct = cn.cursor().execute("""
                SELECT COUNT(DISTINCT ProductKey), COUNT(DISTINCT CustomerKey)
                FROM dbo.Fact_Sales""" + period_where, *period_params).fetchone()
            selected['products'] = int(total_distinct[0])
            selected['customers'] = int(total_distinct[1])
        else:
            selected = next((dict(x) for x in stores if x['key'] == store_key),
                            {'transactions': 0, 'revenue': 0, 'quantity': 0,
                             'products': 0, 'customers': 0})

        # Rank is a strict server-side whitelist; never concatenate free-form SQL.
        sort_expression = ('Revenue DESC, Qty DESC' if rank_by == 'revenue'
                           else 'Qty DESC, Revenue DESC')
        product_rows = cn.cursor().execute("""
            SELECT TOP (10) ProductKey, SUM(Quantity) AS Qty,
                   COALESCE(SUM(TotalAmount),0) AS Revenue,
                   COUNT_BIG(*) AS Deals
            FROM dbo.Fact_Sales""" + selected_where + """
            GROUP BY ProductKey ORDER BY """ + sort_expression + ', ProductKey',
            *selected_params).fetchall()
        products = [{
            'key': int(x[0]), 'name': 'SP-' + str(x[0]),
            'qty': int(x[1]), 'revenue': int(x[2]), 'deals': int(x[3])
        } for x in product_rows]
        if products:
            try:
                marks = ','.join('?' for _ in products)
                names = cn.cursor().execute(
                    'SELECT ProductKey, ProductName FROM dbo.Dim_Product '
                    f'WHERE ProductKey IN ({marks})',
                    *(p['key'] for p in products)).fetchall()
                lookup = {int(x[0]): str(x[1]) for x in names}
                for p in products:
                    p['name'] = lookup.get(p['key'], p['name'])
            except pyodbc.Error:
                # No privileged fallback to bypass SQL permissions.
                pass

        total = int(cn.cursor().execute(
            'SELECT COUNT_BIG(*) FROM dbo.Fact_Sales' + transaction_where,
            *transaction_params).fetchone()[0])
        per_page = 50
        pages = max(1, (total + per_page - 1) // per_page)
        page = min(max(int(page), 1), pages)
        offset = (page - 1) * per_page
        sale_rows = cn.cursor().execute("""
            SELECT SalesKey, DateKey, StoreKey, ProductKey, Quantity, TotalAmount
            FROM dbo.Fact_Sales""" + transaction_where + """
            ORDER BY DateKey DESC, SalesKey DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """, *(transaction_params + [offset, per_page])).fetchall()
        sales = [{
            'key': int(x[0]), 'date': format_date_key(x[1]),
            'store_key': int(x[2]), 'product_key': int(x[3]),
            'quantity': int(x[4]), 'revenue': int(x[5])
        } for x in sale_rows]

    return {
        'stores': stores, 'summary': selected, 'products': products,
        'transactions': {'items': sales, 'count': total, 'page': page,
                         'pages': pages, 'per_page': per_page},
    }


# MINIMART_ADMIN_STORE_ACCESS_WEB_V1
# Truy van quyen qua STORED PROCEDURE voi SQL login Portal_Admin, khong dung Portal_Service.
def admin_manager_access(username, password):
    with db.connect_user(username, password) as cn:
        cur = cn.cursor().execute('EXEC Security.usp_GetManagerStoreAccess')
        rows = cur.fetchall()
    return [{
        'manager': str(x[0]), 'store_key': int(x[1]),
        'store_name': str(x[2]), 'allowed': bool(x[3]),
    } for x in rows]


def admin_set_manager_access(username, password, manager, store_key, action):
    # Chot danh sach tai tang Flask, nhung SQL Stored Procedure moi la bien bao mat.
    if manager not in ('Manager_ThanhHoa', 'Manager_NgheAn', 'Manager_HaTinh'):
        raise ValueError('Tai khoan Manager khong hop le')
    if store_key not in (1, 2, 3) or action not in ('GRANT', 'REVOKE'):
        raise ValueError('Phan cong chi nhanh khong hop le')
    with db.connect_user(username, password) as cn:
        row = cn.cursor().execute(
            'EXEC Security.usp_SetManagerStoreAccess @ManagerUsername=?, @StoreKey=?, @Action=?',
            manager, store_key, action,
        ).fetchone()
        if row is None:
            raise RuntimeError('SQL khong tra ket qua cap nhat phan quyen')
        result = {'manager': str(row[0]), 'store_key': int(row[1]),
                  'action': str(row[2]), 'changed': bool(row[3])}
        cn.commit()
        return result


# MINIMART_MANAGER_SCOPED_STORE_V1
# Validation and query parameter binding; never take SQL code from the client.
def _mm_safe_store_predicate(store_key):
    if store_key is None:
        return '', []
    if type(store_key) is not int or store_key not in (1, 2, 3):
        raise ValueError('Ma chi nhanh khong hop le')
    return ' WHERE StoreKey = ?', [store_key]


# MINIMART_RBAC_3_6_READONLY
def admin_business_role_assignments(username, password):
    """Read assignments via the existing SQL permission boundary, as the real SQL login."""
    with db.connect_user(username, password) as cn:
        cur = cn.cursor().execute('EXEC Security.usp_GetBusinessRoleAssignments')
        rows = cur.fetchall()
    return [{'username': str(row[0]), 'role': str(row[1])} for row in rows]


# MINIMART_RBAC_3_7_SAFE_TRANSFER
def admin_transfer_business_role(username, password, target_user, old_role, new_role):
    """DB stored procedure owns authorization and transactional AccountLog; no direct ALTER ROLE."""
    allowed = {'CustomerStaffRole', 'AuditAdminRole'}
    if old_role not in allowed or new_role not in allowed or old_role == new_role:
        raise ValueError('Vai trò chuyển đổi chưa được hỗ trợ hoặc không hợp lệ')
    if not isinstance(target_user, str) or not (1 <= len(target_user) <= 128):
        raise ValueError('Tài khoản không hợp lệ')
    if (target_user.strip() != target_user or not target_user.startswith('RBAC_Test_')
            or target_user in ('Portal_Admin', 'Portal_Service')):
        raise ValueError('Tài khoản không được phép chuyển')
    with db.connect_user(username, password) as cn:
        cn.cursor().execute(
            'EXEC Security.usp_PortalTransferBusinessRole '
            '@TargetUser=?, @ExpectedOldRole=?, @NewRole=?',
            target_user, old_role, new_role)
        cn.commit()
