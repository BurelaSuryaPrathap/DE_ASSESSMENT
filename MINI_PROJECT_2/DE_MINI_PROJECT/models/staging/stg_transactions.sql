WITH transaction_cleaning AS (
    SELECT DISTINCT 
    CUSTOMER_ID,
    product_id,
    payment_month AS payment_date,
    revenue_type,
    revenue,
    quantity
    FROM {{ source('raw_data', 'transactions') }}
    WHERE CUSTOMER_ID IS NOT NULL
      AND product_id IS NOT NULL
      AND payment_date IS NOT NULL
      AND revenue_type IS NOT NULL
      AND revenue IS NOT NULL
      AND quantity IS NOT NULL
      AND dimension_1 IS NOT NULL
      AND dimension_2 IS NOT NULL
      AND dimension_3 IS NOT NULL
      AND dimension_4 IS NOT NULL
      AND dimension_5 IS NOT NULL
      AND dimension_6 IS NOT NULL
      AND dimension_7 IS NOT NULL
      AND dimension_8 IS NOT NULL
      AND dimension_9 IS NOT NULL
      AND dimension_10 IS NOT NULL
      AND companies IS NOT NULL
)
SELECT * FROM transaction_cleaning