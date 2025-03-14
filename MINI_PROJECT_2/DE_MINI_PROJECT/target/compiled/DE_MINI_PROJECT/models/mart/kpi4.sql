-- WITH monthly_revenue AS (
--     SELECT
--         DATE_TRUNC('MONTH', payment_date) AS month,
--         SUM(revenue) AS total_revenue
--     FROM
--         DE_MINI_PROJECT.staging.stg_transactions
--     WHERE
--         REVENUE_TYPE = 1
--     GROUP BY
--         month
-- )
-- SELECT
--     month,
--     total_revenue,
--     LAG(total_revenue) OVER (ORDER BY month) AS previous,
--     CASE 
--         WHEN LAG(total_revenue) OVER (ORDER BY month) > total_revenue THEN 
--             LAG(total_revenue) OVER (ORDER BY month) - total_revenue
--         ELSE 
--             0
--     END AS revenue_lost
-- FROM
--     monthly_revenue
-- ORDER BY
--     month
 

 WITH revenue_drop as(
    SELECT
    PRODUCT_ID,
    PAYMENT_DATE,
    REVENUE,
    LAG(REVENUE) OVER (PARTITION BY PRODUCT_ID ORDER BY PAYMENT_DATE) AS PREV_REVENUE
FROM DE_MINI_PROJECT.staging.stg_transactions
),
replace_null as(
    SELECT COALESCE(PREV_REVENUE,0) as Previous_Revenue,
    PRODUCT_ID,
    PAYMENT_DATE,
    PREV_REVENUE,
    REVENUE,
     FROM revenue_drop
)
    SELECT
    PRODUCT_ID,
    PAYMENT_DATE,
    SUM(Previous_Revenue) as Previous_Revenue,
    SUM(REVENUE) as Current_Revenue,
    SUM(Previous_Revenue) - SUM(REVENUE) as Revenue_Loss,
FROM replace_null
GROUP BY PRODUCT_ID,PAYMENT_DATE 
ORDER BY Revenue_Loss DESC