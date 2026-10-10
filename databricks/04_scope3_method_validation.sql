-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.silver.emission_factor_master_standardized AS
SELECT
    TRIM(CAST(emission_factor_id AS STRING)) AS emission_factor_id,
    TRIM(CAST(factor_name AS STRING)) AS factor_name,
    TRIM(CAST(sector_code AS STRING)) AS sector_code,
    TRIM(CAST(material_mapping AS STRING)) AS material_mapping,
    TRIM(CAST(calculation_method AS STRING)) AS calculation_method,
    CAST(factor_value AS DOUBLE) AS factor_value,
    TRIM(CAST(factor_unit AS STRING)) AS factor_unit,
    CAST(factor_year AS INT) AS factor_year,
    TRIM(CAST(factor_source AS STRING)) AS factor_source,
    UPPER(TRIM(CAST(factor_status AS STRING))) AS factor_status
FROM iff_esg_assurance.bronze.emission_factor_master_raw;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.silver.emission_factor_master_standardized;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.scope3_price_aligned AS
SELECT
    p.*,

    0.92053 AS governed_price_year_adjustment_factor,

    CASE
        WHEN p.spend_usd IS NOT NULL
        THEN p.spend_usd * 0.92053
        ELSE NULL
    END AS governed_spend_usd_2022

FROM iff_esg_assurance.silver.procurement_standardized p;

-- COMMAND ----------

SELECT
    transaction_id,
    spend_usd,
    excel_spend_usd_2022,
    governed_spend_usd_2022,
    governed_spend_usd_2022 - excel_spend_usd_2022 AS difference
FROM iff_esg_assurance.silver.scope3_price_aligned
ORDER BY transaction_id;

-- COMMAND ----------

SELECT
    CASE
        WHEN ABS(governed_spend_usd_2022 - excel_spend_usd_2022) < 0.01
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS qa_result,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.scope3_price_aligned
GROUP BY
    CASE
        WHEN ABS(governed_spend_usd_2022 - excel_spend_usd_2022) < 0.01
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.scope3_method_validation AS
SELECT
    p.*,

    f.emission_factor_id AS governed_emission_factor_id,
    f.factor_value AS governed_factor_value,
    f.factor_unit AS governed_factor_unit,
    f.factor_year AS governed_factor_year,
    f.factor_status AS governed_factor_status,

    CASE
        WHEN p.emissions_method = 'Spend-based'
             AND f.emission_factor_id IS NOT NULL
             AND f.factor_status = 'APPROVED'
             AND f.factor_year = 2022
             AND p.governed_spend_usd_2022 IS NOT NULL
        THEN 'PASS'

        WHEN p.emissions_method = 'Activity-based'
        THEN 'HOLD'

        WHEN p.emissions_method = 'Supplier-specific'
        THEN 'REVIEW EVIDENCE'

        ELSE 'REVIEW'
    END AS method_validation_status,

    CASE
        WHEN p.emissions_method = 'Spend-based'
             AND f.emission_factor_id IS NOT NULL
             AND f.factor_status = 'APPROVED'
             AND f.factor_year = 2022
        THEN p.governed_spend_usd_2022 * f.factor_value / 1000

        ELSE NULL
    END AS governed_spend_based_emissions_tco2e

FROM iff_esg_assurance.silver.scope3_price_aligned p

LEFT JOIN iff_esg_assurance.silver.emission_factor_master_standardized f
    ON p.material_id = f.material_mapping
   AND f.calculation_method = 'Spend-based';

-- COMMAND ----------

SELECT
    emissions_method,
    method_validation_status,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.scope3_method_validation
GROUP BY emissions_method, method_validation_status
ORDER BY emissions_method;

-- COMMAND ----------

SELECT
    transaction_id,
    excel_spend_based_emissions_tco2e,
    governed_spend_based_emissions_tco2e,
    governed_spend_based_emissions_tco2e
      - excel_spend_based_emissions_tco2e AS difference
FROM iff_esg_assurance.silver.scope3_method_validation
WHERE emissions_method = 'Spend-based'
ORDER BY transaction_id;

-- COMMAND ----------

SELECT
    CASE
        WHEN ABS(
            governed_spend_based_emissions_tco2e
            - excel_spend_based_emissions_tco2e
        ) < 0.0001
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS qa_result,
    COUNT(*) AS records
FROM iff_esg_assurance.silver.scope3_method_validation
WHERE emissions_method = 'Spend-based'
GROUP BY
    CASE
        WHEN ABS(
            governed_spend_based_emissions_tco2e
            - excel_spend_based_emissions_tco2e
        ) < 0.0001
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END;

-- COMMAND ----------

SELECT column_name
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'scope3_method_validation'
  AND column_name = 'source_record_id';