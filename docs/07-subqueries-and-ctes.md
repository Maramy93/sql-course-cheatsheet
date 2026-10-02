# 07 · Subqueries, EXISTS, and CTEs

[Home](../README.md) · [Next: table changes](08-tables-and-changes.md)

A **subquery** is a query inside another statement. A **CTE** (common table expression) gives a query result a name within one statement using WITH. Neither automatically creates a permanent table.

## Scalar subquery: one value

```sql
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
```

Average current price is 19.10. Result: Backpack 40 and Desk Lamp 30. A scalar subquery must return one column and at most one row; zero rows becomes NULL, multiple rows raises an error.

## List subquery: IN

```sql
SELECT name FROM customers
WHERE customer_id IN (
 SELECT customer_id FROM orders WHERE status = 'paid'
)
ORDER BY customer_id; -- Amina, Ben, Clara
```

IN asks whether the outer value appears in the inner result. Duplicates in that list do not duplicate outer rows.

## Correlated subquery: refer to the current outer row

```sql
SELECT c.name,
       (SELECT COUNT(*) FROM orders o
        WHERE o.customer_id = c.customer_id AND o.status = 'paid') AS paid_orders
FROM customers c
ORDER BY c.customer_id;
```

Counts: 2, 1, 1, 0, 0. The inner query references `c.customer_id`. Conceptually it answers a question for each customer; the optimizer may transform the actual execution.

## EXISTS and NOT EXISTS

```sql
SELECT c.name FROM customers c
WHERE EXISTS (
 SELECT 1 FROM orders o
 WHERE o.customer_id = c.customer_id AND o.status = 'paid'
)
ORDER BY c.customer_id;
```

EXISTS checks whether **any row** is returned. `SELECT 1` communicates that the row contents are irrelevant. It does not multiply customers with multiple orders.

```sql
SELECT c.name FROM customers c
WHERE NOT EXISTS (
 SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id; -- Diego, Eli
```

NOT EXISTS is a useful anti join and avoids the `NOT IN` inner-NULL trap. Choose a join when you need related columns, EXISTS when you only need to test whether a related record is present.

## Derived table: named result in FROM

```sql
SELECT order_id, order_total
FROM (
 SELECT order_id, SUM(quantity * unit_price) AS order_total
 FROM order_items GROUP BY order_id
) AS totals
WHERE order_total > 50
ORDER BY order_total DESC;
```

Result: order 6 (€78), order 2 (€54). A derived table alias makes the intermediate relation clear.

## CTE: name each step

```sql
WITH paid_order_totals AS (
 SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS total
 FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
 WHERE o.status = 'paid'
 GROUP BY o.order_id, o.customer_id
), customer_totals AS (
 SELECT customer_id, SUM(total) AS revenue
 FROM paid_order_totals GROUP BY customer_id
)
SELECT c.name, ct.revenue
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY ct.revenue DESC, c.customer_id;
```

Result: Clara 78, Amina 57.50, Ben 54. The intermediate steps keep their grain explicit: one row per order, then one row per customer.

A CTE is not always faster or slower than a subquery. PostgreSQL can inline eligible CTEs; materialization depends on usage and options. Start with clear SQL and measure actual plans.

## Optional: recursive CTE

Recursive CTEs repeatedly build on earlier results, useful for hierarchies. A tiny self-contained example generates numbers:

```sql
WITH RECURSIVE numbers(n) AS (
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM numbers WHERE n < 5
)
SELECT n FROM numbers ORDER BY n;
```

Result: 1 through 5. The anchor starts the result; the recursive part extends it. A termination condition prevents unbounded recursion. Tree traversals also need protection against cycles when the data can contain them.

**Try it:** find products priced above their own category average. Use a correlated AVG subquery comparing `p.category` to the inner category. Expected: Notebook and Desk Lamp.
