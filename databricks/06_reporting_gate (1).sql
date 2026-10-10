-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.silver.reporting_gate AS
SELECT
    m.*,
    g.geo_master_match,

    CASE
        WHEN g.geo_master_match <> 'PASS'
        THEN 'HOLD'

        WHEN governed_method_eligibility LIKE 'HOLD%'
        THEN 'HOLD'

        WHEN governed_method_eligibility LIKE 'REVIEW%'
        THEN 'REVIEW'

        WHEN manual_override_flag = TRUE
        THEN 'REVIEW'

        WHEN dcf_status IN ('UNKNOWN', 'NOT_VERIFIED')
        THEN 'REVIEW'

        ELSE 'ELIGIBLE'
    END AS governed_reporting_eligibility,

    CASE
        WHEN emissions_method = 'Spend-based'
             AND governed_method_eligibility = 'ELIGIBLE'
        THEN governed_spend_based_emissions_tco2e
        ELSE NULL
    END AS governed_final_emissions_tco2e

FROM iff_esg_assurance.silver.method_eligibility m

LEFT JOIN iff_esg_assurance.silver.geo_validation g
    ON m.source_record_id = g.source_record_id;

-- COMMAND ----------

SELECT
    governed_reporting_eligibility,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.reporting_gate
GROUP BY governed_reporting_eligibility
ORDER BY governed_reporting_eligibility;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.reporting_transactions AS
SELECT
    *,

    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN governed_final_emissions_tco2e
        ELSE NULL
    END AS governed_reporting_emissions_tco2e

FROM iff_esg_assurance.silver.reporting_gate;

-- COMMAND ----------

SELECT
    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'ELIGIBLE'
            THEN 1 ELSE 0
        END
    ) AS reporting_eligible,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'REVIEW'
            THEN 1 ELSE 0
        END
    ) AS review,

    SUM(
        CASE
            WHEN governed_reporting_eligibility = 'HOLD'
            THEN 1 ELSE 0
        END
    ) AS hold,

    SUM(governed_final_emissions_tco2e)
        AS total_calculated_emissions_tco2e,

    SUM(governed_reporting_emissions_tco2e)
        AS reporting_emissions_tco2e

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    transaction_id,

    excel_reporting_eligibility,
    governed_reporting_eligibility,

    excel_reporting_emissions_tco2e,
    governed_reporting_emissions_tco2e,

    CASE
        WHEN COALESCE(excel_reporting_eligibility,'NULL')
           = COALESCE(governed_reporting_eligibility,'NULL')
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS eligibility_qa,

    CASE
        WHEN
            (
                excel_reporting_emissions_tco2e IS NULL
                AND governed_reporting_emissions_tco2e IS NULL
            )
            OR
            ABS(
                COALESCE(excel_reporting_emissions_tco2e,0)
                -
                COALESCE(governed_reporting_emissions_tco2e,0)
            ) < 0.0001
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS emissions_qa

FROM iff_esg_assurance.gold.reporting_transactions
ORDER BY transaction_id;

-- COMMAND ----------

SELECT
    eligibility_qa,
    COUNT(*) AS records
FROM (
    SELECT
        CASE
            WHEN COALESCE(excel_reporting_eligibility,'NULL')
               = COALESCE(governed_reporting_eligibility,'NULL')
            THEN 'MATCH'
            ELSE 'MISMATCH'
        END AS eligibility_qa
    FROM iff_esg_assurance.gold.reporting_transactions
)
GROUP BY eligibility_qa;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.silver.reporting_gate;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.reporting_transactions AS
SELECT
    *,
    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN governed_final_emissions_tco2e
        ELSE NULL
    END AS governed_reporting_emissions_tco2e
FROM iff_esg_assurance.silver.reporting_gate;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.reporting_transactions;