
  
    

        create or replace transient table DE_MINI_PROJECT.staging.stg_products
         as
        (WITH products_cleaning AS (
    SELECT DISTINCT 
         product_id,
         product_family, 
         product_sub_family 
    FROM de_mini_project.raw.products
    WHERE product_id IS NOT NULL
      AND PRODUCT_Family IS NOT NULL
      AND product_sub_family IS NOT NULL
)
SELECT * FROM products_cleaning
        );
      
  