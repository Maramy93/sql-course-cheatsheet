-- Run in sql_practice after schema + seed. Row/DDL changes are rolled back.
-- Identity sequence increments can persist even after rollback; gaps are normal.
BEGIN;
CREATE TEMP TABLE study_topics (
 topic_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 title text UNIQUE NOT NULL,
 priority integer NOT NULL DEFAULT 1 CHECK (priority BETWEEN 1 AND 5)
);
INSERT INTO study_topics (title,priority) VALUES ('Joins',3),('Windows',4) RETURNING *;
UPDATE study_topics SET priority=5 WHERE title='Windows' RETURNING *;
ALTER TABLE study_topics ADD COLUMN notes text;
DELETE FROM study_topics WHERE title='Joins' RETURNING *;
UPDATE customers SET city='Limerick' WHERE customer_id=5 RETURNING customer_id,city;
SAVEPOINT before_active_change;
UPDATE customers SET active=FALSE WHERE customer_id=5;
ROLLBACK TO SAVEPOINT before_active_change;
SELECT customer_id,city,active FROM customers WHERE customer_id=5;
ROLLBACK;
SELECT customer_id,city,active FROM customers WHERE customer_id=5;
