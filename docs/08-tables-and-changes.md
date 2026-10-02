# 08 · Creating tables, constraints, and changing data

[Home](../README.md) · [Next: conditional expressions](09-conditional-and-views.md)

DDL defines database objects; DML changes rows. Use `sql/03_modification_lab.sql` for runnable practice that rolls back row/table changes.

## CREATE DATABASE versus CREATE TABLE

```sql
CREATE DATABASE sql_practice;
```

Run that alone while connected to `postgres`, outside a transaction; then connect to the new database. You do not need to run it if you created the database in pgAdmin.

```sql
CREATE TABLE study_topics (
 topic_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 title text UNIQUE NOT NULL,
 priority integer NOT NULL DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
 reviewed_on date
);
```

Run this optional example once in the practice database. If a previous attempt created it, use a fresh table name or deliberately remove that practice table first.

## Constraint definitions

| Rule | What it enforces | Important distinction |
| --- | --- | --- |
| PRIMARY KEY | Unique, non-null identity | One PK constraint, possibly multiple columns |
| FOREIGN KEY / REFERENCES | Referenced key exists | Does not automatically require non-null input |
| UNIQUE | No duplicate non-null key values by default | PostgreSQL usually permits multiple NULLs |
| NOT NULL | Present value required | Does not reject empty text |
| CHECK | Boolean rule must not be FALSE | NULL/UNKNOWN passes; add NOT NULL if needed |
| DEFAULT | Value when input omits a column | Not a validation constraint; explicit NULL is not replaced |

`GENERATED ALWAYS AS IDENTITY` normally rejects explicit ID input unless overridden; `BY DEFAULT` permits it. `SERIAL` is an older PostgreSQL shorthand based on sequences; identity columns are the modern SQL-standard approach used here. Sequence values may have gaps, including after rollback; IDs are not row counts.

Foreign keys preserve **referential integrity**. This lab does not cascade-delete orders when a customer is deleted. PostgreSQL blocks deletion of a referenced customer by default. `ON DELETE CASCADE` is appropriate only when deleting all dependent rows matches your intended lifecycle.

## INSERT

```sql
INSERT INTO study_topics (title, priority)
VALUES ('Window functions', 4)
RETURNING topic_id, title, priority;
```

Name the columns explicitly. RETURNING gives inserted values, including generated IDs. Multiple rows can be inserted in one VALUES list.

```sql
INSERT INTO study_topics (title)
SELECT DISTINCT category FROM products;
```

INSERT ... SELECT copies query results. Re-running these examples can encounter UNIQUE violations; that rule is working as intended.

## UPDATE

```sql
UPDATE study_topics
SET reviewed_on = DATE '2026-10-02', priority = 3
WHERE title = 'Window functions'
RETURNING *;
```

Without WHERE, UPDATE affects every row. First preview the target rows with SELECT. `RETURNING` shows what changed; it is useful in PostgreSQL and not universally portable.

## DELETE

```sql
DELETE FROM study_topics
WHERE title = 'Window functions'
RETURNING *;
```

DELETE removes rows while preserving the table. A missing WHERE removes all rows. Always check the intended condition before executing.

## ALTER TABLE

```sql
ALTER TABLE study_topics ADD COLUMN notes text;
ALTER TABLE study_topics RENAME COLUMN notes TO personal_notes;
ALTER TABLE study_topics ALTER COLUMN priority SET DEFAULT 2;
ALTER TABLE study_topics DROP COLUMN personal_notes;
```

ALTER changes an existing definition. Some alterations validate/rewrite existing data or need locks; consider these effects on real systems.

## DELETE versus TRUNCATE versus DROP

| Statement | Effect | Supports WHERE? |
| --- | --- | --- |
| `DELETE FROM study_topics` | Removes rows; table remains | Yes |
| `TRUNCATE TABLE study_topics` | Empties the table without row-by-row deletion | No |
| `DROP TABLE study_topics` | Removes the table itself | No |

PostgreSQL TRUNCATE does **not** drop and recreate the table. It has stronger locking and foreign-key restrictions than a simple DELETE. `RESTART IDENTITY` resets associated identity sequences; it does not happen by default. TRUNCATE is transactional in PostgreSQL.

```sql
DROP TABLE study_topics;
```

Run only when you are finished with that optional table. Avoid casual CASCADE: it can remove dependent objects too.

## Upsert: insert or handle a conflict

```sql
INSERT INTO customers (name,email,city,signup_date)
VALUES ('Amina','amina@example.test','Dublin',DATE '2025-12-01')
ON CONFLICT (email) DO UPDATE SET city = EXCLUDED.city
RETURNING customer_id, name, city;
```

This optional statement changes data. `EXCLUDED` refers to the attempted new row. ON CONFLICT needs an applicable unique/exclusion rule; this one uses the unique email. It can advance the identity sequence even when the existing row is updated.

**Try it:** explain why `price numeric CHECK (price >= 0)` alone permits NULL. CHECK rejects FALSE, not UNKNOWN; add NOT NULL.
