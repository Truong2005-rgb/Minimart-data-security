# Rebuilding a separate demo environment

## Status

This is a setup recipe and templates based on the supplied SQL exports. It has not been tested on a fresh SQL Server instance here. Keep the original working demo unchanged. SQL exports contain CREATE/ALTER/GRANT and sample INSERT statements; they are not read-only inspection scripts.

Use a separate clean SQL Server instance where `MiniMart_DataWarehouse`, its named SQL logins, and `MiniMart_Audit` do not already exist. Do not run these installation files against the currently demonstrated database. For the original demo, continue using its original application folder and matching local MFA encryption keys; the GitHub bundle intentionally omits those keys.

## Review before installation

1. Copy editable setup templates to `sql/local/` (ignored by Git). Fill in NEW local passwords; never commit a filled-in copy.
2. Review the 13 SQL Login names used by the exported database users. No original passwords/hashes are supplied. Login creation template uses separate placeholders for each login and stops if the original database or conflicting logins already exist.
3. Edit a local copy of `MiniMart_schema.sql`: the exported MDF/LDF paths are tied to the source machine. Use appropriate paths for the separate instance, or use reviewed SQL Server default paths. Retain object ordering, role membership, permissions, and dependent objects.
4. Review the original Audit FILEPATH for the new SQL Server instance. The directory must exist and the SQL Server service identity must be able to write there. The supplied Audit GUID is part of the original configuration; review identity/name collisions in any environment before creation.
5. This schema retains Dynamic Data Masking definitions and legacy HR/account objects. The report's choice to present six mechanisms did not remove those definitions from the database. Do not delete them from the original database to match the report.

## Suggested installation sequence (new instance only)

| Stage | Files / action |
|---|---|
| 1 | Fill and review `00_Create_demo_logins.sql.example` locally, then create new demo logins on the separate instance. |
| 2 | Review and import `sql/exported/MiniMart_schema.sql`, including users, role memberships, column permissions, tables, RLS and procedure definitions. Resolve any setup errors before proceeding. |
| 3 | Fill and review `20_Create_new_encryption_keys.sql.example`, creating NEW master key/certificate/AES-256 key in the rebuilt database. |
| 4 | Review and import `MiniMart_sample_data.sql` ONCE, preserving identity values, foreign-key relationships and the 7 current branch mappings. |
| 5 | Review `30_Encrypt_new_sample_contacts.sql.example`, then encrypt the synthetic contacts using the new key. Old exported ciphertext cannot be decrypted by a different new key. This template checks the new-setup marker and existing sample count before updating ciphertext. |
| 6 | Review/create `MiniMart_Audit.sql`, followed by `MiniMart_DB_AuditSpec.sql`; server audit must exist before the database specification can be created. |
| 7 | Review/apply `40_Align_portal_audit_events.sql` on the rebuilt environment and test both old and added log event names. It changes the logging procedure, not the source database automatically. |
| 8 | Configure process environment variables, install dependencies, launch Flask, and enroll fresh TOTP identities. |
| 9 | Run demo checks under their specified identities and verify actual output, Audit records and portal behavior. |

Do not treat this sequence as verified until you have performed a clean installation and end-to-end tests. If a batch fails, stop and inspect the new instance. Several exported files contain multiple GO batches; executing a whole script in SSMS can continue with later batches after an earlier error. Do not use repeated execution as a repair strategy.

## Runtime requirements

- SQL Server supports the SQL Server 2022 schema features, certificate/symmetric-key encryption and RLS.
- A suitable ODBC driver and Python dependencies are installed on the web application machine.
- All SQL credentials are local demo credentials. `Portal_Service` needs the exported MFA/authentication permissions and EXECUTE on the portal log procedure; business queries use each authenticated user's own login.
- Portal Admin needs `PortalAdminRole`, a matching allowlist entry and the supplied `UserStoreAccess` mappings.
- Application session registry is single-process and in memory. Restarting Flask invalidates sessions.
- New runtime `data/fernet.key` and `data/flask.key` are created locally. Never add them to GitHub.

## Validation targets

- 3 stores, 200 customers, 50 products, 91 dates, 10,091 transactions.
- Revenue: 1,185,893,000 VND. Branch sales: 3,387 / 3,398 / 3,306 transactions.
- Current mapping grants Manager_ThanhHoa branches 1 AND 2, Manager_NgheAn branch 2, Manager_HaTinh branch 3, and Portal_Admin all three branches.
- Staff reads only the four permitted customer columns; unauthorized contact reads return the expected column-permission error.
- Portal Admin decrypts using its real SQL Login; Staff's EXECUTE is denied.
- TOTP, temporary lockout, CSRF, logout, 10-minute idle expiry and 8-hour maximum session behave as documented.
- Test added Audit event names for successful role transfer and branch grants/revokes, plus denied attempts.

The `.sql.example` files are new-environment templates, not copies of the original key material. They must be reviewed and configured; they have not been run here.
