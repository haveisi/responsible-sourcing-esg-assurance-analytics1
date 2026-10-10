-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.reporting_reconciliation AS
SELECT
    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN governed_method_eligibility = 'ELIGIBLE'
            THEN 1 ELSE 0
        END
    ) AS method_eligible_transactions,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'ELIGIBLE'
            THEN 1 ELSE 0
        END
    ) AS reporting_eligible_transactions,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'REVIEW'
            THEN 1 ELSE 0
        END
    ) AS review_transactions,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'HOLD'
            THEN 1 ELSE 0
        END
    ) AS hold_transactions,

    SUM(governed_final_emissions_tco2e)
        AS total_calculated_emissions_tco2e,

    SUM(governed_reporting_emissions_tco2e)
        AS reporting_emissions_tco2e,

    SUM(governed_final_emissions_tco2e)
      - COALESCE(SUM(governed_reporting_emissions_tco2e),0)
        AS excluded_emissions_tco2e,

    CASE
        WHEN COUNT(*) =
             SUM(
                 CASE
                     WHEN governed_reporting_eligibility
                          IN ('ELIGIBLE','REVIEW','HOLD')
                     THEN 1 ELSE 0
                 END
             )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.reporting_reconciliation;

-- COMMAND ----------

SELECT
    r.total_transactions,
    r.method_eligible_transactions,
    r.reporting_eligible_transactions,
    r.review_transactions,
    r.hold_transactions,
    r.total_calculated_emissions_tco2e,
    r.reporting_emissions_tco2e,
    r.excluded_emissions_tco2e,
    r.reconciliation_status,

    100 AS excel_total_transactions,
    33 AS excel_method_eligible,
    15 AS excel_reporting_eligible,
    25 AS excel_review,
    60 AS excel_hold,
    192.59996 AS excel_total_calculated_emissions,
    91.027011 AS excel_reporting_emissions,
    101.57295 AS excel_excluded_emissions

FROM iff_esg_assurance.gold.reporting_reconciliation r;

-- COMMAND ----------

SELECT
    *,

    CASE
        WHEN total_transactions = excel_total_transactions
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS total_transactions_qa,

    CASE
        WHEN reporting_eligible_transactions = excel_reporting_eligible
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS eligible_qa,

    CASE
        WHEN review_transactions = excel_review
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS review_qa,

    CASE
        WHEN hold_transactions = excel_hold
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS hold_qa,

    CASE
        WHEN ABS(
            total_calculated_emissions_tco2e
            - excel_total_calculated_emissions
        ) < 0.01
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS calculated_emissions_qa,

    CASE
        WHEN ABS(
            reporting_emissions_tco2e
            - excel_reporting_emissions
        ) < 0.01
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS reporting_emissions_qa

FROM (
    SELECT
        r.*,
        100 AS excel_total_transactions,
        33 AS excel_method_eligible,
        15 AS excel_reporting_eligible,
        25 AS excel_review,
        60 AS excel_hold,
        192.59996 AS excel_total_calculated_emissions,
        91.027011 AS excel_reporting_emissions,
        101.57295 AS excel_excluded_emissions
    FROM iff_esg_assurance.gold.reporting_reconciliation r
);

-- COMMAND ----------

SELECT
    *,

    CASE
        WHEN total_transactions = excel_total_transactions
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS total_transactions_qa,

    CASE
        WHEN reporting_eligible_transactions = excel_reporting_eligible
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS eligible_qa,

    CASE
        WHEN review_transactions = excel_review
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS review_qa,

    CASE
        WHEN hold_transactions = excel_hold
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS hold_qa,

    CASE
        WHEN ABS(
            total_calculated_emissions_tco2e
            - excel_total_calculated_emissions
        ) < 0.01
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS calculated_emissions_qa,

    CASE
        WHEN ABS(
            reporting_emissions_tco2e
            - excel_reporting_emissions
        ) < 0.01
        THEN 'MATCH' ELSE 'MISMATCH'
    END AS reporting_emissions_qa

FROM (
    SELECT
        r.*,
        100 AS excel_total_transactions,
        33 AS excel_method_eligible,
        15 AS excel_reporting_eligible,
        25 AS excel_review,
        60 AS excel_hold,
        192.59996 AS excel_total_calculated_emissions,
        91.027011 AS excel_reporting_emissions,
        101.57295 AS excel_excluded_emissions
    FROM iff_esg_assurance.gold.reporting_reconciliation r
);

-- COMMAND ----------

SELECT
    governed_reporting_eligibility,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.reporting_transactions
GROUP BY governed_reporting_eligibility;

-- COMMAND ----------

SELECT
    transaction_id,
    excel_final_emissions_tco2e,
    governed_final_emissions_tco2e,
    excel_reporting_emissions_tco2e,
    governed_reporting_emissions_tco2e
FROM iff_esg_assurance.gold.reporting_transactions
WHERE
    ABS(
        COALESCE(excel_final_emissions_tco2e,0)
        -
        COALESCE(governed_final_emissions_tco2e,0)
    ) > 0.0001
OR
    ABS(
        COALESCE(excel_reporting_emissions_tco2e,0)
        -
        COALESCE(governed_reporting_emissions_tco2e,0)
    ) > 0.0001
ORDER BY transaction_id;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.reporting_reconciliation AS
SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE WHEN governed_method_eligibility = 'ELIGIBLE' THEN 1 ELSE 0 END)
        AS method_eligible_transactions,

    SUM(CASE WHEN governed_reporting_eligibility = 'ELIGIBLE' THEN 1 ELSE 0 END)
        AS reporting_eligible_transactions,

    SUM(CASE WHEN governed_reporting_eligibility = 'REVIEW' THEN 1 ELSE 0 END)
        AS review_transactions,

    SUM(CASE WHEN governed_reporting_eligibility = 'HOLD' THEN 1 ELSE 0 END)
        AS hold_transactions,

    SUM(governed_final_emissions_tco2e)
        AS total_calculated_emissions_tco2e,

    SUM(governed_reporting_emissions_tco2e)
        AS reporting_emissions_tco2e,

    SUM(governed_final_emissions_tco2e)
      - COALESCE(SUM(governed_reporting_emissions_tco2e),0)
        AS excluded_emissions_tco2e,

    CASE
        WHEN COUNT(*) =
             SUM(
                 CASE
                     WHEN governed_reporting_eligibility
                          IN ('ELIGIBLE','REVIEW','HOLD')
                     THEN 1 ELSE 0
                 END
             )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.reporting_reconciliation;

-- COMMAND ----------

SELECT COUNT(*) AS total_exceptions
FROM iff_esg_assurance.gold.exception_register;

-- COMMAND ----------

SELECT
    exception_type,
    COUNT(*) AS exception_count
FROM iff_esg_assurance.gold.exception_register
GROUP BY exception_type
ORDER BY exception_count DESC;