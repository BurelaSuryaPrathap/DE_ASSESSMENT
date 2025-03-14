
  
    

        create or replace transient table DE_MINI_PROJECT.staging.stg_country
         as
        (SELECT 
   customer_id,
   company,
   customername AS customer_name 
FROM 
DE_MINI_PROJECT.RAW.country_region
        );
      
  