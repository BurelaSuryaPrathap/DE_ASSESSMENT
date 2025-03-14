WITH customer_revenue AS (
    SELECT 
        CUSTOMER_ID,
        SUM(revenue) AS total_revenue
    FROM DE_MINI_PROJECT.staging.stg_transactions
    GROUP BY CUSTOMER_ID
),
ranked_customers AS (
    SELECT 
        CUSTOMER_ID,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_revenue
)
SELECT 
    rc.CUSTOMER_ID,
    rc.total_revenue,
    rc.revenue_rank,
    cc.CUSTOMER_NAME
FROM ranked_customers rc
JOIN DE_MINI_PROJECT.staging.stg_customers cc
    ON rc.customer_id = cc.customer_id
ORDER BY revenue_rank