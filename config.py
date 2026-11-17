"""Cấu hình cổng đăng nhập. Có thể đổi bằng biến môi trường (xem README)."""
import os

SQL_SERVER = os.environ.get("MM_SQL_SERVER", r"localhost\SQLEXPRESS")
SQL_DATABASE = os.environ.get("MM_SQL_DATABASE", "MiniMart_DataWarehouse")
SVC_USER = os.environ.get("MM_SVC_USER", "Portal_Service")
SVC_PASSWORD = os.environ.get("MM_SVC_PASSWORD", "")
ODBC_DRIVER = os.environ.get("MM_ODBC_DRIVER", "ODBC Driver 18 for SQL Server")

ISSUER = "MiniMart DW"          # tên hiện trong ứng dụng Authenticator
MAX_FAILS = 5                   # số lần sai liên tiếp trước khi khóa
LOCK_MINUTES = 5                # thời gian khóa
PENDING_TTL = 180               # giây: thời hạn giữa bước mật khẩu và bước mã 6 số
SESSION_IDLE = 600             # 10 phút không hoạt động (server-side)
SESSION_ABSOLUTE = 28800         # 8 giờ kể từ khi đăng nhập, không gia hạn
COOKIE_SECURE = os.environ.get("MM_COOKIE_SECURE", "0") == "1"  # =1 khi dùng HTTPS
TOTP_STEP = 30                  # giây cho mỗi mã
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

# Chỉ kích hoạt màn hình Admin khi SQL login thuộc db_owner *và* có trong allowlist.
# V1: màn Admin chỉ đọc/giới thiệu, chưa cho sửa quyền. Mặc định KHÔNG có admin web.
PORTAL_ADMIN_LOGINS = os.environ.get("MM_PORTAL_ADMIN_LOGINS", "")
