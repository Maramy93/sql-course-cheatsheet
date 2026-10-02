# 11 · Window functions for interviews and analysis

[Home](../README.md) · [Next: performance and Python](12-performance-and-python.md)

This chapter extends the supplied outline. A **window function** calculates across related rows while preserving the individual rows. GROUP BY collapses rows; a window adds a result alongside them.

General form: `function(...) OVER (PARTITION BY ... ORDER BY ... frame)`.

- PARTITION BY divides rows into independent groups; omit it for one whole-result partition.
- Window ORDER BY controls the calculation order, not necessarily final display order.
- A frame specifies which rows contribute to a frame-sensitive calculation.

## Compare each product with its category average

```sql
SELECT product_name, category, price,
 ROUND(AVG(price) OVER (PARTITION BY category), 2) AS category_average
FROM products ORDER BY product_id;
```

Five rows remain. Category means: Stationery 6.75, Home 21, Travel 40.

## Ranking and ties

| Function | Ties | Values for prices 30, 30, 12 |
| --- | --- | --- |
| ROW_NUMBER | Assigns distinct numbers | 1, 2, 3 (tie order needs a tiebreaker) |
| RANK | Same rank; leaves gaps | 1, 1, 3 |
| DENSE_RANK | Same rank; no gaps | 1, 1, 2 |

```sql
SELECT product_name, price,
 ROW_NUMBER() OVER (ORDER BY price DESC, product_id) AS row_num,
 RANK() OVER (ORDER BY price DESC) AS price_rank,
 DENSE_RANK() OVER (ORDER BY price DESC) AS dense_price_rank
FROM products ORDER BY price DESC, product_id;
```

The shop's current prices are distinct, so all three happen to produce 1 through 5. Adding product_id to RANK's ORDER BY would make equal prices no longer peers; include it only in ROW_NUMBER if you need to preserve price ties for the other functions.

## Top product per category

```sql
WITH ranked AS (
 SELECT product_id, product_name, category, price,
        ROW_NUMBER() OVER (
          PARTITION BY category ORDER BY price DESC, product_id
        ) AS rn
 FROM products
)
SELECT category, product_name, price FROM ranked
WHERE rn = 1 ORDER BY category;
```

Result: Home Desk Lamp 30, Stationery Notebook 8, Travel Backpack 40. Use DENSE_RANK on price alone instead if the requirement is “all products tied for top price.” You cannot filter a window output in the same SELECT's WHERE; use an outer query/CTE.

## Running paid revenue

```sql
WITH totals AS (
 SELECT o.order_id, o.order_date, SUM(oi.quantity * oi.unit_price) AS total
 FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
 WHERE o.status = 'paid'
 GROUP BY o.order_id, o.order_date
)
SELECT order_id, total,
 SUM(total) OVER (
  ORDER BY order_date, order_id
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
 ) AS running_revenue
FROM totals ORDER BY order_date, order_id;
```

| order_id | total | running_revenue |
| --- | --- | --- |
| 1 | 21.50 | 21.50 |
| 2 | 54.00 | 75.50 |
| 3 | 36.00 | 111.50 |
| 6 | 78.00 | 189.50 |

Use an explicit ROWS frame to make the row-by-row intention clear. With ORDER BY, a default RANGE frame includes peers of the current row; tied sort values can produce the same cumulative value for several rows. GROUP BY the orders first so the window runs at order grain.

## LAG and LEAD

```sql
SELECT order_id, customer_id, order_date,
       LAG(order_date) OVER (
        PARTITION BY customer_id ORDER BY order_date, order_id
       ) AS previous_order_date
FROM orders ORDER BY customer_id, order_date, order_id;
```

LAG looks at a preceding row; LEAD looks ahead. First row in each customer's partition has no previous row and returns NULL. Add a numeric offset and optional default as second/third arguments when needed.

For this data Amina's second order follows 2026-01-05, Ben's second follows 2026-01-08, Clara's second follows 2026-02-10. This example includes **all** statuses; add a paid filter if that's the required definition.

## Second-highest distinct price

```sql
WITH ranked AS (
 SELECT product_name, price,
 DENSE_RANK() OVER (ORDER BY price DESC) AS price_rank
 FROM products
)
SELECT product_name, price FROM ranked WHERE price_rank = 2;
```

Desk Lamp 30. This finds the second distinct price, including any ties. `ORDER BY price DESC LIMIT 1 OFFSET 1` finds the second row, which is different when top prices tie.

**Try it:** calculate each paid order's percentage of total paid revenue. Use `100.0 * total / SUM(total) OVER ()`, after aggregating to paid order grain.

Reference: [window tutorial](https://www.postgresql.org/docs/current/tutorial-window.html).
