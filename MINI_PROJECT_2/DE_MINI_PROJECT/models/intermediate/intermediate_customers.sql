WITH intermediate_customers AS (
    SELECT 
        CUSTOMER_ID,
        COMPANY,
        CUSTOMER_NAME
    FROM {{ ref('stg_customers') }}
)
SELECT 
    c.CUSTOMER_ID,
    c.COMPANY,
    c.CUSTOMER_NAME,
    cr.COUNTRY,
    cr.REGION
FROM intermediate_customers c
JOIN {{ ref('country_region') }} cr
    ON c.CUSTOMER_ID = cr.customer_id
        