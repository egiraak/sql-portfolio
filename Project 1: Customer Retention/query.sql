-- Customer Lifetime Value (CLV) PER CUSTOMER

SELECT 
    "CustomerID",
    ROUND(SUM("Quantity" * "UnitPrice"), 2) AS lifetime_value,
    COUNT(DISTINCT "InvoiceNo") AS total_orders,
    MAX(to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI')) AS last_order_date,
    MIN(to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI')) AS first_order_date
FROM d1
GROUP BY "CustomerID"
ORDER BY lifetime_value DESC
LIMIT 10;

-- COHORT ANALYSIS (MONTHLY RETENTION)

-- 1. Buat Cohort berdasarkan bulan first purchase
WITH first_purchase AS (
  SELECT 
    "CustomerID", 
    MIN(DATE_TRUNC('month', to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI')))::date AS cohort_month
  FROM d1
  GROUP BY "CustomerID"
),
customer_activity AS (
  SELECT 
    f.cohort_month,
    DATE_TRUNC('month', to_timestamp(t."InvoiceDate", 'MM/DD/YYYY HH24:MI'))::date AS activity_month,
    COUNT(DISTINCT t."CustomerID") AS active_customers
  FROM d1 t
  JOIN first_purchase f ON t."CustomerID" = f."CustomerID"
  GROUP BY f.cohort_month, DATE_TRUNC('month', to_timestamp(t."InvoiceDate", 'MM/DD/YYYY HH24:MI'))::date
),
with_offset AS (
  SELECT 
    cohort_month,
    activity_month,
    EXTRACT(YEAR FROM age(activity_month, cohort_month)) * 12
      + EXTRACT(MONTH FROM age(activity_month, cohort_month)) AS month_offset,
    active_customers
  FROM customer_activity
),
cohort_size AS (
  SELECT cohort_month, active_customers AS cohort_size
  FROM with_offset
  WHERE month_offset = 0
)

-- 2. Hitung Retention Rate per Cohort
SELECT 
  w.cohort_month,
  w.activity_month,
  w.month_offset,
  w.active_customers,
  ROUND((w.active_customers::decimal / c.cohort_size) * 100, 2) AS retention_rate
FROM with_offset w
JOIN cohort_size c USING (cohort_month)
ORDER BY w.cohort_month, w.activity_month;


-- RFM (Recency, Frequency, Monetary) ANALYSIS
WITH customer_summary AS (
    SELECT 
        "CustomerID",
        MAX(to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI')) AS last_purchase,
        COUNT(DISTINCT "InvoiceNo") AS frequency,
        SUM("Quantity" * "UnitPrice") AS monetary
    FROM d1
    GROUP BY "CustomerID"
),
rfm AS (
    SELECT
        "CustomerID",
        DATE_PART('day', CURRENT_DATE - last_purchase) AS recency,
        frequency,
        monetary
    FROM customer_summary
)
SELECT *,
    NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
FROM rfm;

--TOP 5 PRODUCTS PER MONTH (by Revenue)
WITH monthly_sales AS (
    SELECT 
        DATE(DATE_TRUNC('month', to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI'))) AS month,
        "Description",
        SUM("Quantity" * "UnitPrice") AS revenue
    FROM d1
    GROUP BY month, "Description"
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank
    FROM monthly_sales
)
SELECT month, "Description", revenue
FROM ranked
WHERE rank <= 5
ORDER BY month, revenue DESC;


-- REPEAT PURCHASE BEHAVIOUR 
-- 1. Persentase Customer yang Kembali Beli
WITH purchases AS (
  SELECT "CustomerID", COUNT(DISTINCT "InvoiceNo") AS orders
  FROM d1
  GROUP BY "CustomerID"
)
SELECT SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS repeat_rate
FROM purchases;

-- 2. Waktu Rata-rata Antar Pembelian (Average Days Between Purchases)
WITH ordered_purchases AS (
  SELECT "CustomerID",
         to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI') AS ts_invoice,
         ROW_NUMBER() OVER (
             PARTITION BY "CustomerID" 
             ORDER BY to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI')
         ) AS rn
  FROM d1
),
diffs AS (
  SELECT a."CustomerID",
         (b.ts_invoice::date - a.ts_invoice::date) AS days_between
  FROM ordered_purchases a
  JOIN ordered_purchases b
    ON a."CustomerID" = b."CustomerID" AND a.rn + 1 = b.rn
)
SELECT "CustomerID", ROUND(AVG(days_between)::numeric) AS avg_days_between
FROM diffs
GROUP BY "CustomerID";

-- SALES AND RETURN ANALYSIS
-- 1. Gross Sales, Returns, Net Sales (keseluruhan)
SELECT
    SUM(CASE WHEN "Quantity" > 0 THEN "Quantity" * "UnitPrice" ELSE 0 END) AS gross_sales,
    SUM(CASE WHEN "Quantity" < 0 THEN ABS("Quantity") * "UnitPrice" ELSE 0 END) AS returns,
    SUM("Quantity" * "UnitPrice") AS net_sales
FROM d1;



