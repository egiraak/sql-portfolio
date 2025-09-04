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
