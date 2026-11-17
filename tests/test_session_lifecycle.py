"""Pure-Python tests for Session Management, independent of SQL Server and Flask."""
import os
import sys
import unittest
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
import session_lifecycle as sl


class TestSessionLifecycle(unittest.TestCase):
    def setUp(self):
        self.reg = {}

    def test_new_random_id_and_revokes_old(self):
        a = sl.create(self.reg, 'alice', 'testpw', now=100)
        b = sl.create(self.reg, 'alice', 'testpw', old_sid=a, now=105)
        self.assertNotEqual(a, b)
        self.assertEqual(sl.inspect(self.reg, a, idle_seconds=900, absolute_seconds=28800, now=106)[1], 'missing')
        self.assertEqual(sl.inspect(self.reg, b, idle_seconds=900, absolute_seconds=28800, now=106)[1], 'ok')

    def test_idle_expiry_rejects_old_id(self):
        sid = sl.create(self.reg, 'alice', 'pw', now=0)
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=899)[1], 'ok')
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=1799)[1], 'idle')
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=1800)[1], 'missing')

    def test_idle_is_refreshed_by_activity(self):
        sid = sl.create(self.reg, 'alice', 'pw', now=10)
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=800)[1], 'ok')
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=1600)[1], 'ok')

    def test_absolute_expiry_even_if_recently_active(self):
        sid = sl.create(self.reg, 'alice', 'pw', now=100)
        self.reg[sid]['last'] = 28790  # phiên vẫn vừa hoạt động
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=28900)[1], 'absolute')
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=28901)[1], 'missing')

    def test_absolute_expiry_takes_priority(self):
        sid = sl.create(self.reg, 'alice', 'pw', now=0)
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=28800)[1], 'absolute')

    def test_revoke_twice(self):
        sid = sl.create(self.reg, 'alice', 'pw', now=0)
        self.assertIsNotNone(sl.revoke(self.reg, sid))
        self.assertIsNone(sl.revoke(self.reg, sid))
        self.assertEqual(sl.inspect(self.reg, sid, idle_seconds=900, absolute_seconds=28800, now=1)[1], 'missing')

    def test_prune_stale_sessions(self):
        a = sl.create(self.reg, 'alice', 'pw', now=0)
        b = sl.create(self.reg, 'bob', 'pw', now=1000)
        self.assertEqual(sl.prune(self.reg, idle_seconds=900, absolute_seconds=28800, now=1001), 1)
        self.assertNotIn(a, self.reg)
        self.assertIn(b, self.reg)

    def test_parallel_sessions_have_unique_ids(self):
        with ThreadPoolExecutor(max_workers=12) as pool:
            ids = list(pool.map(lambda i: sl.create(self.reg, f'u{i}', 'pw', now=0), range(200)))
        self.assertEqual(len(set(ids)), 200)
        self.assertEqual(len(self.reg), 200)


if __name__ == '__main__':
    unittest.main(verbosity=2)
