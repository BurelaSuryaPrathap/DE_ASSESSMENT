WITH products_cleaning AS (
    SELECT DISTINCT 
         product_id,
         product_family, 
         product_sub_family 
    FROM {{ source('raw_data', 'products') }}
    WHERE product_id IS NOT NULL
      AND PRODUCT_Family IS NOT NULL
      AND product_sub_family IS NOT NULL
)
SELECT * FROM products_cleaning