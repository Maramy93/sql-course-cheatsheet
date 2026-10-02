-- Run once after 00_schema.sql. Explicit dates keep exercises reproducible.
BEGIN;
INSERT INTO customers (customer_id,name,email,city,signup_date,active) VALUES
 (1,'Amina','amina@example.test','Dublin','2025-12-01',TRUE),
 (2,'Ben','ben@example.test','Cork','2025-12-03',TRUE),
 (3,'Clara','clara@example.test','Dublin','2025-12-10',TRUE),
 (4,'Diego','diego@example.test','Galway','2025-12-15',FALSE),
 (5,'Eli','eli@example.test',NULL,'2026-01-01',TRUE);
INSERT INTO products (product_id,product_name,category,price) VALUES
 (1,'Notebook','Stationery',8.00),
 (2,'Pen Set','Stationery',5.50),
 (3,'Desk Lamp','Home',30.00),
 (4,'Mug','Home',12.00),
 (5,'Backpack','Travel',40.00);
INSERT INTO orders (order_id,customer_id,order_date,status,created_at) VALUES
 (1,1,'2026-01-05','paid','2026-01-05 09:00:00+00'),
 (2,2,'2026-01-08','paid','2026-01-08 10:00:00+00'),
 (3,1,'2026-02-01','paid','2026-02-01 11:00:00+00'),
 (4,3,'2026-02-10','pending','2026-02-10 12:00:00+00'),
 (5,2,'2026-02-12','cancelled','2026-02-12 13:00:00+00'),
 (6,3,'2026-03-03','paid','2026-03-03 14:00:00+00');
INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES
 (1,1,2,8.00),(1,2,1,5.50),
 (2,3,1,30.00),(2,4,2,12.00),
 (3,3,1,28.00),(3,1,1,8.00),
 (4,4,1,12.00),(5,2,3,5.50),(6,3,3,26.00);
-- Explicit ID inserts do not advance identity sequences: align them now.
SELECT setval(pg_get_serial_sequence('customers','customer_id'),5,TRUE);
SELECT setval(pg_get_serial_sequence('products','product_id'),5,TRUE);
SELECT setval(pg_get_serial_sequence('orders','order_id'),6,TRUE);
COMMIT;
