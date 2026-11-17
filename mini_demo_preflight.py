"""MiniMart demo startup checks: read-only, no password logging."""
from pathlib import Path
import ast
import os
import sys


def fail(message, exit_code=1):
    print("KHONG DAT - " + message)
    raise SystemExit(exit_code)


root = Path(__file__).resolve().parent

# Validate expected project structure and syntax without importing Flask application.
required = (
    "app.py", "config.py", "db.py", "portal_data.py", "portal_routes.py",
    "templates/login.html", "templates/portal_admin.html",
    "static/session_timeout.js", "static/minimart_search.js",
)
missing = [name for name in required if not (root / name).is_file()]
if missing:
    fail("Thieu file du an: " + ", ".join(missing))

try:
    import flask  # noqa: F401
    import jinja2
    import pyodbc
except ImportError as exc:
    fail("Thieu thu vien trong .venv: " + (exc.name or "khong xac dinh"))

try:
    for filename in ("app.py", "portal_data.py", "portal_routes.py"):
        ast.parse((root / filename).read_text(encoding="utf-8-sig"), filename=filename)
    env = jinja2.Environment()
    for filename in ("templates/login.html", "templates/portal_admin.html"):
        env.parse((root / filename).read_text(encoding="utf-8-sig"))
except (SyntaxError, jinja2.TemplateSyntaxError, UnicodeError) as exc:
    fail("Cu phap Python/Jinja2: " + str(exc))
print("DAT - Python va Jinja2 hop le")

try:
    import config
    import db
except Exception as exc:
    fail("Khong nap duoc config.py / db.py: " + type(exc).__name__)

if not config.SVC_PASSWORD or not str(config.SVC_PASSWORD).strip():
    fail("MM_SVC_PASSWORD chua duoc nap vao tien trinh")

admin_logins = [x.strip() for x in getattr(config, "PORTAL_ADMIN_LOGINS", "").split(",")]
if "Portal_Admin" not in admin_logins:
    fail("MM_PORTAL_ADMIN_LOGINS chua co Portal_Admin")
if config.COOKIE_SECURE:
    fail("MM_COOKIE_SECURE=1 khong phu hop localhost HTTP (chi dung 0 voi demo HTTP)")
if config.ODBC_DRIVER not in pyodbc.drivers():
    fail("Chua co ODBC Driver: " + config.ODBC_DRIVER)

print("DAT - Moi truong Python .venv, ODBC va cau hinh demo")
print("SQL server:", config.SQL_SERVER)
print("Database:", config.SQL_DATABASE)
print("Service login:", config.SVC_USER)
print("Session idle:", config.SESSION_IDLE, "giay")

# One connection attempt only, avoids repeated password failures/lockouts.
# Queries are read-only and check the tables actually used by login/MFA.
cn = None
try:
    cn = db.svc()
    cur = cn.cursor()
    cur.execute("SELECT DB_NAME()").fetchone()
    cur.execute("SELECT TOP (0) FailedCount, LockedUntilUtc FROM Security.LoginAttempt").fetchall()
    cur.execute("SELECT TOP (0) TotpSecretEnc, IsEnrolled, LastUsedStep FROM Security.UserMFA").fetchall()
except pyodbc.Error as exc:
    state = str(exc.args[0]) if exc.args else "UNKNOWN"
    fail("Portal_Service/ODBC/SQL/MFA khong san sang (SQLSTATE " + state + ")", 2)
except Exception as exc:
    fail("Loi kiem tra SQL: " + type(exc).__name__, 2)
finally:
    if cn is not None:
        try:
            cn.close()
        except Exception:
            pass
print("DAT - Portal_Service ket noi SQL va doc bang phuc vu MFA")
print("TAT CA KIEM TRA TU DONG DA DAT. Chua thu dang nhap, OTP va cac trang sau MFA.")
