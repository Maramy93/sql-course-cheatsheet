# 06 · Strings, numbers, dates, and casts

[Home](../README.md) · [Next: subqueries](07-subqueries-and-ctes.md)

A **scalar function** returns a value for each input row, unlike an aggregate that summarizes rows.

## Strings

| Expression | Meaning | Example output |
| --- | --- | --- |
| `LOWER('SQL')` | Lowercase | `sql` |
| `UPPER('Sql')` | Uppercase | `SQL` |
| `LENGTH('Ben')` | Character count | `3` |
| `TRIM('  Ben  ')` | Trim boundary spaces | `Ben` |
| `SUBSTRING('Notebook' FROM 1 FOR 4)` | Extract text, positions start at 1 | `Note` |
| `LEFT('Notebook', 4)` | First characters | `Note` |
| `REPLACE('Desk Lamp', 'Lamp', 'Light')` | Replace text | `Desk Light` |
| `SPLIT_PART('a@b.test', '@', 2)` | Field from separated text | `b.test` |
| `'SQL' || ' guide'` | Concatenate | `SQL guide` |
| `CONCAT('SQL', ' guide')` | Concatenate; NULL arguments ignored | `SQL guide` |

```sql
SELECT name, LOWER(email) AS normalized_email,
       name || ' / ' || COALESCE(city, 'Unknown') AS display_name
FROM customers
ORDER BY customer_id;
```

With `||`, a NULL argument generally makes the result NULL. CONCAT skips NULL arguments; decide whether omission or an explicit label is appropriate.

## Math and numeric casts

```sql
SELECT 5 / 2 AS integer_division,        -- 2
       5.0 / 2 AS decimal_division,      -- 2.5
       ROUND(19.567::numeric, 2) AS rounded, -- 19.57
       ABS(-5) AS absolute_value,       -- 5
       7 % 3 AS remainder;              -- 1
```

Integer division truncates. Cast one side before dividing: `CAST(5 AS numeric) / 2` or PostgreSQL shorthand `5::numeric / 2`.

```sql
SELECT '2026-02-01'::date AS parsed_date,
       CAST('12.50' AS numeric) AS parsed_price;
```

Invalid input, such as `'hello'::integer`, raises an error rather than quietly becoming zero.

## Date and time definitions

- **date:** day without time of day.
- **timestamp without time zone:** date/time interpreted as wall-clock fields.
- **timestamptz:** a particular instant, displayed using the session time zone. It does not retain the original named time zone.
- **interval:** a duration or calendar offset such as one month.

Use explicit ISO dates (`YYYY-MM-DD`) in examples to avoid locale ambiguity.

```sql
SELECT CURRENT_DATE,
       CURRENT_TIMESTAMP,
       DATE '2026-01-05' + 7 AS one_week_later,
       DATE '2026-02-01' - DATE '2026-01-05' AS elapsed_days;
```

Last two results: 2026-01-12 and 27. CURRENT_TIMESTAMP is the transaction start timestamp in PostgreSQL; use `clock_timestamp()` when you specifically need the changing wall-clock time.

## Extract, truncate, format

```sql
SELECT order_id,
       EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       DATE_TRUNC('month', order_date::timestamp)::date AS month_start,
       TO_CHAR(order_date, 'YYYY-MM') AS month_label
FROM orders ORDER BY order_id;
```

EXTRACT gets a component. DATE_TRUNC resets lower components to a boundary. TO_CHAR produces formatted **text**, useful for display. Group by actual date boundaries when you need real chronological buckets.

```sql
SELECT DATE_TRUNC('month', o.order_date::timestamp)::date AS month_start,
       SUM(oi.quantity * oi.unit_price) AS paid_revenue
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY DATE_TRUNC('month', o.order_date::timestamp)::date
ORDER BY month_start;
```

| month_start | paid_revenue |
| --- | --- |
| 2026-01-01 | 75.50 |
| 2026-02-01 | 36.00 |
| 2026-03-01 | 78.00 |

Grouping only by EXTRACT(MONTH ...) mixes January from different years.

## Time zones

```sql
SELECT TIMESTAMPTZ '2026-07-01 12:00:00+00'
       AT TIME ZONE 'Europe/Dublin' AS dublin_wall_time;
```

Result: `2026-07-01 13:00:00` as a timestamp without time zone. For a timestamptz input, AT TIME ZONE converts to local wall time. For a timestamp input, it interprets the fields in that zone and returns an instant. Daylight-saving changes mean named zones are preferable to assuming a constant UTC offset.

For a local-calendar-day filter on a timestamptz column:

```sql
SELECT order_id FROM orders
WHERE created_at >= (TIMESTAMP '2026-01-05 00:00:00' AT TIME ZONE 'Europe/Dublin')
  AND created_at <  (TIMESTAMP '2026-01-06 00:00:00' AT TIME ZONE 'Europe/Dublin');
```

**Try it:** show each email's domain. Use `SPLIT_PART(email, '@', 2)`; all seeded domains are `example.test`.

Function syntax varies across database products. See [PostgreSQL functions and operators](https://www.postgresql.org/docs/current/functions.html).
