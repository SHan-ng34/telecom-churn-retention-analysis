-- ============================================================
-- Customer Churn & Retention Economics
-- 02 - Revenue-at-Risk Analysis
-- ============================================================

-- Revenue-at-risk is defined here as the monthly charges
-- associated with customers who have churned.
--
-- Important:
-- This is historical observed revenue exposure, not guaranteed
-- future revenue loss.


-- ============================================================
-- 1. Overall Monthly Revenue & Historical Revenue Exposure
-- ============================================================

SELECT
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        )
        / SUM(monthly_charges),
        2
    ) AS revenue_exposure_pct
FROM customers;


-- ============================================================
-- 2. Revenue-at-Risk by Contract
-- ============================================================

SELECT
    contract,
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

    ROUND(SUM(monthly_charges), 2)
        AS total_monthly_revenue,

    ROUND(
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 'Yes' THEN monthly_charges
                ELSE 0
            END
        )
        / SUM(monthly_charges),
        2
    ) AS revenue_at_risk_pct

FROM customers
GROUP BY contract
ORDER BY revenue_at_risk DESC;


-- ============================================================
-- 3. Revenue-at-Risk by Tenure Group
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

GROUP BY
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END

ORDER BY MIN(tenure);


-- ============================================================
-- 4. Revenue-at-Risk by Payment Method
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
GROUP BY payment_method
ORDER BY revenue_at_risk DESC;


-- ============================================================
-- 5. Active Customer Revenue Exposure
-- ============================================================

-- This metric is used for forward-looking retention opportunity.
-- Unlike historical revenue-at-risk, this only considers customers
-- who are currently active in the snapshot.

SELECT
    COUNT(*) AS active_customers,

    ROUND(
        SUM(monthly_charges),
        2
    ) AS active_monthly_revenue,

    ROUND(
        AVG(monthly_charges),
        2
    ) AS average_active_monthly_charge

FROM customers
WHERE churn = 'No';