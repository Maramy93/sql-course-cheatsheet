# PostgreSQL quick reference

[Full tutorial](README.md) · [Interview questions](docs/13-interview-review.md)

## Read data

```sql
SELECT DISTINCT column1, column2
FROM table_name
WHERE row_condition
GROUP BY column1, column2
HAVING group_condition
ORDER BY column1 DESC, column2 ASC
LIMIT 10 OFFSET 0;
```

Template: select/group only what your particular query needs. Logical order: FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT/windows → DISTINCT → ORDER BY → LIMIT. SELECT aliases work in ORDER BY, not WHERE/HAVING.

| Need | Pattern |
| --- | --- |
| Equal / different | `x = 3` / `x <> 3` |
| Both / either | `a AND b` / `a OR b` |
| Missing | `x IS NULL` |
| Null-safe difference | `x IS DISTINCT FROM y` |
| Membership | `x IN (1, 2, 3)` |
| Inclusive numeric range | `x BETWEEN 10 AND 20` |
| Half-open date range | `d >= DATE '2026-01-01' AND d < DATE '2026-02-01'` |
| Pattern | `name LIKE 'A%'`; `%` = any length, `_` = one character |
| Case-insensitive pattern | `name ILIKE '%lamp%'` (PostgreSQL) |
| Rename output | `expression AS alias` |
| Deterministic top N | `ORDER BY score DESC, id LIMIT 3` |

## Summaries

```sql
SELECT city, COUNT(*) AS n
FROM customers WHERE active
GROUP BY city HAVING COUNT(*) >= 2;
```

COUNT(*) counts rows; COUNT(x) ignores NULL; SUM/AVG/MIN/MAX ignore NULL. COUNT over no rows gives 0; SUM over no rows gives NULL. AVG of order totals requires one input row per order.

## Joins

```sql
SELECT c.name, o.order_id
FROM customers c
LEFT JOIN orders o
 ON o.customer_id = c.customer_id AND o.status = 'paid';
```

| Need | Choice |
| --- | --- |
| Matching pairs | INNER JOIN |
| All left rows | LEFT JOIN |
| All right rows | RIGHT JOIN |
| All rows on both sides | FULL OUTER JOIN |
| Every combination | CROSS JOIN |
| No related row | NOT EXISTS, or LEFT JOIN + right PK IS NULL |
| Stack rows / keep duplicates | UNION / UNION ALL |

One-to-many joins multiply parent rows. COUNT(DISTINCT parent_id) counts parents; duplicated SUM needs grain correction, not SUM(DISTINCT value).

## Expressions

```sql
CASE WHEN price >= 30 THEN 'Premium' ELSE 'Other' END
COALESCE(city, 'Unknown')
amount::numeric / NULLIF(quantity, 0)
LOWER(email)
TRIM(name)
SPLIT_PART(email, '@', 2)
DATE_TRUNC('month', order_date::timestamp)
EXTRACT(YEAR FROM order_date)
```

`::type` is PostgreSQL casting; `CAST(value AS type)` is the standard form. Strings use `'single quotes'`; identifiers use `"double quotes"` only when needed.

## CTE and window patterns

```sql
WITH ranked AS (
 SELECT product_id, category, price,
 ROW_NUMBER() OVER (
  PARTITION BY category ORDER BY price DESC, product_id
 ) AS rn FROM products
)
SELECT * FROM ranked WHERE rn = 1;
```

ROW_NUMBER = distinct row positions; RANK = ties with gaps; DENSE_RANK = ties without gaps. LAG/LEAD look back/ahead. A running sum uses `SUM(x) OVER (ORDER BY d, id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.

## Define and change data (templates)

```sql
CREATE TABLE example (
 id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 label text UNIQUE NOT NULL,
 quantity integer NOT NULL CHECK (quantity > 0)
);
INSERT INTO example (label, quantity) VALUES ('Practice', 2) RETURNING *;
UPDATE example SET quantity = 3 WHERE label = 'Practice' RETURNING *;
DELETE FROM example WHERE label = 'Practice' RETURNING *;
ALTER TABLE example ADD COLUMN note text;
```

DEFAULT supplies omitted values; CHECK permits UNKNOWN; UNIQUE usually permits multiple NULLs; FK does not imply NOT NULL. Identity/sequence gaps are normal.

## Transactions, performance, Python

```sql
BEGIN;
-- make and inspect changes
ROLLBACK; -- or COMMIT to persist
```

EXPLAIN estimates a plan; EXPLAIN ANALYZE executes it. Indexes have write/storage cost. Psycopg: `cur.execute('SELECT ... WHERE city = %s', (city,))` passes values separately.

## Interview traps

NULL is not zero. NOT IN can fail with NULL. WHERE on the right side of LEFT JOIN can discard preserved rows. LIMIT needs ORDER BY. Avoid counting item rows as orders. Clarify status, time zone, grain, and ties before coding.
