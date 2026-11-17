# Known limitations

- Local single-process course demo, not a production security product.
- HTTP on localhost, `TrustServerCertificate=yes`, and Secure cookie disabled by default for that HTTP demo. Do not expose the unchanged demo configuration as an Internet service.
- User SQL passwords are retained in server-process memory to issue queries with the authenticated user's permissions. Sessions are invalidated by restart and are not shared across workers.
- Plaintext Phone and Email remain next to ciphertext. A 200/200 ciphertext count is not proof of complete encryption at rest or a complete security assessment.
- Data was reported as synthetic course data. Review all samples and screenshots before publication if any real information was introduced locally.
- Power BI was used in the course report, but no PBIX file was supplied in the web ZIP. The report's Power BI Import connection did not establish per-viewer RLS.
- RLS expectations must follow current mappings. The current export intentionally permits Thanh Hoa's manager to access Nghe An as well.
- SQL Audit specification covers two business tables; it does not record all changes across the database or account lifecycle.
- The original application log procedure did not accept four action names emitted by the current Flask routes. A separate additive correction is included for review/testing; it was not applied to the original demo.
- `Security.AccountLog.PerformedBy` defaults to execution-context identity; procedure execution as owner can prevent it from uniquely identifying the person using the web. This report limitation remains.
- Web role transfer is restricted to RBAC_Test_01, Staff/Auditor roles, and SQL-side guards. Broader account lifecycle procedures in the schema are not evidence that every lifecycle scenario has been validated.
- Source screenshots, report statements and configuration were collected at different stages. Current code uses 10-minute idle expiry; earlier documents mention 5 or 15 minutes.
- No load test, high-availability test, disaster-recovery exercise, production key-management assessment or independently verified penetration test is included.
- Exported database setup contains machine-specific paths and requires review. Fresh installation and the new SQL templates have not been executed here.
