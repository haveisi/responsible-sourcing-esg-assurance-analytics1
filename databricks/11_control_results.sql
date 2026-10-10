-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.control_results AS

SELECT
    transaction_id,
    supplier_id,
    'CTRL-GEO-001' AS control_id,
    'Geography master-data validation' AS control_name,

    CASE
        WHEN geo_master_match = 'PASS'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS control_result,

    CASE
        WHEN geo_master_match = 'PASS'
        THEN NULL
        ELSE 'Supplier/farm geography does not match governed master data'
    END AS exception_reason

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

SELECT
    transaction_id,
    supplier_id,
    'CTRL-METHOD-001',
    'Emissions method validation',

    CASE
        WHEN method_validation_status = 'PASS'
        THEN 'PASS'
        WHEN method_validation_status = 'HOLD'
        THEN 'FAIL'
        ELSE 'REVIEW'
    END,

    CASE
        WHEN method_validation_status = 'PASS'
        THEN NULL
        WHEN emissions_method = 'Activity-based'
        THEN 'Activity-based emission factor missing'
        WHEN emissions_method = 'Supplier-specific'
        THEN 'Supplier-specific evidence requires review'
        ELSE 'Method validation issue'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

SELECT
    transaction_id,
    supplier_id,
    'CTRL-PRICE-001',
    'Price-year alignment',

    CASE
        WHEN emissions_method <> 'Spend-based'
        THEN 'N/A'

        WHEN governed_spend_usd_2022 IS NOT NULL
         AND ABS(governed_price_year_adjustment_factor - 0.92053) <= 0.000001
        THEN 'PASS'

        ELSE 'FAIL'
    END,

    CASE
        WHEN emissions_method <> 'Spend-based'
        THEN NULL

        WHEN governed_spend_usd_2022 IS NULL
        THEN '2022-dollar spend value missing'

        WHEN ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
        THEN 'Price-year adjustment factor mismatch'

        ELSE NULL
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

SELECT
    transaction_id,
    supplier_id,
    'CTRL-EVID-001',
    'Supplier GHG evidence validation',

    CASE
        WHEN emissions_method <> 'Supplier-specific'
        THEN 'N/A'

        WHEN supplier_specific_validation = 'PASS'
        THEN 'PASS'

        WHEN supplier_specific_validation LIKE 'REVIEW%'
        THEN 'REVIEW'

        ELSE 'FAIL'
    END,

    CASE
        WHEN emissions_method <> 'Supplier-specific'
        THEN NULL
        WHEN supplier_specific_validation = 'PASS'
        THEN NULL
        ELSE supplier_specific_validation
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

SELECT
    transaction_id,
    supplier_id,
    'CTRL-DCF-001',
    'DCF sourcing-status validation',

    CASE
        WHEN dcf_status = 'VERIFIED_DCF'
        THEN 'PASS'

        WHEN dcf_status = 'CLAIMED_DCF'
        THEN 'REVIEW'

        WHEN dcf_status IN ('UNKNOWN','NOT_VERIFIED')
        THEN 'FAIL'

        ELSE 'REVIEW'
    END,

    CASE
        WHEN dcf_status = 'VERIFIED_DCF'
        THEN NULL
        WHEN dcf_status = 'CLAIMED_DCF'
        THEN 'DCF claim requires supporting verification'
        WHEN dcf_status = 'UNKNOWN'
        THEN 'DCF status unknown'
        WHEN dcf_status = 'NOT_VERIFIED'
        THEN 'DCF status not verified'
        ELSE 'DCF status requires review'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

SELECT
    transaction_id,
    supplier_id,
    'CTRL-REPORT-001',
    'Final reporting eligibility gate',

    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN 'PASS'

        WHEN governed_reporting_eligibility = 'REVIEW'
        THEN 'REVIEW'

        ELSE 'FAIL'
    END,

    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN NULL
        ELSE CONCAT(
            'Reporting disposition: ',
            governed_reporting_eligibility
        )
    END

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.control_results
ORDER BY transaction_id, control_id
LIMIT 100;

-- COMMAND ----------

SELECT
    control_id,
    control_name,
    control_result,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.control_results
GROUP BY
    control_id,
    control_name,
    control_result
ORDER BY
    control_id,
    control_result;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.control_summary AS
SELECT
    control_id,
    control_name,

    COUNT(*) AS total_records,

    SUM(CASE WHEN control_result = 'PASS' THEN 1 ELSE 0 END)
        AS pass_records,

    SUM(CASE WHEN control_result = 'REVIEW' THEN 1 ELSE 0 END)
        AS review_records,

    SUM(CASE WHEN control_result = 'FAIL' THEN 1 ELSE 0 END)
        AS fail_records,

    SUM(CASE WHEN control_result = 'N/A' THEN 1 ELSE 0 END)
        AS na_records,

    ROUND(
        100.0 *
        SUM(CASE WHEN control_result = 'PASS' THEN 1 ELSE 0 END)
        /
        NULLIF(
            SUM(
                CASE
                    WHEN control_result IN ('PASS','REVIEW','FAIL')
                    THEN 1 ELSE 0
                END
            ),
            0
        ),
        1
    ) AS pass_rate_pct

FROM iff_esg_assurance.gold.control_results

GROUP BY
    control_id,
    control_name;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.control_summary
ORDER BY control_id;

-- COMMAND ----------

SELECT
    COUNT(*) AS control_rows,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT
    source_record_id,
    transaction_id,
    supplier_id
FROM iff_esg_assurance.gold.reporting_transactions
LIMIT 10;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.control_results AS

-- 1. Geography control
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-GEO-001' AS control_id,
    'Geography master-data validation' AS control_name,

    CASE
        WHEN geo_master_match = 'PASS'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS control_result,

    CASE
        WHEN geo_master_match = 'PASS'
        THEN NULL
        ELSE 'Supplier/farm geography does not match governed master data'
    END AS exception_reason

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- 2. Emissions-method control
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-METHOD-001',
    'Emissions method validation',

    CASE
        WHEN method_validation_status = 'PASS'
        THEN 'PASS'

        WHEN method_validation_status = 'HOLD'
        THEN 'FAIL'

        ELSE 'REVIEW'
    END,

    CASE
        WHEN method_validation_status = 'PASS'
        THEN NULL

        WHEN emissions_method = 'Activity-based'
        THEN 'Activity-based emission factor missing'

        WHEN emissions_method = 'Supplier-specific'
        THEN 'Supplier-specific evidence requires review'

        ELSE 'Method validation issue'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- 3. Price-year control
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-PRICE-001',
    'Price-year alignment',

    CASE
        WHEN emissions_method <> 'Spend-based'
        THEN 'N/A'

        WHEN governed_spend_usd_2022 IS NOT NULL
         AND ABS(governed_price_year_adjustment_factor - 0.92053) <= 0.000001
        THEN 'PASS'

        ELSE 'FAIL'
    END,

    CASE
        WHEN emissions_method <> 'Spend-based'
        THEN NULL

        WHEN governed_spend_usd_2022 IS NULL
        THEN '2022-dollar spend value missing'

        WHEN ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
        THEN 'Price-year adjustment factor mismatch'

        ELSE NULL
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- 4. Supplier evidence control
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-EVID-001',
    'Supplier GHG evidence validation',

    CASE
        WHEN emissions_method <> 'Supplier-specific'
        THEN 'N/A'

        WHEN supplier_specific_validation = 'PASS'
        THEN 'PASS'

        WHEN supplier_specific_validation LIKE 'REVIEW%'
        THEN 'REVIEW'

        ELSE 'FAIL'
    END,

    CASE
        WHEN emissions_method <> 'Supplier-specific'
        THEN NULL

        WHEN supplier_specific_validation = 'PASS'
        THEN NULL

        ELSE supplier_specific_validation
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- 5. DCF / sourcing control
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-DCF-001',
    'DCF sourcing-status validation',

    CASE
        WHEN dcf_status = 'VERIFIED_DCF'
        THEN 'PASS'

        WHEN dcf_status = 'CLAIMED_DCF'
        THEN 'REVIEW'

        WHEN dcf_status IN ('UNKNOWN','NOT_VERIFIED')
        THEN 'FAIL'

        ELSE 'REVIEW'
    END,

    CASE
        WHEN dcf_status = 'VERIFIED_DCF'
        THEN NULL

        WHEN dcf_status = 'CLAIMED_DCF'
        THEN 'DCF claim requires supporting verification'

        WHEN dcf_status = 'UNKNOWN'
        THEN 'DCF status unknown'

        WHEN dcf_status = 'NOT_VERIFIED'
        THEN 'DCF status not verified'

        ELSE 'DCF status requires review'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- 6. Final reporting gate
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    'CTRL-REPORT-001',
    'Final reporting eligibility gate',

    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN 'PASS'

        WHEN governed_reporting_eligibility = 'REVIEW'
        THEN 'REVIEW'

        ELSE 'FAIL'
    END,

    CASE
        WHEN governed_reporting_eligibility = 'ELIGIBLE'
        THEN NULL

        ELSE CONCAT(
            'Reporting disposition: ',
            governed_reporting_eligibility
        )
    END

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS source_records,
    COUNT(DISTINCT control_id) AS controls
FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT
    source_record_id,
    COUNT(*) AS control_tests
FROM iff_esg_assurance.gold.control_results
GROUP BY source_record_id
HAVING COUNT(*) <> 6;