# 12 · Indexes, EXPLAIN, and Python

[Home](../README.md) · [Next: interview review](13-interview-review.md)

## What an index does

An **index** is a separate data structure that can help PostgreSQL locate relevant rows without scanning the whole table. It costs storage and extra write work. An index is not a promise that every query will become faster.

```sql
CREATE INDEX IF NOT EXISTS idx_orders_customer_date
ON orders (customer_id, order_date);
```

This optional index is useful for queries filtering by customer and then date. Composite B-tree indexes are generally most effective when predicates constrain leading columns; do not assume the same benefit for every query on the second column alone. Planner choices depend on selectivity, table size, statistics, and PostgreSQL version.

Primary keys and unique constraints create supporting unique indexes in PostgreSQL. Foreign keys do **not** automatically create an index on the referencing column; decide whether one is useful.

## EXPLAIN versus EXPLAIN ANALYZE

```sql
EXPLAIN
SELECT * FROM orders
WHERE customer_id = 1 AND order_date >= DATE '2026-01-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders
WHERE customer_id = 1 AND order_date >= DATE '2026-01-01';
```

EXPLAIN shows an estimated execution plan. EXPLAIN ANALYZE actually executes the statement and reports observed behavior. **For UPDATE/DELETE/INSERT it actually changes data** unless contained in a transaction you roll back. Use SELECT while learning.

Look for scans, join strategies, estimated versus actual rows, loops, and time. Costs are planner units, not milliseconds. With only six orders, a sequential scan is often sensible even when an index exists.

Good habits: select needed columns; establish row grain; avoid accidental cross joins; use range filters on date/time columns; measure before optimizing. Wrapping a column in a function can prevent use of a plain index for that predicate; an expression index may help specific cases. `ANALYZE orders;` refreshes statistics, distinct from EXPLAIN ANALYZE.

## Python setup

This tutorial uses **Psycopg 3**, imported as `psycopg`. It is a modern alternative to older course examples using psycopg2; the basic parameterized-query ideas are the same.

From the repository folder in Terminal:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r python/requirements.txt
```

Set connection details without hardcoding passwords:

```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=sql_practice
export PGUSER=postgres
python python/query_customers.py Dublin
```

The script asks for the password using a hidden prompt. Do not commit credentials. If `.env` files are later added to your own workflow, they are ignored by the supplied `.gitignore` but are not automatically loaded by this script.

## Parameterized values

```python
with conn.cursor() as cur:
    cur.execute(
        "SELECT name FROM customers WHERE city = %s ORDER BY customer_id",
        (city,),
    )
    rows = cur.fetchall()
```

Values go in a separate tuple. `(city,)` is a one-element tuple; `(city)` is just the value. `%s` is a Psycopg value placeholder, not Python interpolation. Do not quote it and do not combine user input into SQL with f-strings or `%` formatting.

For dynamic **identifiers** (table/column names), value placeholders do not work; use `psycopg.sql.Identifier` and a deliberate allowlist where appropriate. The supplied script has fixed identifiers.

## Connection and transaction behavior

`with psycopg.connect(...) as conn:` commits on normal block exit, rolls back on exception, and closes the connection. A cursor is used to execute SQL and fetch results. `fetchone()` returns one row or None; `fetchall()` returns the remaining rows. For large results consider iteration/batching rather than fetching all rows at once.

The supplied example only reads customer data and catches connection/query errors with a short diagnostic. Passwords are never printed.

References: [Psycopg usage](https://www.psycopg.org/psycopg3/docs/basic/usage.html), [parameters](https://www.psycopg.org/psycopg3/docs/basic/params.html), [EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html).
