-- Top 3 salesperson per Region

WITH ranked AS (
  SELECT
    "Region",
    "Salesperson",
    SUM("Revenue") AS total_revenue,
    SUM("Profit") AS total_profit,
    ROW_NUMBER() OVER (PARTITION BY "Region" ORDER BY SUM("Revenue") DESC) AS rn
  FROM d2
  GROUP BY "Region", "Salesperson"
)
SELECT "Region", "Salesperson", total_revenue, total_profit
FROM ranked
WHERE rn <= 3
ORDER BY "Region", total_revenue DESC;

