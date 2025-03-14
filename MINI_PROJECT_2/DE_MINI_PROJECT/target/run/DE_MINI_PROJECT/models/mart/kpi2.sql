
  
    

        create or replace transient table DE_MINI_PROJECT.mart.kpi2
         as
        (WITH customer_product_activity AS (
    SELECT 
        t.CUSTOMER_ID,
        t.PRODUCT_ID,
        DATE_TRUNC('MONTH', t.payment_date) AS transaction_month
    FROM DE_MINI_PROJECT.staging.stg_transactions t
),
cross_sell_customers AS (
    SELECT 
        CUSTOMER_ID,
        COUNT(DISTINCT PRODUCT_ID) AS products_purchased
    FROM customer_product_activity
    GROUP BY CUSTOMER_ID
    HAVING COUNT(DISTINCT PRODUCT_ID) > 1 -- Customers who purchased multiple products
),
product_churn_customers AS (
    SELECT 
        cpa.CUSTOMER_ID,
        cpa.PRODUCT_ID,
        MAX(cpa.transaction_month) AS last_purchase_month,
        COUNT(*) AS total_purchases
    FROM customer_product_activity cpa
    LEFT JOIN customer_product_activity next_month_activity
        ON cpa.CUSTOMER_ID = next_month_activity.CUSTOMER_ID
        AND cpa.PRODUCT_ID = next_month_activity.PRODUCT_ID
        AND DATEADD(MONTH, 1, cpa.transaction_month) = next_month_activity.transaction_month
    WHERE next_month_activity.CUSTOMER_ID IS NULL -- No purchases in the next month
    GROUP BY cpa.CUSTOMER_ID, cpa.PRODUCT_ID
),
churned_products_count AS (
    SELECT 
        CUSTOMER_ID,
        COUNT(DISTINCT PRODUCT_ID) AS churned_products
    FROM product_churn_customers
    GROUP BY CUSTOMER_ID
)
SELECT 
    DISTINCT
    csc.CUSTOMER_ID,
    csc.products_purchased,
    COALESCE(cpc.churned_products, 0) AS churned_products,
    pcc.PRODUCT_ID AS churned_product_id,
    pcc.last_purchase_month
FROM cross_sell_customers csc
LEFT JOIN product_churn_customers pcc
    ON csc.CUSTOMER_ID = pcc.CUSTOMER_ID
LEFT JOIN churned_products_count cpc
    ON csc.CUSTOMER_ID = cpc.CUSTOMER_ID
ORDER BY csc.products_purchased DESC, pcc.last_purchase_month DESC
        );
      
  