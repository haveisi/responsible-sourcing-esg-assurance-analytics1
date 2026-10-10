-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.silver.evidence_register_standardized AS
SELECT
    TRIM(CAST(evidence_id AS STRING)) AS evidence_id,
    TRIM(CAST(supplier_id AS STRING)) AS supplier_id,
    TRIM(CAST(farm_id AS STRING)) AS farm_id,
    TRIM(CAST(evidence_type AS STRING)) AS evidence_type,
    TRIM(CAST(document_reference AS STRING)) AS document_reference,
    CAST(issue_date AS DATE) AS issue_date,
    CAST(expiry_date AS DATE) AS expiry_date,
    UPPER(TRIM(CAST(verification_status AS STRING))) AS verification_status,
    UPPER(TRIM(CAST(review_status AS STRING))) AS review_status,
    TRIM(CAST(reviewer AS STRING)) AS reviewer,
    TRIM(CAST(notes AS STRING)) AS notes
FROM iff_esg_assurance.bronze.evidence_register_raw;

-- COMMAND ----------

SELECT
    evidence_id,
    supplier_id,
    evidence_type,
    verification_status,
    review_status,
    issue_date,
    expiry_date
FROM iff_esg_assurance.silver.evidence_register_standardized
WHERE evidence_type = 'Supplier GHG report'
ORDER BY supplier_id, issue_date;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.supplier_ghg_evidence_summary AS
SELECT
    supplier_id,

    COUNT(*) AS ghg_report_count,

    SUM(
        CASE
            WHEN verification_status = 'VERIFIED'
             AND review_status = 'APPROVED'
            THEN 1
            ELSE 0
        END
    ) AS verified_approved_count,

    SUM(
        CASE
            WHEN review_status = 'APPROVED'
            THEN 1
            ELSE 0
        END
    ) AS approved_count,

    SUM(
        CASE
            WHEN verification_status = 'UNVERIFIED'
            THEN 1
            ELSE 0
        END
    ) AS unverified_count,

    CASE
        WHEN SUM(
            CASE
                WHEN verification_status = 'VERIFIED'
                 AND review_status = 'APPROVED'
                THEN 1
                ELSE 0
            END
        ) > 0
        THEN 'VERIFIED + APPROVED'

        WHEN SUM(
            CASE
                WHEN review_status = 'APPROVED'
                THEN 1
                ELSE 0
            END
        ) > 0
        THEN 'APPROVED BUT UNVERIFIED'

        WHEN COUNT(*) > 0
        THEN 'EVIDENCE EXISTS - NOT APPROVED'

        ELSE 'NO EVIDENCE'
    END AS supplier_ghg_evidence_status

FROM iff_esg_assurance.silver.evidence_register_standardized
WHERE evidence_type = 'Supplier GHG report'
GROUP BY supplier_id;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.silver.supplier_ghg_evidence_summary
ORDER BY supplier_id;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.supplier_specific_validation AS
SELECT
    m.*,

    e.ghg_report_count,
    e.verified_approved_count,
    e.approved_count,
    e.unverified_count,
    e.supplier_ghg_evidence_status,

    CASE
        WHEN m.emissions_method <> 'Supplier-specific'
        THEN 'N/A'

        WHEN e.supplier_id IS NULL
        THEN 'HOLD - NO GHG EVIDENCE'

        WHEN e.supplier_ghg_evidence_status = 'VERIFIED + APPROVED'
        THEN 'PASS'

        WHEN e.supplier_ghg_evidence_status = 'APPROVED BUT UNVERIFIED'
        THEN 'REVIEW - UNVERIFIED'

        WHEN e.supplier_ghg_evidence_status = 'EVIDENCE EXISTS - NOT APPROVED'
        THEN 'HOLD - EVIDENCE NOT APPROVED'

        ELSE 'HOLD - NO GHG EVIDENCE'
    END AS supplier_specific_validation

FROM iff_esg_assurance.silver.scope3_method_validation m

LEFT JOIN iff_esg_assurance.silver.supplier_ghg_evidence_summary e
    ON m.supplier_id = e.supplier_id;

-- COMMAND ----------

SELECT
    emissions_method,
    supplier_specific_validation,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.supplier_specific_validation
GROUP BY emissions_method, supplier_specific_validation
ORDER BY emissions_method, supplier_specific_validation;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.method_eligibility AS
SELECT
    *,

    CASE
        WHEN emissions_method = 'Spend-based'
             AND method_validation_status = 'PASS'
        THEN 'ELIGIBLE'

        WHEN emissions_method = 'Activity-based'
        THEN 'HOLD - NEED ACTIVITY EF'

        WHEN emissions_method = 'Supplier-specific'
             AND supplier_specific_validation = 'PASS'
        THEN 'ELIGIBLE'

        WHEN emissions_method = 'Supplier-specific'
             AND supplier_specific_validation LIKE 'REVIEW%'
        THEN 'REVIEW - SUPPLIER EVIDENCE'

        WHEN emissions_method = 'Supplier-specific'
        THEN 'HOLD - NO SUPPLIER EVIDENCE'

        ELSE 'REVIEW'
    END AS governed_method_eligibility

FROM iff_esg_assurance.silver.supplier_specific_validation;

-- COMMAND ----------

SELECT
    governed_method_eligibility,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.method_eligibility
GROUP BY governed_method_eligibility
ORDER BY governed_method_eligibility;

-- COMMAND ----------

SELECT
    transaction_id,
    emissions_method,
    excel_method_eligibility,
    governed_method_eligibility,

    CASE
        WHEN COALESCE(excel_method_eligibility,'NULL')
           = COALESCE(governed_method_eligibility,'NULL')
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS qa_result

FROM iff_esg_assurance.silver.method_eligibility
ORDER BY transaction_id;

-- COMMAND ----------

SELECT
    CASE
        WHEN COALESCE(excel_method_eligibility,'NULL')
           = COALESCE(governed_method_eligibility,'NULL')
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS qa_result,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.method_eligibility
GROUP BY
    CASE
        WHEN COALESCE(excel_method_eligibility,'NULL')
           = COALESCE(governed_method_eligibility,'NULL')
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END;

-- COMMAND ----------

SELECT column_name
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'supplier_specific_validation'
  AND column_name = 'source_record_id';

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.method_eligibility AS
SELECT
    *,

    CASE
        WHEN emissions_method = 'Spend-based'
             AND method_validation_status = 'PASS'
        THEN 'ELIGIBLE'

        WHEN emissions_method = 'Activity-based'
        THEN 'HOLD - NEED ACTIVITY EF'

        WHEN emissions_method = 'Supplier-specific'
             AND supplier_specific_validation = 'PASS'
        THEN 'ELIGIBLE'

        WHEN emissions_method = 'Supplier-specific'
             AND supplier_specific_validation LIKE 'REVIEW%'
        THEN 'REVIEW - SUPPLIER EVIDENCE'

        WHEN emissions_method = 'Supplier-specific'
        THEN 'HOLD - NO SUPPLIER EVIDENCE'

        ELSE 'REVIEW'
    END AS governed_method_eligibility

FROM iff_esg_assurance.silver.supplier_specific_validation;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_record_ids
FROM iff_esg_assurance.silver.method_eligibility;

-- COMMAND ----------

SELECT
    source_record_id,
    transaction_id,
    supplier_id
FROM iff_esg_assurance.silver.method_eligibility
LIMIT 10;

-- COMMAND ----------

