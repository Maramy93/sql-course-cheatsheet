-- Read-only queries. Run after schema + seed; run one at a time to inspect results.

-- 1. Active Dublin customers
-- Clara (2025-12-10), Amina (2025-12-01). AND combines the two row conditions.
SELECT name, signup_date FROM customers WHERE active AND city='Dublin' ORDER BY signup_date DESC,customer_id;

-- 2. Two most expensive products
-- Backpack 40, Desk Lamp 30. The ID supplies a deterministic tie-breaker.
SELECT product_name,price FROM products ORDER BY price DESC,product_id LIMIT 2;

-- 3. Counts and NULL
-- 5, 4, 3. COUNT(column) ignores NULL.
SELECT COUNT(*) AS customers,COUNT(city) AS known_cities,COUNT(DISTINCT city) AS distinct_cities FROM customers;

-- 4. February orders
-- 3, 4, 5. The half-open range includes all February dates.
SELECT order_id FROM orders WHERE order_date >= DATE '2026-02-01' AND order_date < DATE '2026-03-01' ORDER BY order_id;

-- 5. Category averages
-- Home 21, Travel 40. HAVING filters the aggregate result.
SELECT category,ROUND(AVG(price),2) AS average_price FROM products GROUP BY category HAVING AVG(price)>15 ORDER BY category;

-- 6. Customer order counts
-- Amina 2, Ben 2, Clara 2, Diego 0, Eli 0. Count the joined key, not COUNT(*).
SELECT c.customer_id,c.name,COUNT(o.order_id) AS order_count FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id GROUP BY c.customer_id,c.name ORDER BY c.customer_id;

-- 7. Customers with no orders
-- Diego, Eli. NOT EXISTS does not duplicate outer customers.
SELECT c.name FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id) ORDER BY c.customer_id;

-- 8. Products never ordered
-- Backpack. This includes orders in every status when checking existence.
SELECT p.product_name FROM products p WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id=p.product_id) ORDER BY p.product_id;

-- 9. Paid revenue
-- 189.50. Use historical sale price and exclude pending/cancelled orders.
SELECT SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid';

-- 10. Revenue for all customers
-- Clara 78, Amina 57.50, Ben 54, Diego 0, Eli 0. The status filter belongs in ON to preserve customers.
SELECT c.customer_id,c.name,COALESCE(SUM(oi.quantity*oi.unit_price),0) AS revenue FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.status='paid' LEFT JOIN order_items oi ON oi.order_id=o.order_id GROUP BY c.customer_id,c.name ORDER BY revenue DESC,c.customer_id;

-- 11. Average paid order value
-- 47.38. First create one row per paid order.
WITH totals AS (SELECT o.order_id,SUM(oi.quantity*oi.unit_price) AS total FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY o.order_id) SELECT ROUND(AVG(total),2) AS average_order_value FROM totals;

-- 12. Monthly paid revenue
-- 2026-01-01: 75.50; 2026-02-01: 36; 2026-03-01: 78.
SELECT DATE_TRUNC('month',o.order_date::timestamp)::date AS month_start,SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY DATE_TRUNC('month',o.order_date::timestamp)::date ORDER BY month_start;

-- 13. Top product by category
-- Home: Desk Lamp 30; Stationery: Notebook 8; Travel: Backpack 40.
WITH ranked AS (SELECT product_name,category,price,ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC,product_id) AS rn FROM products) SELECT category,product_name,price FROM ranked WHERE rn=1 ORDER BY category;

-- 14. Second-highest distinct price
-- Desk Lamp 30. DENSE_RANK preserves tied distinct prices.
WITH ranked AS (SELECT product_name,price,DENSE_RANK() OVER (ORDER BY price DESC) AS rnk FROM products) SELECT product_name,price FROM ranked WHERE rnk=2 ORDER BY product_name;

-- 15. Running revenue
-- Order 1: 21.50; order 2: 75.50; order 3: 111.50; order 6: 189.50 cumulative.
WITH totals AS (SELECT o.order_id,o.order_date,SUM(oi.quantity*oi.unit_price) AS total FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY o.order_id,o.order_date) SELECT order_id,total,SUM(total) OVER (ORDER BY order_date,order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue FROM totals ORDER BY order_date,order_id;
