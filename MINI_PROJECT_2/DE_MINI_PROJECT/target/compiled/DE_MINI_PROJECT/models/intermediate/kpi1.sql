-- WITH customer_activity AS (
--     SELECT 
--         CUSTOMER_ID,
--         DATE_TRUNC('MONTH', payment_month) AS transaction_month
--     FROM DE_MINI_PROJECT.staging.stg_transactions
--     GROUP BY CUSTOMER_ID, DATE_TRUNC('MONTH', payment_month)
-- ),
-- new_customers AS (
--     SELECT 
--         transaction_month,
--         COUNT(DISTINCT CUSTOMER_ID) AS new_customers_count
--     FROM customer_activity ca
--     WHERE transaction_month = (
--         SELECT MIN(transaction_month)
--         FROM customer_activity ca2
--         WHERE ca.CUSTOMER_ID = ca2.CUSTOMER_ID
--     )
--     GROUP BY transaction_month
-- ),
-- churned_customers AS (
--     SELECT 
--         ca.transaction_month,
--         COUNT(DISTINCT ca.CUSTOMER_ID) AS churned_customers_count
--     FROM customer_activity ca
--     LEFT JOIN customer_activity next_month_activity
--         ON ca.CUSTOMER_ID = next_month_activity.CUSTOMER_ID
--         AND DATEADD(MONTH, 3, ca.transaction_month) = next_month_activity.transaction_month
--     WHERE next_month_activity.CUSTOMER_ID IS NULL
--     GROUP BY ca.transaction_month
-- )
-- SELECT 
--     COALESCE(nc.transaction_month, cc.transaction_month) AS transaction_month,
--     COALESCE(nc.new_customers_count, 0) AS new_customers,
--     COALESCE(cc.churned_customers_count, 0) AS churned_customers
-- FROM new_customers nc
-- FULL OUTER JOIN churned_customers cc
--     ON nc.transaction_month = cc.transaction_month
-- ORDER BY transaction_month


WITH customers_data AS (
    SELECT
        payment_month,
        customer_id,
        MIN(payment_month) OVER (PARTITION BY customer_id) AS first_purchase_date,
        MAX(payment_month) OVER (PARTITION BY customer_id) AS last_purchase_date
    FROM DE_MINI_PROJECT.staging.stg_transactions  
    JOIN DE_MINI_PROJECT.staging.stg_customers USING (customer_id)
),
new_and_churned_customers AS (
    SELECT
        payment_month,
        COUNT(DISTINCT CASE WHEN first_purchase_date = payment_month THEN customer_id END) AS new_customers,
        COUNT(DISTINCT CASE WHEN last_purchase_date = payment_month AND first_purchase_date != last_purchase_date THEN customer_id END) AS churned_customers
    FROM customers_data
    GROUP BY payment_month
    ORDER BY payment_month
)
SELECT * FROM new_and_churned_customers