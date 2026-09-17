-- ============================================================
-- Customer Churn & Retention Economics
-- 01 - Core Churn Analysis
-- ============================================================

-- Assumptions:
--   churn = "Yes" indicates a churned customer.
--   churn = "No" indicates an active customer.
--   Monthly Charges represent recurring monthly revenue.
--
-- Note:
--   This analysis is observational. Results describe associations
--   with observed churn and do not establish causation.


-- ============================================================
-- 1. Overall Customer Churn
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers;


-- ============================================================
-- 2. Churn by Contract Type
-- ============================================================

SELECT
    contract,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY contract
ORDER BY churn_rate DESC;


-- ============================================================
-- 3. Churn by Tenure Group
-- ============================================================

SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END AS tenure_group,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END
ORDER BY
    MIN(tenure);


-- ============================================================
-- 4. Churn by Payment Method
-- ============================================================

SELECT
    payment_method,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY payment_method
ORDER BY churn_rate DESC;


-- ============================================================
-- 5. Churn by Monthly Charge Segment
--    Median monthly charge used as the split point.
-- ============================================================

WITH median_charge AS (
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY monthly_charges) AS median_monthly_charge
    FROM customers
)

SELECT
    CASE
        WHEN c.monthly_charges < m.median_monthly_charge
            THEN 'Below median'
        ELSE 'At/above median'
    END AS charge_segment,
    COUNT(*) AS customers,
    SUM(CASE WHEN c.churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN c.churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers c
CROSS JOIN median_charge m
GROUP BY
    CASE
        WHEN c.monthly_charges < m.median_monthly_charge
            THEN 'Below median'
        ELSE 'At/above median'
    END
ORDER BY churn_rate DESC;