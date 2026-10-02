# Original SQL practice challenges

[Home](../README.md) · [Worked solutions](SOLUTIONS.md)

Load the original schema and seed first. Do not change the seed before doing these challenges. Revenue always means paid orders only unless a question explicitly says otherwise. Give stable output ordering where practical.

| # | Level | Task | Expected check |
| --- | --- | --- | --- |
| 1 | Basic | List active Dublin customers, newest signup first | Clara, Amina |
| 2 | Basic | Find the two most expensive current products | Backpack 40, Desk Lamp 30 |
| 3 | Basic | Count all customers, known cities, distinct known cities | 5 / 4 / 3 |
| 4 | Basic | List February 2026 order IDs, all statuses | 3, 4, 5 |
| 5 | Aggregate | Find categories with average current price above 15 | Home 21, Travel 40 |
| 6 | Join | Count each customer's orders, including zero | 2, 2, 2, 0, 0 by customer ID |
| 7 | Join | Find customers with no orders | Diego, Eli |
| 8 | Join | Find products never ordered in any status | Backpack |
| 9 | Analysis | Calculate total paid revenue | 189.50 |
| 10 | Analysis | Calculate paid revenue for every customer, including zero | Clara 78; Amina 57.50; Ben 54; Diego/Eli 0 |
| 11 | Analysis | Calculate average paid order value | 47.38 rounded |
| 12 | Dates | Calculate paid revenue by calendar month including year | Jan 75.50; Feb 36; Mar 78 |
| 13 | Window | Find the most expensive product in each category; break ties by ID | Desk Lamp, Notebook, Backpack |
| 14 | Window | Find the second-highest distinct current price and its products | Desk Lamp 30 |
| 15 | Window | Calculate running paid revenue in order date/ID order | 21.50, 75.50, 111.50, 189.50 |

## Follow-up interview questions

- For #6, why does COUNT(*) give the wrong zero-order counts after a LEFT JOIN?
- For #10, where must the paid filter go to keep zero-revenue customers?
- For #11, why does AVG(quantity * unit_price) answer a different question?
- For #12, how would you include months with no orders? Build a calendar relation (e.g. generate_series in PostgreSQL), then LEFT JOIN monthly aggregates and COALESCE absent totals.
- For #13, how would you return all top-price ties? DENSE_RANK ordered by price alone.
- For #14, when is OFFSET 1 wrong? When the maximum price is repeated.
- For #15, why aggregate to order grain before calculating the running total?

After solving, compare with the solutions and run `tests/verify.sql`. Try writing alternative queries with equivalent results.
