"""Session lifecycle for the MiniMart single-process Flask demonstration.

Server-side registry only. Session IDs in Flask's signed cookie are opaque random
identifiers; passwords remain only in process RAM as required by the existing
user-specific SQL Server queries (RLS/CLS). Never run this module with multiple
WSGI worker processes: each worker has a separate registry.
"""
from __future__ import annotations

import secrets
import threading
import time

_LOCK = threading.RLock()


def create(registry, user: str, password: str, *, old_sid=None, now=None) -> str:
    """Rotate authenticated session ID, invalidating any previous ID."""
    if not user or not isinstance(user, str):
        raise ValueError("User must be a nonempty string")
    ts = time.monotonic() if now is None else now
    with _LOCK:
        if old_sid:
            registry.pop(old_sid, None)
        sid = secrets.token_urlsafe(32)
        while sid in registry:
            sid = secrets.token_urlsafe(32)
        registry[sid] = {"user": user, "password": password, "created": ts, "last": ts}
        return sid


def inspect(registry, sid, *, idle_seconds: int, absolute_seconds: int, now=None):
    """Return (session_record_or_none, status): ok/missing/idle/absolute.

    On expiry, deletes the registry entry *before* returning status. Last-activity
    is updated only after both limits are checked; absolute expiry never slides.
    """
    if not sid:
        return None, "missing"
    ts = time.monotonic() if now is None else now
    with _LOCK:
        record = registry.get(sid)
        if record is None:
            return None, "missing"
        if ts - record["created"] >= absolute_seconds:
            return registry.pop(sid), "absolute"
        if ts - record["last"] >= idle_seconds:
            return registry.pop(sid), "idle"
        record["last"] = ts
        return record.copy(), "ok"


def revoke(registry, sid):
    """Invalidate a session ID immediately, even if browser retains its cookie."""
    if not sid:
        return None
    with _LOCK:
        return registry.pop(sid, None)


def prune(registry, *, idle_seconds: int, absolute_seconds: int, now=None):
    """Remove abandoned sessions without granting them any extra lifetime."""
    ts = time.monotonic() if now is None else now
    with _LOCK:
        stale = [sid for sid, row in registry.items()
                 if ts - row["created"] >= absolute_seconds
                 or ts - row["last"] >= idle_seconds]
        for sid in stale:
            registry.pop(sid, None)
        return len(stale)
