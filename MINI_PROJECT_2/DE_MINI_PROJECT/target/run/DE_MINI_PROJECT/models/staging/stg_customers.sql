
  
    

        create or replace transient table DE_MINI_PROJECT.staging.stg_customers
         as
        (WITH customers_cleaning AS (
    SELECT 
        DISTINCT
        CUSTOMER_ID,
        COMPANY,
        CUSTOMERNAME AS CUSTOMER_NAME
    FROM de_mini_project.raw.customers
    WHERE 
        CUSTOMER_ID IS NOT NULL
        AND COMPANY IS NOT NULL
        AND CUSTOMERNAME IS NOT NULL
)
SELECT 
    cc.CUSTOMER_ID, 
    cc.COMPANY,
    cc.CUSTOMER_NAME,
    cr.REGION, 
    cr.COUNTRY 
FROM customers_cleaning cc
JOIN DE_MINI_PROJECT.RAW.country_region cr
    ON cc.CUSTOMER_ID = cr.customer_id
        );
      
  