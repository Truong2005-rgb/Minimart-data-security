"""Truy cập SQL Server.

- connect_user(): Kết nối bằng tài khoản người dùng để áp dụng RBAC, RLS, CLS.
- svc(): Kết nối bằng Portal_Service cho MFA, AuthLog
         và gọi Stored Procedure ghi AuditLog.
"""

from datetime import datetime, timezone

import pyodbc

import config


def _esc(value):
    return "{" + value.replace("}", "}}") + "}"


def _conn_str(user, password):
    return (
        f"DRIVER={{{config.ODBC_DRIVER}}};SERVER={config.SQL_SERVER};DATABASE={config.SQL_DATABASE};"
        f"UID={_esc(user)};PWD={_esc(password)};Encrypt=yes;TrustServerCertificate=yes;Connection Timeout=5"
    )


def utcnow():
    return datetime.now(timezone.utc).replace(tzinfo=None)


def connect_user(username, password):
    """Trả về kết nối nếu đăng nhập SQL đúng, ngược lại ném pyodbc.Error."""
    return pyodbc.connect(_conn_str(username, password), timeout=5)


def svc():
    return pyodbc.connect(_conn_str(config.SVC_USER, config.SVC_PASSWORD), timeout=5)


# ---------- khóa tạm do nhập sai ----------
def get_attempt(username):
    with svc() as c:
        row = c.cursor().execute(
            "SELECT FailedCount, LockedUntilUtc FROM Security.LoginAttempt WHERE UserName = ?", username
        ).fetchone()
    return (row[0], row[1]) if row else (0, None)


def set_attempt(username, count, locked_until):
    with svc() as c:
        c.cursor().execute(
            """MERGE Security.LoginAttempt AS t USING (SELECT ? AS UserName) AS s ON t.UserName = s.UserName
               WHEN MATCHED THEN UPDATE SET FailedCount = ?, LockedUntilUtc = ?, LastFailUtc = SYSUTCDATETIME()
               WHEN NOT MATCHED THEN INSERT (UserName, FailedCount, LockedUntilUtc, LastFailUtc)
                    VALUES (s.UserName, ?, ?, SYSUTCDATETIME());""",
            username, count, locked_until, count, locked_until,
        )
        c.commit()


# ---------- MFA ----------
def get_mfa(username):
    """Trả về dict(secret_enc, enrolled, last_step) hoặc None."""
    with svc() as c:
        row = c.cursor().execute(
            "SELECT TotpSecretEnc, IsEnrolled, LastUsedStep FROM Security.UserMFA WHERE UserName = ?", username
        ).fetchone()
    return {"secret_enc": row[0], "enrolled": bool(row[1]), "last_step": int(row[2])} if row else None


def create_mfa(username, secret_enc):
    with svc() as c:
        c.cursor().execute(
            "INSERT INTO Security.UserMFA (UserName, TotpSecretEnc) VALUES (?, ?)", username, secret_enc
        )
        c.commit()


def mark_enrolled(username, step):
    with svc() as c:
        c.cursor().execute(
            "UPDATE Security.UserMFA SET IsEnrolled = 1, EnrolledAtUtc = SYSUTCDATETIME(), LastUsedStep = ? "
            "WHERE UserName = ?", step, username,
        )
        c.commit()


def set_last_step(username, step):
    with svc() as c:
        c.cursor().execute("UPDATE Security.UserMFA SET LastUsedStep = ? WHERE UserName = ?", step, username)
        c.commit()


# ---------- nhật ký ----------
def log(event, username, ip, detail=None):
    with svc() as c:
        c.cursor().execute(
            "INSERT INTO Security.AuthLog (UserName, EventType, ClientIp, Detail) VALUES (?, ?, ?, ?)",
            username, event, ip, detail,
        )
        c.commit()


# ---------- trang chủ sau khi đăng nhập: chạy bằng chính tài khoản người dùng ----------
def user_summary(username, password):
    """Cho thấy RLS/RBAC áp dụng thật: truy vấn Fact_Sales bằng đúng tài khoản đăng nhập."""
    info = {"login": None, "dbuser": None, "roles": [], "sales": None, "sales_error": None}
    with connect_user(username, password) as c:
        cur = c.cursor()
        row = cur.execute(
            "SELECT SUSER_SNAME(), USER_NAME(), IS_MEMBER('StoreManagerRole'), "
            "IS_MEMBER('CustomerStaffRole'), IS_MEMBER('AuditAdminRole')"
        ).fetchone()
        info["login"], info["dbuser"] = row[0], row[1]
        for name, flag in zip(("StoreManagerRole", "CustomerStaffRole", "AuditAdminRole"), row[2:]):
            if flag == 1:
                info["roles"].append(name)
        try:
            r = cur.execute("SELECT COUNT(*), ISNULL(SUM(TotalAmount), 0) FROM dbo.Fact_Sales").fetchone()
            info["sales"] = {"count": int(r[0]), "total": int(r[1])}
        except pyodbc.Error as e:
            info["sales_error"] = str(e.args[-1])[:300] if e.args else "Bị từ chối"
    return info


# ---------- ghi nhat ky hoat dong Portal ----------
def log_portal_action(username, action, status='SUCCESS',
                      object_name=None, detail=None):
    """
    Ghi AuditLog qua Stored Procedure.
    Chi su dung tai khoan dich vu Portal_Service.
    """
    with svc() as c:
        c.cursor().execute(
            """
            EXEC dbo.usp_MiniMartPortalWriteAudit
                @DatabaseUser = ?,
                @ActionName = ?,
                @ActionStatus = ?,
                @ObjectName = ?,
                @Details = ?
            """,
            username,
            action,
            status,
            object_name,
            detail
        )
        c.commit()
