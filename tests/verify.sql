-- PostgreSQL assertions. Run AFTER schema + seed, before modifying baseline data.
-- In psql use: -v ON_ERROR_STOP=1 -f tests/verify.sql
DO $$
DECLARE actual numeric;
BEGIN
 IF (SELECT COUNT(*) FROM customers) <> 5 THEN RAISE EXCEPTION 'Expected 5 customers'; END IF;
 IF (SELECT COUNT(*) FROM products) <> 5 THEN RAISE EXCEPTION 'Expected 5 products'; END IF;
 IF (SELECT COUNT(*) FROM orders) <> 6 THEN RAISE EXCEPTION 'Expected 6 orders'; END IF;
 IF (SELECT COUNT(*) FROM order_items) <> 9 THEN RAISE EXCEPTION 'Expected 9 items'; END IF;
 IF (SELECT COUNT(city) FROM customers) <> 4 THEN RAISE EXCEPTION 'Expected 4 known cities'; END IF;
 IF (SELECT COUNT(DISTINCT city) FROM customers) <> 3 THEN RAISE EXCEPTION 'Expected 3 distinct known cities'; END IF;
 SELECT SUM(oi.quantity*oi.unit_price) INTO actual FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid';
 IF actual IS DISTINCT FROM 189.50 THEN RAISE EXCEPTION 'Revenue mismatch: %',actual; END IF;
 IF (SELECT COUNT(*) FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id) <> 8 THEN RAISE EXCEPTION 'Expected 8 left-join rows'; END IF;
 IF (SELECT COUNT(*) FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.status='paid') <> 6 THEN RAISE EXCEPTION 'Expected 6 paid-preserving join rows'; END IF;
 IF (SELECT COUNT(*) FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id)) <> 2 THEN RAISE EXCEPTION 'Expected 2 customers without orders'; END IF;
 IF (SELECT COUNT(*) FROM products p WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id=p.product_id)) <> 1 THEN RAISE EXCEPTION 'Expected 1 product without orders'; END IF;
 WITH totals AS (SELECT o.order_id,SUM(oi.quantity*oi.unit_price) AS total FROM orders o JOIN order_items oi ON oi.order_id=o.order_id WHERE o.status='paid' GROUP BY o.order_id)
 SELECT ROUND(AVG(total),2) INTO actual FROM totals;
 IF actual IS DISTINCT FROM 47.38 THEN RAISE EXCEPTION 'Average order value mismatch: %',actual; END IF;
 WITH ranked AS (SELECT price,DENSE_RANK() OVER (ORDER BY price DESC) AS rnk FROM products)
 SELECT MIN(price) INTO actual FROM ranked WHERE rnk=2;
 IF actual IS DISTINCT FROM 30 THEN RAISE EXCEPTION 'Second distinct price mismatch: %',actual; END IF;
 RAISE NOTICE 'Baseline checks passed.';
END;
$$;
