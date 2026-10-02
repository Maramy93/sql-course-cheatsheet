-- Optional stored objects for chapter 9.
CREATE OR REPLACE VIEW paid_order_totals AS
SELECT o.order_id,o.customer_id,o.order_date,SUM(oi.quantity*oi.unit_price) AS total
FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
WHERE o.status='paid'
GROUP BY o.order_id,o.customer_id,o.order_date;

CREATE OR REPLACE FUNCTION customer_paid_revenue(p_customer_id integer)
RETURNS numeric
LANGUAGE sql STABLE
AS $$
 SELECT COALESCE(SUM(oi.quantity*oi.unit_price),0)
 FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
 WHERE o.customer_id=p_customer_id AND o.status='paid';
$$;

CREATE OR REPLACE PROCEDURE mark_customer_inactive(p_customer_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
 UPDATE customers SET active=FALSE WHERE customer_id=p_customer_id;
END;
$$;
