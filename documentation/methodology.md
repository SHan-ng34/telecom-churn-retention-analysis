# Methodology

## 1. Data Source & Scope

The project uses the IBM Telco Customer Churn dataset, containing 7,043 customer records and 21 customer-level attributes.

The dataset includes information on:

- Customer tenure
- Contract type
- Payment method
- Monthly charges
- Total charges
- Internet and additional services
- Churn status

The analysis treats each customer record as an observational snapshot.

---

## 2. Data Cleaning

The raw CSV was preserved without modification.

A cleaned copy was created using Python and Pandas.

### Cleaning Steps

1. Loaded the raw CSV using Pandas.
2. Converted the TotalCharges field to numeric format.
3. Converted whitespace-only values in TotalCharges to missing values using numeric coercion.
4. Preserved the resulting missing values rather than imputing them.
5. Exported the cleaned dataset as:

data/cleaned/telco_churn_cleaned.csv

### Data Quality Checks

The dataset was checked for:

- Customer ID uniqueness
- Missing values
- Valid categorical values
- Numeric ranges
- Tenure range
- Monthly charge range
- Plausibility of total charges

There were 11 missing TotalCharges values. These records had zero tenure, no observed churn, and two-year contracts. Because TotalCharges was not required for the core churn and revenue-exposure calculations, the missing values were retained.

### PostgreSQL Data Loading

The cleaned CSV was loaded into PostgreSQL using the customers table defined in:

sql/00_create_table.sql

The cleaned dataset can be loaded using PostgreSQL's \copy command:

\copy customers FROM 'data/cleaned/telco_churn_cleaned.csv' WITH (FORMAT csv, HEADER true);

`\copy` was used instead of server-side `COPY` because it reads the file from the client environment and avoids requiring PostgreSQL server-level file access permissions.
---

## 3. Business KPI Definitions

### Customer Count

Total number of unique customers in the dataset.

### Churn Rate

The percentage of customers whose churn status is Yes.

Churn Rate =
Churned Customers / Total Customers × 100

### Monthly Revenue

The sum of MonthlyCharges across customers.

### Historical Revenue-at-Risk

Monthly charges associated with customers whose churn status is Yes.

Historical Revenue-at-Risk =
SUM(MonthlyCharges for Churn = Yes)

This represents observed historical monthly revenue exposure associated with customers who churned in the dataset.

It is not treated as guaranteed future revenue loss.

### Revenue Exposure %

Revenue Exposure % =
Historical Revenue-at-Risk / Total Monthly Revenue × 100

### Active Monthly Revenue Exposure

For forward-looking retention analysis, monthly charges from customers with Churn = No are used.

This represents the recurring monthly revenue associated with customers who remain active in the observed snapshot and provides an exposure measure for potential retention activity.

---

## 4. Churn Segmentation

Churn was analyzed across multiple customer dimensions to identify patterns and concentrations.

### Contract

Customers were grouped into:

- Month-to-month
- One year
- Two year

### Tenure

Tenure was grouped into:

- 0–12 months
- 13–24 months
- 25–48 months
- 49–72 months

### Monthly Charges

Customers were divided using the median monthly charge into:

- Below median
- At/above median

The charge segmentation was used as an economic lens rather than as a standalone intervention criterion.

### Payment Method

Churn was compared across the available payment methods.

### Service Breadth

Service breadth was defined using the presence of phone, multiple lines, internet, and selected additional services.

The resulting service count was used to examine whether churn patterns varied with breadth of service adoption.

---

## 5. Multi-Dimensional Segment Analysis

Single-variable churn rates were supplemented with combinations of customer attributes.

The analysis examined combinations including:

- Contract × payment method
- Contract × tenure
- Contract × payment method × tenure

Segment evaluation considered:

- Segment size
- Number of churned customers
- Churn rate
- Historical revenue exposure
- Active customer revenue exposure

A higher percentage of churn does not automatically represent the largest business opportunity. Segment scale and economic exposure were therefore considered alongside churn rate.

This approach led to the identification of:

Month-to-month + Electronic Check + 0–12 Months

as a concentrated population for potential retention testing.

---

## 6. Statistical Analysis

Statistical analysis was performed in Python using SciPy and Statsmodels.

### Chi-Square Tests

Chi-square tests of independence were used to assess whether selected categorical variables were statistically associated with churn.

Tests included:

- Contract type vs churn
- Payment method vs churn

### Cramér's V

Cramér's V was used to describe the strength of association for categorical variables.

### Logistic Regression

A multivariable logistic regression model was used to examine the association between selected customer characteristics and churn while controlling for other included variables.

Variables included:

- Tenure
- Monthly charges
- Contract
- Payment method
- Internet service
- Tech support

Categorical variables were encoded before modelling.

Redundant variables were removed where structural relationships caused model-identification issues.

The logistic regression results are interpreted as associations rather than causal effects.

---

## 7. Revenue & Retention Economics

A scenario-based framework was developed to evaluate the economics of potential retention interventions.

The framework uses:

- Active customer count
- Average active monthly charges
- Assumed retention rate
- Intervention cost per customer
- Six-month evaluation horizon

### Potential Revenue Retained

Potential Revenue Retained =
Active Customers
× Assumed Retention Rate
× Average Active Monthly Charges
× 6 months

### Intervention Cost

Intervention Cost =
Active Customers
× Intervention Cost per Customer

### Net Potential Value

Net Potential Value =
Potential Revenue Retained
− Intervention Cost

### Break-Even Retention Rate

Break-Even Retention Rate =
Intervention Cost per Customer
/
(Average Active Monthly Charges × 6)

Three illustrative intervention-cost scenarios were evaluated:

- $20 per customer
- $40 per customer
- $60 per customer

These scenarios are decision thresholds rather than forecasts of actual intervention performance.

---

## 8. Retention Experiment Framework

The historical dataset does not contain intervention or treatment information, so an actual A/B experiment could not be performed.

Instead, the analysis proposes a future experimental framework:

1. Define eligible customers.
2. Randomly assign eligible customers to control and treatment groups.
3. Apply the selected intervention to the treatment group.
4. Measure retention over a defined evaluation period.
5. Calculate incremental retention versus the control group.
6. Estimate revenue retained.
7. Calculate intervention cost.
8. Evaluate net incremental value.
9. Scale, modify, or discontinue the intervention based on observed results.

---

## 9. Analytical Limitations

### Observational Data

The dataset is an observational historical snapshot. Associations between customer characteristics and churn should not be interpreted as evidence of causation.

For example, higher churn among electronic-check customers does not establish that changing payment method will cause customers to remain.

### Historical Revenue-at-Risk

Historical revenue-at-risk represents monthly charges associated with customers who had already churned in the observed dataset.

It should not be interpreted as guaranteed future revenue loss.

### Forward-Looking Exposure

Active-customer monthly revenue exposure is used when discussing potential retention opportunities because these customers remain active in the observed snapshot.

### No Actual Experiment

An actual A/B experiment was not possible because the dataset does not contain:

- Treatment assignment
- Control and treatment groups
- Intervention timing
- Post-intervention outcomes

Therefore, the proposed retention experiments are future decision frameworks rather than observed experimental results.

### Retention Economics

The intervention cost and retention-rate assumptions are illustrative scenarios. They are used to calculate economic thresholds, not to predict actual intervention outcomes.