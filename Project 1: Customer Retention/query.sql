-- BASIC RETENTION METRICS

-- 1. Total Orders per Customer
SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS total_orders
FROM transactions
GROUP BY CustomerID
ORDER BY total_orders DESC;

-- 2. First & Last Purchase Date per Customer
SELECT CustomerID,
       MIN(InvoiceDate) AS first_purchase,
       MAX(InvoiceDate) AS last_purchase
FROM transactions
GROUP BY CustomerID;

-- 3. Customer Lifetime (days between first and last purchase)
SELECT CustomerID,
       DATEDIFF(DAY, MIN(InvoiceDate), MAX(InvoiceDate)) AS lifetime_days
FROM transactions
GROUP BY CustomerID;

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

-- RFM ANALYSIS (RECENCY, FREQUENCY, MONETARY)

-- Hitung RFM Score
WITH rfm AS (
  SELECT CustomerID,
         DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM transactions)) AS recency,
         COUNT(DISTINCT InvoiceNo) AS frequency,
         SUM(Quantity * UnitPrice) AS monetary
  FROM transactions
  GROUP BY CustomerID
)
SELECT CustomerID,
       NTILE(5) OVER (ORDER BY recency ASC) AS R_Score,
       NTILE(5) OVER (ORDER BY frequency DESC) AS F_Score,
       NTILE(5) OVER (ORDER BY monetary DESC) AS M_Score
FROM rfm;

-- REPEAT PURCHASE BEHAVIOUR 
-- 1. Persentase Customer yang Kembali Beli
WITH purchases AS (
  SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS orders
  FROM transactions
  GROUP BY CustomerID
)
SELECT SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS repeat_rate
FROM purchases;

-- 2. Waktu Rata-rata Antar Pembelian (Average Days Between Purchases)
WITH ordered_purchases AS (
  SELECT CustomerID,
         InvoiceDate,
         ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY InvoiceDate) AS rn
  FROM transactions
),
diffs AS (
  SELECT a.CustomerID,
         DATEDIFF(DAY, a.InvoiceDate, b.InvoiceDate) AS days_between
  FROM ordered_purchases a
  JOIN ordered_purchases b
  ON a.CustomerID = b.CustomerID AND a.rn + 1 = b.rn
)
SELECT CustomerID, AVG(days_between) AS avg_days_between
FROM diffs
GROUP BY CustomerID;





WITH monthly_users AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        customer_id
    FROM transactions
    GROUP BY 1, customer_id
),
retention AS (
    SELECT 
        curr.month,
        COUNT(DISTINCT curr.customer_id) AS active_users,
        COUNT(DISTINCT CASE WHEN next.customer_id IS NOT NULL THEN curr.customer_id END) AS retained_users
    FROM monthly_users curr
    LEFT JOIN monthly_users next
        ON curr.customer_id = next.customer_id
        AND next.month = curr.month + INTERVAL '1 month'
    GROUP BY curr.month
)
SELECT 
    month,
    active_users,
    retained_users,
    ROUND(retained_users::decimal / active_users * 100, 2) AS retention_rate
FROM retention
ORDER BY month;
