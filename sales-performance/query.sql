-- Top 3 Salesperson per Region

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

-- Contribution Margin per Product Category
SELECT
  "Product_Category",
  SUM("Revenue") AS revenue,
  SUM("Profit") AS profit,
  ROUND( (SUM("Profit") * 1.0) / NULLIF(SUM("Revenue"),0), 4)*100 AS profit_margin,
  ROUND(AVG("Discount_Percentage"),2) AS avg_discount
FROM d2
GROUP BY "Product_Category"
ORDER BY profit_margin DESC;

-- ROAS (Return on Ad Spend)
SELECT
  "Product_Category",
  SUM("Revenue") AS total_revenue,
  SUM("Marketing_Spend") AS total_marketing,
  ROUND(SUM("Revenue") * 100.0 / NULLIF(SUM("Marketing_Spend"),0), 2) AS roas_percent
FROM d2
GROUP BY "Product_Category"
HAVING SUM("Marketing_Spend") > 0
ORDER BY roas_percent DESC;

-- Discount Elasticity Proxy
WITH bands AS (
  SELECT *,
    CASE
      WHEN "Discount_Percentage" = 0 THEN 'no_discount'
      WHEN "Discount_Percentage" BETWEEN 0.01 AND 10 THEN 'low'
      WHEN "Discount_Percentage" BETWEEN 10.0001 AND 20 THEN 'medium'
      ELSE 'high'
    END AS discount_band
  FROM d2
)
SELECT
  discount_band,
  COUNT(*) AS orders,
  SUM("Revenue") AS revenue,
  SUM("Profit") AS profit,
  AVG("Units_Sold") AS avg_units
FROM bands
GROUP BY discount_band
ORDER BY revenue DESC;
