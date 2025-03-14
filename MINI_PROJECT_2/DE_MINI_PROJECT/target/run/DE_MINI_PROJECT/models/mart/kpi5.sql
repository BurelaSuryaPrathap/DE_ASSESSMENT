
  
    

        create or replace transient table DE_MINI_PROJECT.mart.kpi5
         as
        (WITH first_payment AS (
    SELECT
        customer_id,
        MIN(payment_date) AS first_payment_date
    FROM
        DE_MINI_PROJECT.staging.stg_transactions
    GROUP BY
        customer_id
),
 
new_customers_by_fy AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM first_payment_date) AS fiscal_year
    FROM
        first_payment
)
 
SELECT
    fiscal_year,
    COUNT(DISTINCT customer_id) AS new_customers_count
FROM
    new_customers_by_fy
GROUP BY
    fiscal_year
ORDER BY
    fiscal_year
        );
      
  