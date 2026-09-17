-- ============================================================
-- Customer Churn & Retention Economics
-- 03 - Segment Analysis
-- ============================================================

-- Purpose:
-- Examine combinations of customer characteristics to identify
-- concentrated churn and revenue exposure.
--
-- Analytical principle:
-- Segment size and economic exposure are considered alongside
-- churn rate. A high percentage alone does not necessarily
-- represent the largest business opportunity.
--
-- Results are observational and do not establish causation.


-- ============================================================
-- 1. Month-to-Month + Payment Method
-- ============================================================

SELECT
    payment_method,
    COUNT(*) AS customers,

    SUM(
        CASE
            WHEN churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk

FROM customers
WHERE contract = 'Month-to-month'
GROUP BY payment_method
ORDER BY churn_rate DESC;


-- ============================================================
-- 2. Month-to-Month + Tenure Group
-- ============================================================

SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END AS tenure_group,

    COUNT(*) AS customers,

    SUM(
        CASE
            WHEN churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk

FROM customers
WHERE contract = 'Month-to-month'

GROUP BY
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END

ORDER BY MIN(tenure);


-- ============================================================
-- 3. Month-to-Month + Electronic Check
-- ============================================================

SELECT
    COUNT(*) AS customers,

    SUM(
        CASE
            WHEN churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk

FROM customers
WHERE contract = 'Month-to-month'
  AND payment_method = 'Electronic check';


-- ============================================================
-- 4. Priority Segment
--    Month-to-Month + Electronic Check + 0-12 Months
-- ============================================================

SELECT
    COUNT(*) AS customers,

    SUM(
        CASE
            WHEN churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS historical_revenue_at_risk,

    SUM(
        CASE
            WHEN churn = 'No' THEN 1
            ELSE 0
        END
    ) AS active_customers,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'No' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS active_monthly_revenue_exposure,

    ROUND(
        AVG(monthly_charges),
        2
    ) AS average_monthly_charge

FROM customers
WHERE contract = 'Month-to-month'
  AND payment_method = 'Electronic check'
  AND tenure <= 12;


-- ============================================================
-- 5. Priority Segment — Active Customers Only
-- ============================================================

SELECT
    COUNT(*) AS active_customers,

    ROUND(
        SUM(monthly_charges),
        2
    ) AS active_monthly_revenue_exposure,

    ROUND(
        AVG(monthly_charges),
        2
    ) AS average_monthly_charge

FROM customers
WHERE churn = 'No'
  AND contract = 'Month-to-month'
  AND payment_method = 'Electronic check'
  AND tenure <= 12;


-- ============================================================
-- 6. High Monthly Charge Segment
--    Median split used as an economic lens
-- ============================================================

WITH median_charge AS (
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY monthly_charges)
        AS median_monthly_charge
    FROM customers
)

SELECT
    CASE
        WHEN c.monthly_charges < m.median_monthly_charge
            THEN 'Below median'
        ELSE 'At/above median'
    END AS charge_segment,

    COUNT(*) AS customers,

    SUM(
        CASE
            WHEN c.churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN c.churn = 'Yes' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN c.churn = 'Yes' THEN c.monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk

FROM customers c
CROSS JOIN median_charge m

GROUP BY
    CASE
        WHEN c.monthly_charges < m.median_monthly_charge
            THEN 'Below median'
        ELSE 'At/above median'
    END

ORDER BY churn_rate DESC;