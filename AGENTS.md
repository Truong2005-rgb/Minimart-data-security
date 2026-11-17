# Instructions for coding agents

## Scope and project context

These instructions apply to this repository. Read `README.md`, `docs/SETUP.md`, and
`docs/KNOWN_LIMITATIONS.md` before changing database setup, authentication, or
authorization behavior.

This is a Python/Flask and SQL Server course demo of a Mini-Mart sales warehouse
and its security controls. Keep documentation grounded in the supplied code and
observed results; do not describe it as a production deployment or a verified
one-click installer.

## Repository map

- `app.py`: Flask application and authentication/session integration.
- `config.py`, `db.py`, `mfa.py`: runtime settings, SQL access, and TOTP support.
- `session_lifecycle.py`: SQL-independent in-memory session lifecycle helpers.
- `portal_routes.py`, `portal_data.py`: portal routes and business-data access.
- `templates/`, `static/`: Jinja pages, styles, and browser scripts.
- `sql/exported/`: supplied schema, sample data, and SQL Server Audit exports.
- `sql/setup-templates/`: separate-environment setup templates and log-event fix.
- `sql/demo/`: verification queries; inspect each script's prerequisites first.
- `tests/test_session_lifecycle.py`: existing pure-Python session tests.
- `config.env.example`: reference settings, not an automatically loaded file.

## Working conventions

- Make focused changes and follow the surrounding Python, SQL, and template style.
- Preserve Vietnamese interface text and SQL object names unless the task requires
  changing them. Update dependent queries and documentation together when needed.
- Keep SQL values parameterized. Do not interpolate user input into SQL strings.
- Business queries must continue to use the authenticated user's SQL identity.
  Do not replace them with a privileged service connection to bypass permissions.
- Preserve SQL-side RBAC/RLS/column permissions, live role checks, CSRF checks,
  TOTP replay/lockout controls, and session expiry when editing related code.
- Branch filters in the interface may narrow SQL-authorized access; they must not
  determine or expand authorization on their own.
- The role-transfer demo is restricted to `RBAC_Test_01` and Staff/Auditor roles.
- Current defaults are a 10-minute idle timeout and an 8-hour absolute timeout.
  Keep configuration, UI explanations, and documentation consistent if changed.
- Do not log SQL passwords, TOTP seeds/codes, Fernet keys, or session credentials.

## Local execution

Use Python 3.10+ and install dependencies in a virtual environment:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

The full portal also requires SQL Server, an appropriate Microsoft ODBC driver,
and configured process environment variables. Review `config.env.example` and
`docs/SETUP.md`; copying a file to `.env` does not configure this application.

On Windows, after configuring the separate SQL environment, launch with:

```powershell
.\CHAY_MINIMART_DEMO.bat
```

The launcher prompts for the local service password and performs startup checks.
Review its target server/database before use. The local login page is
`http://127.0.0.1:5000/login`.

## Database and secret handling

- Use read-only inspection for the existing working demo. Rebuild/setup work
  belongs on a separate clean instance following `docs/SETUP.md`.
- Do not execute the exported schema or sample INSERTs against the existing demo
  as a check: duplicate objects/data and permission changes can result.
- Keep supplied SQL exports as historical inputs. Prefer a separate reviewed
  migration/setup script for fixes rather than silently rewriting the baseline.
- Setup templates contain placeholders and have not been validated on a fresh
  instance here. Review file paths, identities, keys, and Audit dependencies.
- New encryption keys cannot decrypt ciphertext created by the original keys.
  Follow the documented new-environment sample re-encryption sequence.
- Never commit filled-in credentials, `data/`, runtime `.key` files, local SQL
  copies under `sql/local/`, database backups, or `.sqlaudit` files.
- Keep `.gitignore` protections in place. Example configuration must contain
  placeholders rather than real credentials or key material.

## Validation and accurate reporting

Run the existing SQL-independent tests when session behavior changes:

```powershell
python tests/test_session_lifecycle.py
```

For authentication, permissions, encryption, or auditing changes, relevant SQL
checks and portal flows also require a configured SQL Server environment. Verify
expected allow/deny behavior under the actual relevant identities. A connection
failure or missing-object error does not prove that an access-denial test passed.
If the environment is unavailable, report the untested behavior explicitly.

Keep these distinctions in documentation and assertions:

- Baseline sample: 10,091 transactions, 200 customers, 50 products, 3 stores,
  and 91 dates. These describe the bundled snapshot, not every future dataset.
- RLS follows current `Security.UserStoreAccess` mappings. The current export
  permits Thanh Hoa's manager branches 1 and 2; do not assume one branch per
  manager from an older screenshot.
- Contact ciphertext is supplied alongside plaintext Phone/Email. Non-NULL
  ciphertext counts alone do not prove successful decryption or full protection
  of data at rest.
- SQL Server Audit and application logs have different scopes. The separate
  `40_Align_portal_audit_events.sql` correction must not be assumed applied.
- The session test suite does not establish end-to-end portal or SQL security.
- No PBIX is supplied; do not claim per-viewer Power BI RLS has been validated.

In a change summary, state what changed, which checks actually ran, and any
remaining environment-dependent checks. Update setup notes for changed commands
or prerequisites; never invent successful runs or performance improvements.
