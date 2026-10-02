# Validation and reproducibility

## Checks performed for this package

- Checked relative Markdown/image links and code-fence pairing.
- Parsed all SVG files as XML, rendered them, and visually inspected the four diagrams.
- Parsed/compiled the supplied Python script to check syntax.
- Independently ran all 15 exercise queries against the same seeded relationships in SQLite, adapting only PostgreSQL date-literal/date-truncation syntax for that check. All expected result rows matched.
- Checked LEFT JOIN row counts (8), paid-preserving LEFT JOIN counts (6), and CROSS JOIN counts (25).
- Verified the ZIP contains only the original repository files; course screenshots and notes are excluded.

**Limit:** a PostgreSQL server and Psycopg connection were unavailable in the authoring environment. SQLite result checks do not prove PostgreSQL execution, numeric typing, stored functions/procedures, pgAdmin behavior, or backup/restore operations. The SQL was reviewed against PostgreSQL documentation; execute the checks below on your installed server. Python's live database connection has not been tested here.

## Validate locally

In an empty `sql_practice` database, execute `sql/00_schema.sql`, then `sql/01_seed.sql`. Then execute `tests/verify.sql`; pgAdmin should report `Baseline checks passed` in its messages. An exception means a check failed; confirm you are using the unchanged seed in the correct database.

Optional command-line equivalent from the repository root:

```bash
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f sql/00_schema.sql
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f sql/01_seed.sql
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f tests/verify.sql
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f sql/02_examples.sql
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f sql/03_modification_lab.sql
psql -h localhost -U postgres -d sql_practice -v ON_ERROR_STOP=1 -f sql/04_functions_and_views.sql
```

The modification lab finishes with ROLLBACK and should leave the seed rows unchanged. The object script intentionally adds a view, function, and procedure. Check them:

```sql
SELECT customer_paid_revenue(1); -- 57.50
SELECT COUNT(*) FROM paid_order_totals; -- 4
BEGIN;
CALL mark_customer_inactive(5);
SELECT active FROM customers WHERE customer_id = 5; -- FALSE
ROLLBACK;
```

If a load fails, address the first error before continuing. Reset only a disposable practice database with `sql/99_reset.sql`, then reload schema/seed. Do not run schema/seed again over existing data.
