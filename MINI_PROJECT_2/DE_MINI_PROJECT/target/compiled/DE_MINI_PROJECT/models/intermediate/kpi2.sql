WITH customer_product_activity AS (
    SELECT 
        t.CUSTOMER_ID,
        p.PRODUCT_FAMILY,
        DATE_TRUNC('MONTH', t.payment_month) AS transaction_month,
        COUNT(DISTINCT t.product_id) AS products_purchased
    FROM DE_MINI_PROJECT.staging.stg_transactions t
    JOIN DE_MINI_PROJECT.staging.stg_products p
        ON t.product_id = p.product_id
    GROUP BY t.CUSTOMER_ID, p.PRODUCT_FAMILY, DATE_TRUNC('MONTH', t.payment_month)
),
cross_sell_customers AS (
    SELECT 
        CUSTOMER_ID,
        COUNT(DISTINCT PRODUCT_FAMILY) AS product_families_purchased
    FROM customer_product_activity
    GROUP BY CUSTOMER_ID
    HAVING COUNT(DISTINCT PRODUCT_FAMILY) > 1 -- Customers who purchased from multiple product families
),
product_churn_customers AS (
    SELECT 
        cpa.CUSTOMER_ID,
        cpa.PRODUCT_FAMILY,
        MAX(cpa.transaction_month) AS last_purchase_month,
        COUNT(*) AS total_purchases
    FROM customer_product_activity cpa
    LEFT JOIN customer_product_activity next_month_activity
        ON cpa.CUSTOMER_ID = next_month_activity.CUSTOMER_ID
        AND cpa.PRODUCT_FAMILY = next_month_activity.PRODUCT_FAMILY
        AND DATEADD(MONTH, 1, cpa.transaction_month) = next_month_activity.transaction_month
    WHERE next_month_activity.CUSTOMER_ID IS NULL -- No purchases in the next month
    GROUP BY cpa.CUSTOMER_ID, cpa.PRODUCT_FAMILY
)
SELECT 
    csc.CUSTOMER_ID,
    csc.product_families_purchased,
    pcc.PRODUCT_FAMILY AS churned_product_family,
    pcc.last_purchase_month
FROM cross_sell_customers csc
LEFT JOIN product_churn_customers pcc
    ON csc.CUSTOMER_ID = pcc.CUSTOMER_ID
ORDER BY csc.product_families_purchased DESC, pcc.last_purchase_month DESC