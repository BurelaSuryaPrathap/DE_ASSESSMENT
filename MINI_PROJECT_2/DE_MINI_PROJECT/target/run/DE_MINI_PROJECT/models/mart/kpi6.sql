
  
    

        create or replace transient table DE_MINI_PROJECT.mart.kpi6
         as
        (WITH product_revenue AS (
    SELECT 
        p.PRODUCT_ID,
        SUM(t.revenue) AS total_products_revenue
    FROM DE_MINI_PROJECT.staging.stg_transactions t
    JOIN DE_MINI_PROJECT.staging.stg_products p 
        ON t.product_id = p.product_id
    GROUP BY p.PRODUCT_ID
),
ranked_products AS (
    SELECT 
        PRODUCT_ID,
        total_products_revenue,
        DENSE_RANK() OVER (ORDER BY total_products_revenue DESC) AS revenue_rank
    FROM product_revenue
)
SELECT * 
FROM ranked_products
ORDER BY revenue_rank

















-- WITH product_revenue AS (
--     SELECT 
--         PRODUCT_ID, 
--         SUM(revenue) AS total_products_revenue
--     FROM DE_MINI_PROJECT.staging.stg_transactions
--     GROUP BY PRODUCT_ID
-- ),
-- ranked_products AS (
--     SELECT 
--         PRODUCT_ID,
--         total_products_revenue,
--         DENSE_RANK() OVER (ORDER BY total_products_revenue DESC) AS revenue_rank
--     FROM product_revenue
-- )
-- SELECT 
--     rc.PRODUCT_ID,
--     rp.PRODUCT_FAMILY,
--     rc.total_products_revenue,
--     rc.revenue_rank
-- FROM ranked_products rc
-- JOIN PRODUCT_REVENUE rp
--     ON rc.product_id = rp.product_id
-- ORDER BY revenue_rank


-- WITH int_rank_products AS(
-- SELECT
--     p.product_id,
--     SUM(t.revenue) AS total_revenue,
--     RANK() OVER(ORDER BY SUM(t.revenue) DESC) AS rank
-- FROM
--     DE_MINI_PROJECT.staging.stg_transactions t
-- JOIN
--     DE_MINI_PROJECT.staging.stg_products p ON t.product_id = p.product_id
-- GROUP BY
--     p.product_id
-- ORDER BY
--     total_revenue DESC
-- )
-- SELECT * FROM int_rank_products
        );
      
  