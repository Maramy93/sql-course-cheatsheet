# 04 · Aggregation, GROUP BY, and HAVING

[Home](../README.md) · [Next: joins](05-joins-and-sets.md)

An **aggregate** summarizes several input rows into one value. GROUP BY makes one summary row per group; it changes the result grain.

| Function | Purpose | NULL behavior |
| --- | --- | --- |
| `COUNT(*)` | Count rows | Counts rows containing NULL |
| `COUNT(column)` | Count present values | Ignores NULL |
| `COUNT(DISTINCT column)` | Count distinct present values | Ignores NULL |
| `SUM(column)` | Add values | Ignores NULL |
| `AVG(column)` | Mean of present values | Ignores NULL |
| `MIN(column)`, `MAX(column)` | Smallest/largest | Ignore NULL |

```sql
SELECT COUNT(*) AS customers,
       COUNT(city) AS known_cities,
       COUNT(DISTINCT city) AS distinct_cities
FROM customers;
```

Result: **5, 4, 3**. Most aggregates return NULL on an empty input; COUNT returns 0. Use COALESCE only when zero correctly expresses your meaning.

## GROUP BY: one row per city

```sql
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC, city NULLS LAST;
```

| city | customer_count |
| --- | --- |
| Dublin | 2 |
| Cork | 1 |
| Galway | 1 |
| NULL | 1 |

NULL values form a group. As a general rule, selected non-aggregate expressions must be grouped; PostgreSQL also allows some expressions functionally dependent on a grouped primary key. Explicit grouping is easier to review when learning.

## WHERE filters rows; HAVING filters groups

```sql
SELECT city, COUNT(*) AS active_customers
FROM customers
WHERE active
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY city;
```

Only Dublin survives, with 2 active customers. WHERE removes inactive Diego **before** grouping. HAVING evaluates the resulting aggregate values.

Incorrect: `WHERE COUNT(*) >= 2`. Incorrect in PostgreSQL: `HAVING active_customers >= 2`. Repeat the aggregate expression or use a CTE.

## Revenue: get the grain and status right

Revenue in this tutorial means paid order item quantity × sale price.

```sql
SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) AS paid_revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'paid';
```

Result: **189.50**. Pending and cancelled lines are excluded. Current product price is not used.

```sql
SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;
```

| order_id | order_total |
| --- | --- |
| 1 | 21.50 |
| 2 | 54.00 |
| 3 | 36.00 |
| 6 | 78.00 |

Average paid **order total** is `189.50 / 4 = 47.375`. AVG of individual line totals would answer a different question. First aggregate to order grain, then average those totals:

```sql
SELECT ROUND(AVG(order_total), 2) AS average_order_total
FROM (
 SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_total
 FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
 WHERE o.status = 'paid'
 GROUP BY o.order_id
) AS paid_orders;
```

Result: **47.38**.

## Conditional aggregation

```sql
SELECT customer_id,
       COUNT(*) FILTER (WHERE status = 'paid') AS paid_orders,
       COUNT(*) FILTER (WHERE status = 'pending') AS pending_orders
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
```

Result: Amina's ID 1 → 2 paid/0 pending; Ben's ID 2 → 1/0; Clara's ID 3 → 1/1. Customers without any orders are absent; use a LEFT JOIN to include them.

An equivalent broadly portable pattern is `SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END)`.

## COUNT after a LEFT JOIN

```sql
SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY c.customer_id;
```

Counts: **2, 2, 2, 0, 0**. COUNT(*) would count the preserved NULL-extended row for Diego and Eli as one. Count a non-null key on the joined side when you mean matched rows.

**Try it:** find product categories with an average current price above €15. Expected categories: Home (€21) and Travel (€40).
