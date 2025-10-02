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


SELECT
  "Product_Category",
  SUM("Revenue") AS revenue,
  SUM("Profit") AS profit,
  ROUND( (SUM("Profit") * 1.0) / NULLIF(SUM("Revenue"),0), 4)*100 AS profit_margin,
  ROUND(AVG("Discount_Percentage"),2) AS avg_discount
FROM d2
GROUP BY "Product_Category"
ORDER BY profit_margin DESC;
