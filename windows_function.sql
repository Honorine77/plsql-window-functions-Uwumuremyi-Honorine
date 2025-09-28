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
    DATE_FORMAT(t.sale_date,'%Y-%m-01') AS month_start,
    SUM(t.amount) AS month_total
  FROM transactions t
  JOIN customers c ON t.customer_id = c.customer_id
  GROUP BY c.region, DATE_FORMAT(t.sale_date,'%Y-%m-01')
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
SELECT 
    c.name,
    SUM(t.amount) as total_spent,
    NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) as customer_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) = 1 THEN 'VIP Customer'
        WHEN NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) = 2 THEN 'High Value'
        WHEN NTILE(4) OVER (ORDER BY SUM(t.amount) DESC) = 3 THEN 'Medium Value'
        ELSE 'New Customer'
    END as customer_segment
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;



