-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.exception_register AS
WITH base AS (
    SELECT
        transaction_id,
        supplier_id,
        governed_reporting_eligibility,
        geo_master_match,
        governed_method_eligibility,
        supplier_specific_validation,
        dcf_status,
        manual_override_flag,

        CASE
            WHEN geo_master_match <> 'PASS'
            THEN 'GEO'

            WHEN governed_method_eligibility LIKE '%ACTIVITY%'
            THEN 'METHOD'

            WHEN governed_method_eligibility LIKE '%SUPPLIER%'
            THEN 'EVIDENCE'

            WHEN manual_override_flag = TRUE
            THEN 'MANUAL OVERRIDE'

            WHEN dcf_status IN ('UNKNOWN','NOT_VERIFIED')
            THEN 'DCF'

            ELSE 'OTHER'
        END AS exception_type,

        CASE
            WHEN geo_master_match <> 'PASS'
            THEN 'Supplier/farm geography does not match governed master data'

            WHEN governed_method_eligibility LIKE '%ACTIVITY%'
            THEN 'Activity-based emissions factor missing'

            WHEN governed_method_eligibility LIKE '%SUPPLIER%'
            THEN 'Supplier-specific GHG evidence missing or unresolved'

            WHEN manual_override_flag = TRUE
            THEN 'Manual override requires review'

            WHEN dcf_status IN ('UNKNOWN','NOT_VERIFIED')
            THEN 'DCF status is unknown or not verified'

            ELSE 'Other governance exception'
        END AS exception_reason

    FROM iff_esg_assurance.gold.reporting_transactions

    WHERE governed_reporting_eligibility <> 'ELIGIBLE'
)

SELECT
    CONCAT(
        'EXC-',
        LPAD(
            ROW_NUMBER() OVER (ORDER BY transaction_id),
            3,
            '0'
        )
    ) AS exception_id,

    transaction_id,
    supplier_id,
    governed_reporting_eligibility AS reporting_eligibility,
    exception_type,
    exception_reason,

    CASE
        WHEN exception_type = 'METHOD'
        THEN 'Carbon Accounting'

        WHEN exception_type = 'EVIDENCE'
        THEN 'Responsible Sourcing'

        WHEN exception_type = 'GEO'
        THEN 'Data Steward'

        WHEN exception_type = 'DCF'
        THEN 'Responsible Sourcing'

        WHEN exception_type = 'MANUAL OVERRIDE'
        THEN 'Data Governance'

        ELSE 'Data Governance'
    END AS control_owner,

    CASE
        WHEN exception_type IN ('METHOD','EVIDENCE','GEO')
        THEN 'High'

        WHEN exception_type IN ('DCF','MANUAL OVERRIDE')
        THEN 'Medium'

        ELSE 'Medium'
    END AS severity,

    CASE
        WHEN exception_type = 'METHOD'
        THEN 'Obtain and approve activity-based emission factor'

        WHEN exception_type = 'EVIDENCE'
        THEN 'Obtain or resolve supplier GHG evidence'

        WHEN exception_type = 'GEO'
        THEN 'Correct supplier/farm geographic linkage'

        WHEN exception_type = 'DCF'
        THEN 'Validate DCF status and supporting evidence'

        WHEN exception_type = 'MANUAL OVERRIDE'
        THEN 'Review and approve or remove manual override'

        ELSE 'Investigate and resolve exception'
    END AS remediation_action,

    'OPEN' AS status,

    CASE
        WHEN exception_type = 'METHOD'
        THEN 'Approved EF source, unit, and methodology'

        WHEN exception_type = 'EVIDENCE'
        THEN 'Verified and approved supplier GHG report'

        WHEN exception_type = 'GEO'
        THEN 'Corrected master record and geolocation evidence'

        WHEN exception_type = 'DCF'
        THEN 'Approved DCF declaration or sourcing evidence'

        WHEN exception_type = 'MANUAL OVERRIDE'
        THEN 'Documented override approval'

        ELSE 'Closure evidence'
    END AS evidence_required,

    CAST(NULL AS STRING) AS reviewer,
    CAST(NULL AS DATE) AS review_date,
    CAST(NULL AS DATE) AS closure_date,
    'NOT RETESTED' AS retest_result,
    'OPEN' AS closure_status

FROM base;

-- COMMAND ----------

SELECT
    exception_type,
    COUNT(*) AS exception_count
FROM iff_esg_assurance.gold.exception_register
GROUP BY exception_type
ORDER BY exception_count DESC;

-- COMMAND ----------

SELECT COUNT(*) AS total_exceptions
FROM iff_esg_assurance.gold.exception_register;

-- COMMAND ----------

SELECT
    (SELECT COUNT(*)
     FROM iff_esg_assurance.gold.reporting_transactions
     WHERE governed_reporting_eligibility <> 'ELIGIBLE')
    AS noneligible_transactions,

    (SELECT COUNT(*)
     FROM iff_esg_assurance.gold.exception_register)
    AS exception_records;

-- COMMAND ----------

SELECT
    CASE
        WHEN
            (SELECT COUNT(*)
             FROM iff_esg_assurance.gold.reporting_transactions
             WHERE governed_reporting_eligibility <> 'ELIGIBLE')
            =
            (SELECT COUNT(*)
             FROM iff_esg_assurance.gold.exception_register)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS exception_register_reconciliation;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.exception_register
ORDER BY exception_id
LIMIT 20;

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

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.fact_exception AS
SELECT
    exception_id,
    transaction_id,
    supplier_id,
    reporting_eligibility,
    exception_type,
    exception_reason,
    control_owner,
    severity,
    remediation_action,
    status,
    evidence_required,
    reviewer,
    review_date,
    closure_date,
    retest_result,
    closure_status
FROM iff_esg_assurance.gold.exception_register;