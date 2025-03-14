
  
    

        create or replace transient table DE_MINI_PROJECT.mart.kpi1
         as
        (WITH customers_data AS (
    SELECT
        payment_date,
        customer_id,
        MIN(payment_date) OVER (PARTITION BY customer_id) AS first_purchase_date,
        MAX(payment_date) OVER (PARTITION BY customer_id) AS last_purchase_date
    FROM DE_MINI_PROJECT.staging.stg_transactions  
    JOIN DE_MINI_PROJECT.staging.stg_customers USING (customer_id)
),
new_and_churned_customers AS (
    SELECT
        payment_date,
        COUNT(DISTINCT CASE WHEN first_purchase_date = payment_date THEN customer_id END) AS new_customers,
        COUNT(DISTINCT CASE WHEN last_purchase_date = payment_date AND first_purchase_date != last_purchase_date THEN customer_id END) AS churned_customers
    FROM customers_data
    GROUP BY payment_date
    ORDER BY payment_date
)
SELECT * FROM new_and_churned_customers
        );
      
  