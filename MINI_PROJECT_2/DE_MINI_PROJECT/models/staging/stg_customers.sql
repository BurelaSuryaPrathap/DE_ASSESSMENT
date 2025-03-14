

WITH customers_cleaning AS (
    SELECT 
        DISTINCT
        CUSTOMER_ID,
        COMPANY,
        CUSTOMERNAME AS CUSTOMER_NAME
    FROM {{ source('raw_data', 'customers') }}
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
JOIN {{ ref('country_region') }} cr
    ON cc.CUSTOMER_ID = cr.customer_id