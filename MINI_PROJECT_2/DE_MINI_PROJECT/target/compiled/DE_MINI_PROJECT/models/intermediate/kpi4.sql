WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('MONTH', payment_date) AS month,
        SUM(revenue) AS total_revenue
    FROM
        DE_MINI_PROJECT.staging.stg_transactions
    WHERE
        REVENUE_TYPE = 1
    GROUP BY
        month
)
SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS previous,
    CASE 
        WHEN LAG(total_revenue) OVER (ORDER BY month) > total_revenue THEN 
            LAG(total_revenue) OVER (ORDER BY month) - total_revenue
        ELSE 
            0
    END AS revenue_lost
FROM
    monthly_revenue
-- WHERE
--     revenue_lost > 0
ORDER BY
    month