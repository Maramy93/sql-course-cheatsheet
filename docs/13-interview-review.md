# 13 · Interview review

[Home](../README.md) · [Quick syntax](../CHEATSHEET.md) · [Practice](../exercises/QUESTIONS.md)

## Explain these in your own words

| Question | A useful concise answer |
| --- | --- |
| SQL versus PostgreSQL? | SQL is a language; PostgreSQL is a DBMS that implements it with additional features. |
| Primary versus foreign key? | A PK uniquely identifies a row; an FK enforces a reference to an existing key. |
| WHERE versus HAVING? | WHERE filters input rows; HAVING filters grouped results. |
| COUNT(*) versus COUNT(x)? | COUNT(*) counts rows; COUNT(x) counts non-null x values. |
| INNER versus LEFT JOIN? | INNER keeps matches; LEFT also keeps unmatched left rows with NULL right fields. |
| UNION versus UNION ALL? | UNION deduplicates whole rows; UNION ALL preserves duplicates. |
| Subquery versus CTE? | Both express intermediate queries; a CTE names a result within a statement. |
| GROUP BY versus window? | GROUP BY collapses rows to groups; windows calculate while preserving rows. |
| RANK versus DENSE_RANK? | Both share ranks for ties; only RANK leaves gaps. |
| View versus materialized view? | A view stores a query definition; a materialized view stores its results until refreshed. |
| DELETE versus TRUNCATE versus DROP? | Remove selected rows / empty the table / remove the table definition. |
| What is normalization? | Organize related facts to reduce redundancy and update anomalies. |
| What is an index? | An access structure that may speed reads at storage/write cost. |
| What is ACID? | Atomicity, consistency, isolation, durability for transactions. |
| How do you prevent SQL injection? | Parameterize values; safely compose identifiers; use appropriate privileges. |
| Why can a join inflate revenue? | Several matches duplicate input facts before aggregation; establish grain first. |

## How to approach a SQL task

1. Clarify the result grain: one row per customer, order, month, or item?
2. Clarify business meaning: paid only? Include customers with zero purchases? What time zone?
3. Identify keys and relationship cardinality before joining.
4. Filter the relevant base rows, then aggregate at the intended grain.
5. Decide NULL handling and tie policy explicitly.
6. Add deterministic ordering if the result needs top-N/pagination.
7. Check one case by hand and compare totals or counts before discussing performance.

For “top three customers,” ask whether ties at third place must be included. ROW_NUMBER gives exactly three rows when enough exist; DENSE_RANK includes everyone at the top three distinct totals.

## Classic mistakes to spot

- `column = NULL` instead of `IS NULL`.
- NOT IN with a NULL in its list/subquery.
- COUNT(*) after LEFT JOIN when counting matched orders.
- A joined-side WHERE condition removing unmatched outer rows.
- SUM of already-duplicated parent facts after a one-to-many join.
- AVG of item rows when asked for average order value.
- Using current product price instead of historical sale price.
- GROUP BY month number without year.
- BETWEEN timestamps ending at midnight of the final day.
- Integer division producing a truncated ratio.
- LIMIT without ORDER BY or without a stable tie-breaker.
- Selecting a non-grouped, non-aggregate expression.
- Assuming a CTE is always cached or always faster.
- Assuming every indexed query should use an index on a tiny table.
- Updating all rows by forgetting WHERE.

## Worked reasoning: customers with zero paid revenue

Start with customers to preserve everyone. Filter paid status in ON, join the matching items, sum item revenue, then COALESCE the missing sum.

```sql
SELECT c.customer_id, c.name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS paid_revenue
FROM customers c
LEFT JOIN orders o
 ON o.customer_id = c.customer_id AND o.status = 'paid'
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.name
ORDER BY paid_revenue DESC, c.customer_id;
```

Clara 78, Amina 57.50, Ben 54, Diego 0, Eli 0. COUNT(DISTINCT o.order_id) would count paid orders at this joined item grain; COUNT(o.order_id) would count item rows.

## 30-minute interview refresher

| Minutes | Review task |
| --- | --- |
| 0–5 | Definitions and logical query order |
| 5–10 | NULL, filters, WHERE/HAVING |
| 10–17 | Join preservation, cardinality, anti joins |
| 17–24 | CTEs, second-highest value, windows and ties |
| 24–30 | Transactions, constraints, indexes, parameterization |

## Longer-term review

First pass: build the database and run each chapter. Next day: solve filtering/aggregation tasks without notes. After a week: solve joins and window tasks. After a month: explain the classic mistakes aloud and add a new original dataset/query of your own. Keep dates and lessons in `my-notes/`.

This repo is a review aid, not evidence of professional experience on its own. Be ready to explain the queries and their assumptions during an interview.
