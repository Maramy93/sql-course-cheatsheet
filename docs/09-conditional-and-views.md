# 09 · CASE, NULL handling, views, functions, and procedures

[Home](../README.md) · [Next: transactions](10-transactions.md)

## CASE: produce values with conditions

```sql
SELECT product_name, price,
 CASE
  WHEN price >= 30 THEN 'Premium'
  WHEN price >= 10 THEN 'Standard'
  ELSE 'Budget'
 END AS price_band
FROM products ORDER BY product_id;
```

Bands: Notebook Budget, Pen Set Budget, Desk Lamp Premium, Mug Standard, Backpack Premium. CASE uses the first TRUE branch; order thresholds carefully. Without ELSE, unmatched rows return NULL. All result branches need compatible data types.

A simple CASE compares one value:

```sql
SELECT order_id,
 CASE status
  WHEN 'paid' THEN 'Complete'
  WHEN 'pending' THEN 'Waiting'
  ELSE 'Closed'
 END AS status_label
FROM orders ORDER BY order_id;
```

CASE is an **expression** that returns a value; it is not by itself a procedural loop.

## COALESCE: first non-null value

```sql
SELECT name, COALESCE(city, 'Unknown') AS city_label
FROM customers ORDER BY customer_id;
```

Eli's label becomes Unknown for this result only. The stored city remains NULL. Use a value with a compatible type; `COALESCE(numeric_column, 'Unknown')` cannot serve as a numeric result.

## NULLIF: turn a particular value into NULL

```sql
SELECT 10.0 / NULLIF(0, 0) AS safe_ratio; -- NULL
SELECT NULLIF('', '') AS empty_to_null; -- NULL
```

NULLIF(a,b) returns NULL when a = b, otherwise a. For a ratio, `numerator::numeric / NULLIF(denominator, 0)` avoids division by zero. Whether to display a missing ratio as zero is a separate business decision.

## GREATEST and LEAST

```sql
SELECT GREATEST(8, 12, 30), LEAST(8, 12, 30); -- 30, 8
```

They compare expressions within a row; MAX/MIN aggregate across rows. PostgreSQL ignores NULL arguments here unless all arguments are NULL; other systems can differ.

## Views: save a query definition

A normal **view** behaves like a named query. It does not cache its output rows.

```sql
CREATE OR REPLACE VIEW paid_order_totals AS
SELECT o.order_id, o.customer_id, o.order_date,
       SUM(oi.quantity * oi.unit_price) AS total
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, o.customer_id, o.order_date;

SELECT * FROM paid_order_totals ORDER BY order_id;
```

Result: orders 1, 2, 3, 6 with totals 21.50, 54, 36, 78. A materialized view stores results and needs refresh to reflect changes. View-based access can expose selected columns, but do not assume all views are automatically a security boundary.

## Functions versus procedures

| Object | How called | Intended use in this lab |
| --- | --- | --- |
| Function | In an expression / SELECT | Return a reusable calculated value |
| Procedure | `CALL ...` | Execute a named action |

Load `sql/04_functions_and_views.sql` first. It creates the same view above and the objects below; you can load it again with CREATE OR REPLACE.

```sql
SELECT customer_paid_revenue(1); -- 57.50
```

The SQL function takes a customer ID, sums paid item revenue, and returns zero when there is none. Unlike a query template, a function is a stored database object.

```sql
BEGIN;
CALL mark_customer_inactive(5);
SELECT active FROM customers WHERE customer_id = 5; -- FALSE
ROLLBACK;
```

The procedure changes Eli's active flag; rollback restores TRUE. Our procedure contains no transaction-control statements. PostgreSQL procedures can manage transactions only in permitted call contexts; a procedure does not imply an automatic commit.

```sql
DROP VIEW IF EXISTS paid_order_totals;
```

This optional cleanup removes the view definition, not the underlying orders. The reset script removes these tutorial objects before rebuilding the tables.

**Try it:** label prices under 10 as Low and all others as Other. Then explain why `CASE WHEN price < 10 ...` would classify a nullable price as Other.
