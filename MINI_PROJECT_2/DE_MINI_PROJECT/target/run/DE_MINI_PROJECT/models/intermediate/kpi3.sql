
  
    

        create or replace transient table DE_MINI_PROJECT.intermediate.kpi3
         as
        (WITH customer_revenue AS (
    SELECT 
        CUSTOMER_ID,
        DATE_TRUNC('MONTH', payment_month) AS transaction_month,
        SUM(revenue) AS total_revenue
    FROM DE_MINI_PROJECT.staging.stg_transactions
    GROUP BY CUSTOMER_ID, DATE_TRUNC('MONTH', payment_month)
),
existing_customers_revenue AS (
    SELECT 
        cr.transaction_month,
        cr.CUSTOMER_ID,
        cr.total_revenue AS current_revenue,
        COALESCE(lm.total_revenue, 0) AS last_month_revenue
    FROM customer_revenue cr
    LEFT JOIN customer_revenue lm
        ON cr.CUSTOMER_ID = lm.CUSTOMER_ID
        AND cr.transaction_month = DATEADD(MONTH, 1, lm.transaction_month)
),
nrr_grr_last_month AS (
    SELECT 
        transaction_month,
        SUM(last_month_revenue) AS total_last_month_revenue,
        SUM(current_revenue) AS total_current_revenue,
        SUM(CASE 
            WHEN current_revenue < last_month_revenue THEN current_revenue
            ELSE last_month_revenue
        END) AS total_grr_revenue -- Revenue excluding upsells
    FROM existing_customers_revenue
    GROUP BY transaction_month
),
nrr_grr_ltm AS (
    SELECT 
        DATE_TRUNC('YEAR', transaction_month) AS fiscal_year,
        SUM(last_month_revenue) AS total_last_month_revenue,
        SUM(current_revenue) AS total_current_revenue,
        SUM(CASE 
            WHEN current_revenue < last_month_revenue THEN current_revenue
            ELSE last_month_revenue
        END) AS total_grr_revenue
    FROM existing_customers_revenue
    WHERE transaction_month >= DATEADD(MONTH, -12, CURRENT_DATE) -- Last 12 months
    GROUP BY DATE_TRUNC('YEAR', transaction_month)
),
final_nrr_grr AS (
    SELECT 
        'Last Month' AS period_type,
        transaction_month AS period,
        CASE 
            WHEN total_last_month_revenue > 0 THEN ROUND((total_current_revenue / total_last_month_revenue) * 100, 2)
            ELSE 0
        END AS NRR,
        CASE 
            WHEN total_last_month_revenue > 0 THEN ROUND((total_grr_revenue / total_last_month_revenue) * 100, 2)
            ELSE 0
        END AS GRR
    FROM nrr_grr_last_month
    UNION ALL
    SELECT 
        'Last 12 Months (LTM)' AS period_type,
        fiscal_year AS period,
        CASE 
            WHEN total_last_month_revenue > 0 THEN ROUND((total_current_revenue / total_last_month_revenue) * 100, 2)
            ELSE 0
        END AS NRR,
        CASE 
            WHEN total_last_month_revenue > 0 THEN ROUND((total_grr_revenue / total_last_month_revenue) * 100, 2)
            ELSE 0
        END AS GRR
    FROM nrr_grr_ltm
)
SELECT 
    period_type,
    period,
    NRR,
    GRR
FROM final_nrr_grr
ORDER BY period_type, period
        );
      
  