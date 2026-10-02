# Worked solutions

[Questions](QUESTIONS.md) · [Home](../README.md)

## 1. Active Dublin customers

```sql
SELECT name, signup_date FROM customers WHERE active AND city='Dublin' ORDER BY signup_date DESC,customer_id;
```

Clara (2025-12-10), Amina (2025-12-01). AND combines the two row conditions.

## 2. Two most expensive products

```sql
SELECT product_name,price FROM products ORDER BY price DESC,product_id LIMIT 2;
```

Backpack 40, Desk Lamp 30. The ID supplies a deterministic tie-breaker.

## 3. Counts and NULL

```sql
SELECT COUNT(*) AS customers,COUNT(city) AS known_cities,COUNT(DISTINCT city) AS distinct_cities FROM customers;
```

5, 4, 3. COUNT(column) ignores NULL.

## 4. February orders

```sql
SELECT order_id FROM orders WHERE order_date >= DATE '2026-02-01' AND order_date < DATE '2026-03-01' ORDER BY order_id;
```

3, 4, 5. The half-open range includes all February dates.

## 5. Category averages

```sql
SELECT category,ROUND(AVG(price),2) AS average_price FROM products GROUP BY category HAVING AVG(price)>15 ORDER BY category;
```

Home 21, Travel 40. HAVING filters the aggregate result.

## 6. Customer order counts

```sql
SELECT c.customer_id,c.name,COUNT(o.order_id) AS order_count FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id GROUP BY c.customer_id,c.name ORDER BY c.customer_id;
```

Amina 2, Ben 2, Clara 2, Diego 0, Eli 0. Count the joined key, not COUNT(*).

## 7. Customers with no orders

```sql
SELECT c.name FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id) ORDER BY c.customer_id;
```

Diego, Eli. NOT EXISTS does not duplicate outer customers.

## 8. Products never ordered

```sql
SELECT p.product_name FROM products p WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id=p.product_id) ORDER BY p.product_id;
```

Backpack. This includes orders in every status when checking existence.

## 9. Paid revenue

```sql
SELECT SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid';
```

189.50. Use historical sale price and exclude pending/cancelled orders.

## 10. Revenue for all customers

```sql
SELECT c.customer_id,c.name,COALESCE(SUM(oi.quantity*oi.unit_price),0) AS revenue FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.status='paid' LEFT JOIN order_items oi ON oi.order_id=o.order_id GROUP BY c.customer_id,c.name ORDER BY revenue DESC,c.customer_id;
```

Clara 78, Amina 57.50, Ben 54, Diego 0, Eli 0. The status filter belongs in ON to preserve customers.

## 11. Average paid order value

```sql
WITH totals AS (SELECT o.order_id,SUM(oi.quantity*oi.unit_price) AS total FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY o.order_id) SELECT ROUND(AVG(total),2) AS average_order_value FROM totals;
```

47.38. First create one row per paid order.

## 12. Monthly paid revenue

```sql
SELECT DATE_TRUNC('month',o.order_date::timestamp)::date AS month_start,SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY DATE_TRUNC('month',o.order_date::timestamp)::date ORDER BY month_start;
```

2026-01-01: 75.50; 2026-02-01: 36; 2026-03-01: 78.

## 13. Top product by category

```sql
WITH ranked AS (SELECT product_name,category,price,ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC,product_id) AS rn FROM products) SELECT category,product_name,price FROM ranked WHERE rn=1 ORDER BY category;
```

Home: Desk Lamp 30; Stationery: Notebook 8; Travel: Backpack 40.

## 14. Second-highest distinct price

```sql
WITH ranked AS (SELECT product_name,price,DENSE_RANK() OVER (ORDER BY price DESC) AS rnk FROM products) SELECT product_name,price FROM ranked WHERE rnk=2 ORDER BY product_name;
```

Desk Lamp 30. DENSE_RANK preserves tied distinct prices.

## 15. Running revenue

```sql
WITH totals AS (SELECT o.order_id,o.order_date,SUM(oi.quantity*oi.unit_price) AS total FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY o.order_id,o.order_date) SELECT order_id,total,SUM(total) OVER (ORDER BY order_date,order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue FROM totals ORDER BY order_date,order_id;
```

Order 1: 21.50; order 2: 75.50; order 3: 111.50; order 6: 189.50 cumulative.
