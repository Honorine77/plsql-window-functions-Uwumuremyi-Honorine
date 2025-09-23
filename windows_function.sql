--- RANKING
WITH cust_totals AS (
  SELECT customer_id,
         SUM(amount) AS total_revenue
  FROM transactions
  GROUP BY customer_id
)
SELECT customer_id,
       total_revenue,
       ROW_NUMBER() OVER (ORDER BY total_revenue DESC)   AS row_num,
       RANK() OVER (ORDER BY total_revenue DESC)         AS rnk,
       DENSE_RANK() OVER (ORDER BY total_revenue DESC)   AS dense_rnk,
       PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS pct_rank
FROM cust_totals
ORDER BY total_revenue DESC;

--- AGGREGATE 
WITH monthly AS (
  SELECT
    c.region,
    TRUNC(t.sale_date,'MM') AS month_start,
    SUM(t.amount) AS month_total
  FROM transactions t
  JOIN customers c ON t.customer_id = c.customer_id
  GROUP BY c.region, TRUNC(t.sale_date,'MM')
)
SELECT
  region,
  month_start,
  month_total,
  SUM(month_total) OVER (
    PARTITION BY region
    ORDER BY month_start
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_rows,
  SUM(month_total) OVER (
    PARTITION BY region
    ORDER BY month_start
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_range
FROM monthly
ORDER BY region, month_start;
--- MONTH OVER MONTH
WITH monthly AS (
  SELECT
    c.region,
    TRUNC(t.sale_date,'MM') AS month_start,
    SUM(t.amount) AS month_total
  FROM transactions t
  JOIN customers c ON t.customer_id = c.customer_id
  GROUP BY c.region, TRUNC(t.sale_date,'MM')
)
SELECT
  region,
  month_start,
  month_total,
  LAG(month_total) OVER (PARTITION BY region ORDER BY month_start) AS prev_month_total,
  -- calculate % change safely (avoid divide by zero)
  CASE
    WHEN LAG(month_total) OVER (PARTITION BY region ORDER BY month_start) IS NULL THEN NULL
    WHEN LAG(month_total) OVER (PARTITION BY region ORDER BY month_start) = 0 THEN NULL
    ELSE ROUND(
      (month_total - LAG(month_total) OVER (PARTITION BY region ORDER BY month_start))
      / LAG(month_total) OVER (PARTITION BY region ORDER BY month_start) * 100, 2)
  END AS pct_change_mom
FROM monthly
ORDER BY region, month_start;
--- DISTRIBUTION
WITH cust_totals AS (
  SELECT customer_id, SUM(amount) AS total_revenue
  FROM transactions
  GROUP BY customer_id
)
SELECT
  customer_id,
  total_revenue,
  NTILE(4) OVER (ORDER BY total_revenue DESC) AS quartile,  -- 1 = top 25%
  CUME_DIST() OVER (ORDER BY total_revenue DESC) AS cume_dist
FROM cust_totals
ORDER BY total_revenue DESC;



