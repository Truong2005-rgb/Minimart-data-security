"""Xử lý TOTP (mã 6 số đổi mỗi 30 giây) và mã hóa khóa bí mật trước khi lưu vào SQL Server."""
import hmac
import os
import time

import pyotp
from cryptography.fernet import Fernet

import config


def _key_path(name):
    os.makedirs(config.DATA_DIR, exist_ok=True)
    return os.path.join(config.DATA_DIR, name)


def _load_or_create(name, maker):
    path = _key_path(name)
    if not os.path.exists(path):
        with open(path, "wb") as f:
            f.write(maker())
        try:
            os.chmod(path, 0o600)
        except OSError:
            pass
    with open(path, "rb") as f:
        return f.read()


def fernet():
    return Fernet(_load_or_create("fernet.key", Fernet.generate_key))


def flask_secret():
    return _load_or_create("flask.key", lambda: os.urandom(32))


def new_secret():
    return pyotp.random_base32()


def encrypt_secret(secret):
    return fernet().encrypt(secret.encode()).decode()


def decrypt_secret(token):
    return fernet().decrypt(token.encode()).decode()


def provisioning_uri(username, secret):
    return pyotp.TOTP(secret, interval=config.TOTP_STEP).provisioning_uri(
        name=username, issuer_name=config.ISSUER
    )


def is_replay(secret, code, last_step):
    """True nếu code đúng là mã của bước thời gian đã dùng thành công gần nhất (bất kể đã qua bao lâu)."""
    code = (code or "").strip().replace(" ", "")
    if last_step <= 0 or len(code) != 6 or not code.isdigit():
        return False
    totp = pyotp.TOTP(secret, interval=config.TOTP_STEP)
    return hmac.compare_digest(totp.at(last_step * config.TOTP_STEP), code)


def verify(secret, code, last_step, now=None):
    """Trả về số bước thời gian nếu mã đúng và chưa dùng; ngược lại None.

    Chấp nhận lệch 1 bước (±30 giây). Mỗi bước chỉ được dùng một lần
    (last_step) để chống dùng lại mã đã nhìn thấy.
    """
    code = (code or "").strip().replace(" ", "")
    if len(code) != 6 or not code.isdigit():
        return None
    totp = pyotp.TOTP(secret, interval=config.TOTP_STEP)
    current = int((now if now is not None else time.time()) // config.TOTP_STEP)
    for step in (current - 1, current, current + 1):
        if step > last_step and hmac.compare_digest(totp.at(step * config.TOTP_STEP), code):
            return step
    return None
