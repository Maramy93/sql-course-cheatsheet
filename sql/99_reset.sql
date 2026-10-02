-- DESTRUCTIVE: removes this tutorial's tables and stored objects.
-- Run ONLY in a disposable sql_practice database, then reload schema + seed.
BEGIN;
DROP VIEW IF EXISTS paid_order_totals;
DROP FUNCTION IF EXISTS customer_paid_revenue(integer);
DROP PROCEDURE IF EXISTS mark_customer_inactive(integer);
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
COMMIT;
