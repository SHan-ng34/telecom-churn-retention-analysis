-- ============================================================
-- Customer Churn & Retention Economics
-- 04 - Statistical Analysis Preparation
-- ============================================================

-- Purpose:
-- Prepare datasets used for statistical analysis in Python.
--
-- Statistical tests themselves were performed using Python
-- (SciPy / Statsmodels), not PostgreSQL.
--
-- Results are observational and do not establish causation.


-- ============================================================
-- 1. Contract vs Churn
-- ============================================================

SELECT
    contract,
    churn,
    COUNT(*) AS customer_count
FROM customers
GROUP BY contract, churn
ORDER BY contract, churn;


-- ============================================================
-- 2. Payment Method vs Churn
-- ============================================================

SELECT
    payment_method,
    churn,
    COUNT(*) AS customer_count
FROM customers
GROUP BY payment_method, churn
ORDER BY payment_method, churn;


-- ============================================================
-- 3. Contract vs Tenure
--    Used to examine differences in average tenure
--    across contract types.
-- ============================================================

SELECT
    contract,
    COUNT(*) AS customers,
    ROUND(AVG(tenure), 2) AS average_tenure
FROM customers
GROUP BY contract
ORDER BY average_tenure;


-- ============================================================
-- 4. Logistic Regression Input Variables
-- ============================================================

-- The Python analysis uses:
--
--   tenure
--   monthly_charges
--   contract
--   payment_method
--   internet_service
--   tech_support
--
-- Customer ID and TotalCharges are excluded from the model
-- because they are not used as explanatory variables in the
-- final specification.
--
-- The full dataset is exported/loaded into Python for
-- categorical encoding and statistical modelling.


SELECT
    customer_id,
    churn,
    tenure,
    monthly_charges,
    contract,
    payment_method,
    internet_service,
    tech_support
FROM customers;