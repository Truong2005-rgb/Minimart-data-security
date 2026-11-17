"""Cổng đăng nhập hai lớp cho MiniMart Data Warehouse.

Lớp 1: tên đăng nhập + mật khẩu SQL Server (kiểm tra bằng cách đăng nhập thật vào SQL Server).
Lớp 2: mã 6 số từ ứng dụng Authenticator (đăng ký lần đầu bằng cách quét mã QR).

Chạy:  python app.py   rồi mở http://127.0.0.1:5000
"""
import base64
from datetime import timedelta
import io
import math
import secrets
import time

import pyodbc
import qrcode
from flask import Flask, abort, redirect, render_template, request, session, url_for

import config
import db
import mfa
import session_lifecycle

app = Flask(__name__)
app.secret_key = mfa.flask_secret()
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
    SESSION_COOKIE_SECURE=config.COOKIE_SECURE,  # chỉ bật khi triển khai HTTPS
    PERMANENT_SESSION_LIFETIME=timedelta(seconds=config.SESSION_ABSOLUTE),
    SESSION_REFRESH_EACH_REQUEST=False,
)

# Trạng thái giữ trong bộ nhớ của tiến trình (mất khi tắt chương trình).
# Mật khẩu chỉ nằm ở đây, không nằm trong cookie và không ghi ra đĩa hay SQL Server.
PENDING = {}   # token -> {user, password, stage, expires}
SESSIONS = {}  # sid -> {user, password, created, last}; chỉ trong RAM


# ---------------------------------------------------------------- tiện ích
def ip():
    return request.remote_addr or "?"


def clean_username(raw):
    return (raw or "").strip()[:128]


def lock_minutes(username):
    _, until = db.get_attempt(username)
    if until and until > db.utcnow():
        return max(1, math.ceil((until - db.utcnow()).total_seconds() / 60))
    return 0


def register_failure(username):
    count, until = db.get_attempt(username)
    if until and until <= db.utcnow():
        count, until = 0, None          # hết thời gian khóa thì đếm lại từ đầu
    count += 1
    if count >= config.MAX_FAILS:
        until = db.utcnow().replace(microsecond=0) + timedelta(minutes=config.LOCK_MINUTES)
        db.log("LOCKED", username, ip(), f"Sai {count} lần liên tiếp")
    db.set_attempt(username, count, until)
    return config.MAX_FAILS - count


def clear_failures(username):
    db.set_attempt(username, 0, None)


def qr_data_uri(text):
    img = qrcode.make(text, box_size=7, border=2)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()


def start_session(user, password):
    # Chỉ gọi sau khi SQL password + OTP đã hợp lệ. Cấp SID mới mỗi lần MFA.
    session_lifecycle.prune(SESSIONS, idle_seconds=config.SESSION_IDLE,
                            absolute_seconds=config.SESSION_ABSOLUTE)
    sid = session_lifecycle.create(SESSIONS, user, password, old_sid=session.get("sid"))
    session.clear()  # xóa trạng thái trước xác thực; xoay cả CSRF token
    session.permanent = True
    session["sid"] = sid
    session["csrf"] = secrets.token_urlsafe(16)


def log_session_event(event, user):
    """Không để lỗi Audit giữ cho phiên đã hết hạn vẫn có quyền truy cập."""
    try:
        db.log(event, user, ip())
    except Exception as exc:
        app.logger.warning("Không ghi được sự kiện %s: %s", event, exc)


def prune_pending():
    """Dọn mật khẩu của các bước MFA bỏ dở khỏi bộ nhớ khi có request mới."""
    now = time.time()
    for token, pending in list(PENDING.items()):
        if pending["expires"] < now:
            PENDING.pop(token, None)


def current_pending(stage):
    token = session.get("pending")
    p = PENDING.get(token)
    if not p or p["expires"] < time.time() or p["stage"] != stage:
        PENDING.pop(token, None)
        session.pop("pending", None)
        return None
    return p


def render_login(message=None, status=400):
    return render_template("login.html", error=message), status


# ---------------------------------------------------------------- bảo vệ chung
@app.before_request
def csrf_check():
    prune_pending()
    if "csrf" not in session:
        session["csrf"] = secrets.token_urlsafe(16)
    if request.method == "POST":
        sent = request.form.get("csrf", "")
        if not secrets.compare_digest(sent, session.get("csrf", "")):
            abort(400)


@app.after_request
def headers(resp):
    resp.headers["X-Content-Type-Options"] = "nosniff"
    resp.headers["X-Frame-Options"] = "DENY"
    resp.headers["Cache-Control"] = "no-store"
    resp.headers["Content-Security-Policy"] = "default-src 'self'; img-src 'self' data:; style-src 'self'"
    return resp


@app.context_processor
def inject():
    return {"csrf": session.get("csrf", ""), "issuer": config.ISSUER, "max_fails": config.MAX_FAILS}


# ---------------------------------------------------------------- các trang
@app.route("/")
def index():
    return redirect(url_for("home" if session.get("sid") in SESSIONS else "login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        notices = {
            "idle": "Phiên đã hết hạn do không hoạt động. Vui lòng đăng nhập lại.",
            "absolute": "Phiên đã đạt giới hạn 8 giờ. Vui lòng xác thực lại.",
            "invalid": "Phiên không còn hợp lệ. Vui lòng đăng nhập lại.",
        }
        return render_template("login.html", error=None,
                               notice=notices.get(request.args.get("reason")))

    # Bắt đầu quy trình đăng nhập mới: không giữ một phiên đăng nhập cũ.
    session_lifecycle.revoke(SESSIONS, session.pop("sid", None))
    old_pending = session.pop("pending", None)
    PENDING.pop(old_pending, None)

    username = clean_username(request.form.get("username"))
    password = request.form.get("password", "")
    if not username or not password:
        return render_login("Vui lòng nhập tên đăng nhập và mật khẩu.")

    try:
        wait = lock_minutes(username)
        if wait:
            db.log("LOCKED_ATTEMPT", username, ip())
            return render_login(f"Đăng nhập tạm thời bị khóa do nhập sai nhiều lần. Thử lại sau khoảng {wait} phút.", 429)

        try:
            db.connect_user(username, password).close()
        except pyodbc.Error as e:
            sqlstate = e.args[0] if e.args else ""
            if sqlstate not in ("28000", "42000"):       # không phải lỗi sai tài khoản/mật khẩu
                app.logger.error("Lỗi kết nối SQL Server: %s", e)
                return render_login("Không kết nối được SQL Server. Kiểm tra cấu hình (xem README).", 503)
            register_failure(username)
            db.log("PASSWORD_FAIL", username, ip())
            # Cùng một thông báo cho "sai mật khẩu" và "tài khoản không tồn tại"
            return render_login("Sai tên đăng nhập hoặc mật khẩu.", 401)

        record = db.get_mfa(username)
        stage = "verify" if record and record["enrolled"] else "enroll"
        db.log("PASSWORD_OK", username, ip(), "Chuyển sang bước " + stage)
    except pyodbc.Error as e:
        app.logger.error("Lỗi cơ sở dữ liệu: %s", e)
        return render_login("Lỗi hệ thống khi truy cập cơ sở dữ liệu. Kiểm tra Portal_Service (xem README).", 500)

    token = secrets.token_urlsafe(24)
    PENDING[token] = {"user": username, "password": password, "stage": stage,
                      "expires": time.time() + config.PENDING_TTL}
    session["pending"] = token
    return redirect(url_for(stage))


@app.route("/enroll", methods=["GET", "POST"])
def enroll():
    p = current_pending("enroll")
    if not p:
        return redirect(url_for("login"))
    user = p["user"]
    record = db.get_mfa(user)
    if record is None:
        secret = mfa.new_secret()
        db.create_mfa(user, mfa.encrypt_secret(secret))
        db.log("ENROLL_START", user, ip())
    else:
        secret = mfa.decrypt_secret(record["secret_enc"])

    error = None
    if request.method == "POST":
        wait = lock_minutes(user)
        step = None if wait else mfa.verify(secret, request.form.get("code"), 0)
        if wait:
            error = f"Tạm khóa do nhập sai nhiều lần. Thử lại sau khoảng {wait} phút."
        elif step is None:
            left = register_failure(user)
            db.log("OTP_FAIL", user, ip(), "Bước đăng ký")
            error = f"Mã không đúng. Còn {max(left, 0)} lần thử." if left > 0 else "Nhập sai quá nhiều lần, tạm khóa."
        else:
            db.mark_enrolled(user, step)
            clear_failures(user)
            db.log("ENROLL_OK", user, ip())
            db.log("LOGIN_OK", user, ip(), "Đăng ký xong và đăng nhập")
            PENDING.pop(session.get("pending"), None)
            start_session(user, p["password"])
            return redirect(url_for("home"))

    uri = mfa.provisioning_uri(user, secret)
    grouped = " ".join(secret[i:i + 4] for i in range(0, len(secret), 4))
    return render_template("enroll.html", user=user, qr=qr_data_uri(uri), secret=grouped, error=error)


@app.route("/verify", methods=["GET", "POST"])
def verify():
    p = current_pending("verify")
    if not p:
        return redirect(url_for("login"))
    user = p["user"]
    error = None
    if request.method == "POST":
        wait = lock_minutes(user)
        if wait:
            error = f"Tạm khóa do nhập sai nhiều lần. Thử lại sau khoảng {wait} phút."
        else:
            record = db.get_mfa(user)
            secret = mfa.decrypt_secret(record["secret_enc"])
            code = request.form.get("code")
            step = mfa.verify(secret, code, record["last_step"])
            if step is None:
                # mã đúng nhưng đã dùng rồi: trùng mã của lần đăng nhập thành công gần nhất,
                # hoặc vẫn còn trong khoảng thời gian hợp lệ nhưng thuộc bước đã dùng
                replay = (mfa.is_replay(secret, code, record["last_step"])
                          or mfa.verify(secret, code, -1) is not None)
                left = register_failure(user)
                db.log("OTP_REPLAY" if replay else "OTP_FAIL", user, ip(), None)
                error = ("Mã này đã được dùng. Hãy chờ mã mới." if replay else "Mã không đúng.")
                error += f" Còn {max(left, 0)} lần thử." if left > 0 else " Tạm khóa."
            else:
                db.set_last_step(user, step)
                clear_failures(user)
                db.log("LOGIN_OK", user, ip())
                PENDING.pop(session.get("pending"), None)
                start_session(user, p["password"])
                return redirect(url_for("home"))
    return render_template("verify.html", user=user, error=error)


@app.route("/home")
def home():
    # URL tương thích với phiên bản cũ. Mọi kiểm tra SID và vai trò
    # nay nằm trong /portal và áp dụng cho tất cả các trang.
    return redirect(url_for("portal_index"))


@app.route("/logout", methods=["POST"])
def logout():
    s = session_lifecycle.revoke(SESSIONS, session.get("sid"))
    old_pending = session.pop("pending", None)
    PENDING.pop(old_pending, None)
    session.clear()
    if s:
        log_session_event("LOGOUT", s["user"])
    return redirect(url_for("login"))


# Đăng ký các trang mới sau khi khai báo xong routes MFA cũ.
import portal_routes
portal_routes.register(app, SESSIONS, session_lifecycle, log_session_event)


if __name__ == "__main__":
    # 127.0.0.1: chỉ máy này truy cập được. Không bật debug khi demo.
    app.run(host="127.0.0.1", port=5000, debug=False)
