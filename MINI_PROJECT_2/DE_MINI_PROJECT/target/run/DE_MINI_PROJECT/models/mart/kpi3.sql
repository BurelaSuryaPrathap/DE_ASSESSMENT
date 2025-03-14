
  
    

        create or replace transient table DE_MINI_PROJECT.mart.kpi3
         as
        (WITH BASE AS (
    SELECT
        t.CUSTOMER_ID,
        c.CUSTOMER_NAME, -- Join with stg_customers to get CUSTOMER_NAME
        t.PAYMENT_DATE,
        DATEADD(month, -3, t.PAYMENT_DATE) AS PREVIOUS_MONTH,
        COUNT(DISTINCT t.PRODUCT_ID) AS NO_OF_PRODUCTS,
        SUM(t.revenue) AS TOTAL_REVENUE -- Replace TOTAL_REVENUE with revenue or appropriate calculation
    FROM DE_MINI_PROJECT.staging.stg_transactions t
    JOIN DE_MINI_PROJECT.staging.stg_customers c -- Join with stg_customers
        ON t.CUSTOMER_ID = c.CUSTOMER_ID
    GROUP BY
        t.CUSTOMER_ID,
        c.CUSTOMER_NAME,
        t.PAYMENT_DATE
), BASE2 AS (
    SELECT
        CUSTOMER_ID,
        PAYMENT_DATE,
        COUNT(PRODUCT_ID) AS NO_OF_PRODUCTS,
        SUM(revenue) AS TOTAL_REVENUE -- Replace TOTAL_REVENUE with revenue or appropriate calculation
    FROM DE_MINI_PROJECT.staging.stg_transactions
    GROUP BY
        CUSTOMER_ID,
        PAYMENT_DATE
), max_payment_month AS (
    SELECT
        MAX(PAYMENT_DATE) AS max_payment_month
    FROM DE_MINI_PROJECT.staging.stg_transactions
), product_churn AS (
    SELECT
        c.CUSTOMER_NAME,
        COUNT(DISTINCT CASE WHEN t.PAYMENT_DATE < DATEADD(MONTH, -3, max_payment_month) THEN t.PRODUCT_ID END) AS Product_Churn
    FROM DE_MINI_PROJECT.staging.stg_transactions t
    JOIN DE_MINI_PROJECT.staging.stg_customers c -- Join with stg_customers
        ON t.CUSTOMER_ID = c.CUSTOMER_ID
    JOIN max_payment_month ON 1=1
    GROUP BY
        c.CUSTOMER_NAME
), FINAL AS (
    SELECT
        BASE.CUSTOMER_NAME,
        BASE.CUSTOMER_ID,
        BASE.PAYMENT_DATE,
        BASE.NO_OF_PRODUCTS,
        BASE.TOTAL_REVENUE,
        BASE.PREVIOUS_MONTH,
        BASE2.TOTAL_REVENUE AS PREVIOUS_MONTH_REVENUE,
        BASE2.NO_OF_PRODUCTS AS NO_OF_PRODUCTS_PAST_MONTH,
        Product_Churn
    FROM BASE
    LEFT JOIN BASE2
        ON BASE.CUSTOMER_ID = BASE2.CUSTOMER_ID
        AND BASE.PREVIOUS_MONTH = BASE2.PAYMENT_DATE
    LEFT JOIN product_churn
        ON BASE.CUSTOMER_NAME = product_churn.CUSTOMER_NAME
), FINAL2 AS (
    SELECT
        CUSTOMER_ID,
        CUSTOMER_NAME,
        PAYMENT_DATE,
        NO_OF_PRODUCTS,
        TOTAL_REVENUE,
        PREVIOUS_MONTH,
        PREVIOUS_MONTH_REVENUE,
        NO_OF_PRODUCTS_PAST_MONTH,
        CASE
            WHEN (NO_OF_PRODUCTS - (NO_OF_PRODUCTS_PAST_MONTH - Product_Churn)) > 0 THEN (NO_OF_PRODUCTS - (NO_OF_PRODUCTS_PAST_MONTH - Product_Churn))
            ELSE 0
        END AS CROSS_SELL_IN_PRODUCTS,
        CASE
            WHEN (NO_OF_PRODUCTS - (NO_OF_PRODUCTS_PAST_MONTH - Product_Churn)) > 0 THEN (TOTAL_REVENUE - PREVIOUS_MONTH_REVENUE)
            ELSE 0
        END AS CROSS_SELL_IN_REVENUE,
        Product_Churn AS PRODUCT_CHURN
    FROM FINAL
), FINAL3 AS (
    SELECT
        *,
        RANK() OVER (ORDER BY CROSS_SELL_IN_REVENUE DESC) AS CROSS_SELL_RANK,
        RANK() OVER (ORDER BY PRODUCT_CHURN DESC) AS PRODUCT_CHURN_RANK
    FROM FINAL2
)
SELECT
    *
FROM
    FINAL3
ORDER BY CROSS_SELL_RANK, PRODUCT_CHURN_RANK
        );
      
  