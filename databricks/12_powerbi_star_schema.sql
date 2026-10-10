-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.fact_reporting_transaction AS
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    municipality_code,
    farm_id,
    material_id,
    reporting_year,
    invoice_date,

    quantity,
    quantity_unit,
    spend_usd,

    emissions_method,
    governed_emission_factor_id,
    governed_factor_value,
    governed_spend_usd_2022,
    governed_spend_based_emissions_tco2e,

    governed_method_eligibility,
    geo_master_match,
    dcf_status,
    manual_override_flag,

    governed_reporting_eligibility,

    governed_final_emissions_tco2e,
    governed_reporting_emissions_tco2e

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT COUNT(*) AS rows
FROM iff_esg_assurance.gold.fact_reporting_transaction;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.fact_control_result AS
SELECT
    transaction_id,
    supplier_id,
    control_id,
    control_result,
    exception_reason

FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT COUNT(*) AS rows
FROM iff_esg_assurance.gold.fact_control_result;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_supplier AS
SELECT DISTINCT
    TRIM(CAST(supplier_id AS STRING)) AS supplier_id,
    supplier_name,
    country_code,
    municipality_name,
    LPAD(CAST(municipality_code AS STRING),7,'0') AS municipality_code,
    CAST(supplier_ghg_data_available AS STRING) AS supplier_ghg_data_available

FROM iff_esg_assurance.bronze.supplier_master_raw
WHERE supplier_id IS NOT NULL;

-- COMMAND ----------

SELECT COUNT(*) AS rows
FROM iff_esg_assurance.gold.fact_control_result;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_supplier AS
SELECT DISTINCT
    TRIM(CAST(supplier_id AS STRING)) AS supplier_id,
    supplier_name,
    country_code,
    municipality_name,
    LPAD(CAST(municipality_code AS STRING),7,'0') AS municipality_code,
    CAST(supplier_ghg_data_available AS STRING) AS supplier_ghg_data_available

FROM iff_esg_assurance.bronze.supplier_master_raw
WHERE supplier_id IS NOT NULL;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.dim_supplier
ORDER BY supplier_id;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.bronze.municipality_reference_raw;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.bronze.municipality_reference_raw;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.bronze.municipality_reference_raw
LIMIT 5;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.bronze.municipality_reference_raw;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.bronze.municipality_reference_raw
LIMIT 1;

-- COMMAND ----------

SELECT
    column_name,
    data_type
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'municipality_reference_raw'
ORDER BY ordinal_position;

-- COMMAND ----------

SELECT
    column_name,
    data_type
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'municipality_reference_raw'
  AND LOWER(column_name) LIKE '%volume%';

-- COMMAND ----------

SELECT
    column_name,
    data_type
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'municipality_reference_raw'
  AND LOWER(column_name) LIKE '%mapbiomas%';

-- COMMAND ----------

SELECT
    column_name,
    data_type
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'municipality_reference_raw'
  AND LOWER(column_name) LIKE '%deforestation%';

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.bronze.municipality_reference_raw
LIMIT 1;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_municipality AS
SELECT DISTINCT
    LPAD(CAST(ibge_municipality_code AS STRING), 7, '0') AS municipality_code,
    municipality_name,
    state_code,
    state_name,
    CAST(area_km2 AS DOUBLE) AS area_km2,
    trase_biome,
    CAST(trase_year AS INT) AS trase_year
FROM iff_esg_assurance.bronze.municipality_reference_raw;

-- COMMAND ----------

SELECT COUNT(*) AS municipalities
FROM iff_esg_assurance.gold.dim_municipality;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_municipality AS
SELECT DISTINCT
    LPAD(CAST(ibge_municipality_code AS STRING), 7, '0') AS municipality_code,
    municipality_name,
    state_code,
    state_name,
    CAST(area_km2 AS DOUBLE) AS area_km2,

    CAST(trase_municipality_id AS STRING) AS trase_municipality_id,
    trase_biome,
    CAST(trase_year AS INT) AS trase_year,
    CAST(trase_volume AS DOUBLE) AS trase_soy_volume,
    CAST(trase_land_use AS DOUBLE) AS trase_land_use,

    CAST(soy_deforestation_5yr_exposure AS DOUBLE)
        AS soy_deforestation_5yr_exposure,

    CAST(co2_net_deforestation_exposure AS DOUBLE)
        AS co2_net_deforestation_exposure,

    CAST(mapbiomas_alert_count AS BIGINT)
        AS mapbiomas_alert_count,

    CAST(mapbiomas_alert_area_ha AS DOUBLE)
        AS mapbiomas_alert_area_ha,

    mapbiomas_year_range,
    mapbiomas_biomes,
    mapbiomas_primary_pressure,
    biome_complexity_flag,
    source

FROM iff_esg_assurance.bronze.municipality_reference_raw;

-- COMMAND ----------

SELECT COUNT(*) AS municipalities
FROM iff_esg_assurance.gold.dim_municipality;

-- COMMAND ----------

SELECT
    municipality_code,
    municipality_name,
    state_code,
    trase_biome,
    trase_year,
    trase_soy_volume,
    soy_deforestation_5yr_exposure,
    mapbiomas_alert_count,
    mapbiomas_alert_area_ha,
    mapbiomas_primary_pressure,
    biome_complexity_flag
FROM iff_esg_assurance.gold.dim_municipality
ORDER BY state_code, municipality_name;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_control AS
SELECT DISTINCT
    control_id,
    control_name,

    CASE
        WHEN control_id = 'CTRL-GEO-001'
            THEN 'Geography'

        WHEN control_id = 'CTRL-METHOD-001'
            THEN 'Carbon Method'

        WHEN control_id = 'CTRL-PRICE-001'
            THEN 'Price-Year'

        WHEN control_id = 'CTRL-EVID-001'
            THEN 'Evidence'

        WHEN control_id = 'CTRL-DCF-001'
            THEN 'Responsible Sourcing'

        WHEN control_id = 'CTRL-REPORT-001'
            THEN 'Reporting Gate'

        ELSE 'Other'
    END AS control_category

FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.dim_control
ORDER BY control_id;

-- COMMAND ----------

SELECT COUNT(*) AS control_count
FROM iff_esg_assurance.gold.dim_control;

-- COMMAND ----------

SELECT
    column_name,
    data_type
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'supplier_master_raw'
ORDER BY ordinal_position;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_supplier AS
SELECT DISTINCT
    TRIM(CAST(supplier_id AS STRING)) AS supplier_id,
    TRIM(CAST(supplier_name AS STRING)) AS supplier_name,
    UPPER(TRIM(CAST(country_code AS STRING))) AS country_code,
    TRIM(CAST(municipality_name AS STRING)) AS municipality_name,
    LPAD(CAST(municipality_code AS STRING), 7, '0') AS municipality_code,
    CAST(supplier_ghg_data_available AS STRING) AS supplier_ghg_data_available
FROM iff_esg_assurance.bronze.supplier_master_raw
WHERE supplier_id IS NOT NULL;

-- COMMAND ----------

SELECT COUNT(*) AS supplier_count
FROM iff_esg_assurance.gold.dim_supplier;

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

-- COMMAND ----------

SELECT COUNT(*) AS exception_count
FROM iff_esg_assurance.gold.fact_exception;

-- COMMAND ----------

SELECT COUNT(*) AS transaction_count
FROM iff_esg_assurance.gold.fact_reporting_transaction;

-- COMMAND ----------

SELECT COUNT(*) AS control_result_count
FROM iff_esg_assurance.gold.fact_control_result;

-- COMMAND ----------

SELECT
    COUNT(*) AS orphan_supplier_transactions
FROM iff_esg_assurance.gold.fact_reporting_transaction f
LEFT JOIN iff_esg_assurance.gold.dim_supplier d
    ON f.supplier_id = d.supplier_id
WHERE f.supplier_id IS NOT NULL
  AND d.supplier_id IS NULL;

-- COMMAND ----------

SELECT
    COUNT(*) AS orphan_municipality_transactions
FROM iff_esg_assurance.gold.fact_reporting_transaction f
LEFT JOIN iff_esg_assurance.gold.dim_municipality d
    ON f.municipality_code = d.municipality_code
WHERE f.municipality_code IS NOT NULL
  AND d.municipality_code IS NULL;

-- COMMAND ----------

SELECT
    COUNT(*) AS orphan_control_results
FROM iff_esg_assurance.gold.fact_control_result f
LEFT JOIN iff_esg_assurance.gold.dim_control d
    ON f.control_id = d.control_id
WHERE d.control_id IS NULL;

-- COMMAND ----------

SELECT
    supplier_id,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.dim_supplier
GROUP BY supplier_id
HAVING COUNT(*) > 1;

-- COMMAND ----------

SELECT
    municipality_code,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.dim_municipality
GROUP BY municipality_code
HAVING COUNT(*) > 1;

-- COMMAND ----------

SELECT
    control_id,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.dim_control
GROUP BY control_id
HAVING COUNT(*) > 1;

-- COMMAND ----------

SELECT 'FactReportingTransaction' AS object_name,
       COUNT(*) AS row_count
FROM iff_esg_assurance.gold.fact_reporting_transaction

UNION ALL

SELECT 'FactControlResult',
       COUNT(*)
FROM iff_esg_assurance.gold.fact_control_result

UNION ALL

SELECT 'FactException',
       COUNT(*)
FROM iff_esg_assurance.gold.fact_exception

UNION ALL

SELECT 'DimSupplier',
       COUNT(*)
FROM iff_esg_assurance.gold.dim_supplier

UNION ALL

SELECT 'DimMunicipality',
       COUNT(*)
FROM iff_esg_assurance.gold.dim_municipality

UNION ALL

SELECT 'DimControl',
       COUNT(*)
FROM iff_esg_assurance.gold.dim_control;

-- COMMAND ----------

SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT transaction_id) AS distinct_transaction_ids
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    transaction_id,
    COUNT(*) AS row_count
FROM iff_esg_assurance.gold.reporting_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, transaction_id;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.reporting_transactions
WHERE transaction_id IN (
    SELECT transaction_id
    FROM iff_esg_assurance.gold.reporting_transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
)
ORDER BY transaction_id;

-- COMMAND ----------

SELECT 'standardized' AS stage, COUNT(*) AS rows
FROM iff_esg_assurance.silver.procurement_standardized

UNION ALL

SELECT 'method_validation', COUNT(*)
FROM iff_esg_assurance.silver.scope3_method_validation

UNION ALL

SELECT 'supplier_validation', COUNT(*)
FROM iff_esg_assurance.silver.supplier_specific_validation

UNION ALL

SELECT 'method_eligibility', COUNT(*)
FROM iff_esg_assurance.silver.method_eligibility

UNION ALL

SELECT 'reporting_gate', COUNT(*)
FROM iff_esg_assurance.silver.reporting_gate

UNION ALL

SELECT 'gold_reporting', COUNT(*)
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    transaction_id,
    supplier_id,
    farm_id,
    material_id,
    invoice_date,
    spend_usd,
    COUNT(*) AS rows
FROM iff_esg_assurance.silver.procurement_standardized
WHERE transaction_id IN ('TXN-000039','TXN-000074')
GROUP BY
    transaction_id,
    supplier_id,
    farm_id,
    material_id,
    invoice_date,
    spend_usd
ORDER BY transaction_id;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.silver.procurement_standardized
WHERE transaction_id IN ('TXN-000039','TXN-000074')
ORDER BY transaction_id;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.procurement_standardized AS

WITH cleaned AS (
    SELECT
        CAST(transaction_id AS STRING) AS transaction_id,
        NULLIF(TRIM(CAST(supplier_id AS STRING)), '') AS supplier_id,
        CAST(material_id AS STRING) AS material_id,
        CAST(invoice_date AS DATE) AS invoice_date,
        CAST(reporting_year AS INT) AS reporting_year,
        UPPER(TRIM(CAST(country_code AS STRING))) AS country_code,
        TRIM(CAST(municipality_name AS STRING)) AS municipality_name,
        LPAD(CAST(municipality_code AS STRING),7,'0') AS municipality_code,
        CAST(farm_id AS STRING) AS farm_id,
        CAST(latitude AS DOUBLE) AS latitude,
        CAST(longitude AS DOUBLE) AS longitude,
        CAST(quantity AS DOUBLE) AS quantity,
        CAST(quantity_unit AS STRING) AS quantity_unit,
        CAST(spend_local AS DOUBLE) AS spend_local,
        CAST(currency AS STRING) AS currency,
        CAST(fx_rate AS DOUBLE) AS fx_rate,
        CAST(spend_usd AS DOUBLE) AS spend_usd,
        CAST(emissions_method AS STRING) AS emissions_method,
        CAST(emission_factor_id AS STRING) AS emission_factor_id,
        CAST(factor_value AS DOUBLE) AS factor_value,
        CAST(spend_price_year AS INT) AS spend_price_year,
        CAST(price_year_adjustment_factor AS DOUBLE)
            AS price_year_adjustment_factor,

        CAST(spend_usd_2022 AS DOUBLE)
            AS excel_spend_usd_2022,

        CAST(spend_based_emissions_tco2e AS DOUBLE)
            AS excel_spend_based_emissions_tco2e,

        CAST(dcf_status AS STRING) AS dcf_status,
        CAST(traceability_level AS STRING) AS traceability_level,
        CAST(evidence_id AS STRING) AS evidence_id,
        CAST(manual_override_flag AS BOOLEAN) AS manual_override_flag,
        CAST(source_system AS STRING) AS source_system,
        CAST(data_version AS STRING) AS data_version,

        CAST(geo_master_match AS STRING)
            AS excel_geo_master_match,

        CAST(method_validation_status AS STRING)
            AS excel_method_validation_status,

        CAST(method_eligibility AS STRING)
            AS excel_method_eligibility,

        CAST(final_emissions_tco2e AS DOUBLE)
            AS excel_final_emissions_tco2e,

        CAST(supplier_ghg_available AS STRING)
            AS excel_supplier_ghg_available,

        CAST(supplier_ghg_evidence_status AS STRING)
            AS excel_supplier_ghg_evidence_status,

        CAST(supplier_specific_validation AS STRING)
            AS excel_supplier_specific_validation,

        CAST(ghg_evidence_found AS STRING)
            AS excel_ghg_evidence_found,

        CAST(reporting_eligibility AS STRING)
            AS excel_reporting_eligibility,

        CAST(reporting_emissions_tco2e AS DOUBLE)
            AS excel_reporting_emissions_tco2e

    FROM iff_esg_assurance.bronze.procurement_transactions_raw
)

SELECT
    CONCAT(
        'REC-',
        LPAD(
            ROW_NUMBER() OVER (
                ORDER BY
                    transaction_id,
                    supplier_id,
                    invoice_date,
                    material_id,
                    farm_id,
                    spend_usd,
                    quantity
            ),
            3,
            '0'
        )
    ) AS source_record_id,

    *

FROM cleaned;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.procurement_standardized AS

WITH cleaned AS (
    SELECT
        CAST(transaction_id AS STRING) AS transaction_id,
        NULLIF(TRIM(CAST(supplier_id AS STRING)), '') AS supplier_id,
        CAST(material_id AS STRING) AS material_id,
        CAST(invoice_date AS DATE) AS invoice_date,
        CAST(reporting_year AS INT) AS reporting_year,
        UPPER(TRIM(CAST(country_code AS STRING))) AS country_code,
        TRIM(CAST(municipality_name AS STRING)) AS municipality_name,
        LPAD(CAST(municipality_code AS STRING),7,'0') AS municipality_code,
        CAST(farm_id AS STRING) AS farm_id,
        CAST(latitude AS DOUBLE) AS latitude,
        CAST(longitude AS DOUBLE) AS longitude,
        CAST(quantity AS DOUBLE) AS quantity,
        CAST(quantity_unit AS STRING) AS quantity_unit,
        CAST(spend_local AS DOUBLE) AS spend_local,
        CAST(currency AS STRING) AS currency,
        CAST(fx_rate AS DOUBLE) AS fx_rate,
        CAST(spend_usd AS DOUBLE) AS spend_usd,
        CAST(emissions_method AS STRING) AS emissions_method,
        CAST(emission_factor_id AS STRING) AS emission_factor_id,
        CAST(factor_value AS DOUBLE) AS factor_value,
        CAST(spend_price_year AS INT) AS spend_price_year,
        CAST(price_year_adjustment_factor AS DOUBLE) AS price_year_adjustment_factor,

        CAST(spend_usd_2022 AS DOUBLE) AS excel_spend_usd_2022,
        CAST(spend_based_emissions_tco2e AS DOUBLE) AS excel_spend_based_emissions_tco2e,

        CAST(dcf_status AS STRING) AS dcf_status,
        CAST(traceability_level AS STRING) AS traceability_level,
        CAST(evidence_id AS STRING) AS evidence_id,
        CAST(manual_override_flag AS BOOLEAN) AS manual_override_flag,
        CAST(source_system AS STRING) AS source_system,
        CAST(data_version AS STRING) AS data_version,

        CAST(geo_master_match AS STRING) AS excel_geo_master_match,
        CAST(method_validation_status AS STRING) AS excel_method_validation_status,
        CAST(method_eligibility AS STRING) AS excel_method_eligibility,
        CAST(final_emissions_tco2e AS DOUBLE) AS excel_final_emissions_tco2e,
        CAST(supplier_ghg_available AS STRING) AS excel_supplier_ghg_available,
        CAST(supplier_ghg_evidence_status AS STRING) AS excel_supplier_ghg_evidence_status,
        CAST(supplier_specific_validation AS STRING) AS excel_supplier_specific_validation,
        CAST(ghg_evidence_found AS STRING) AS excel_ghg_evidence_found,
        CAST(reporting_eligibility AS STRING) AS excel_reporting_eligibility,
        CAST(reporting_emissions_tco2e AS DOUBLE) AS excel_reporting_emissions_tco2e

    FROM iff_esg_assurance.bronze.procurement_transactions_raw
)

SELECT
    CONCAT(
        'REC-',
        LPAD(
            ROW_NUMBER() OVER (
                ORDER BY
                    transaction_id,
                    supplier_id,
                    invoice_date,
                    material_id,
                    farm_id,
                    spend_usd,
                    quantity
            ),
            3,
            '0'
        )
    ) AS source_record_id,

    *

FROM cleaned;

-- COMMAND ----------

SELECT
    COUNT(*) AS source_records,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.silver.procurement_standardized;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.transaction_id_validation AS
SELECT
    p.*,

    COUNT(*) OVER (
        PARTITION BY transaction_id
    ) AS transaction_id_occurrences,

    CASE
        WHEN transaction_id IS NULL
        THEN 'FAIL - MISSING ID'

        WHEN COUNT(*) OVER (
            PARTITION BY transaction_id
        ) > 1
        THEN 'FAIL - DUPLICATE ID'

        ELSE 'PASS'
    END AS transaction_id_validation

FROM iff_esg_assurance.silver.procurement_standardized p;

-- COMMAND ----------

SELECT
    transaction_id,
    source_record_id,
    supplier_id,
    material_id,
    invoice_date,
    transaction_id_occurrences,
    transaction_id_validation
FROM iff_esg_assurance.silver.transaction_id_validation
WHERE transaction_id_validation <> 'PASS'
ORDER BY transaction_id, source_record_id;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.geo_validation AS
SELECT
    p.source_record_id,
    p.transaction_id,
    p.supplier_id,
    p.farm_id,

    p.municipality_code AS transaction_municipality_code,
    q.municipality_code AS qgis_municipality_code,

    p.latitude AS transaction_latitude,
    p.longitude AS transaction_longitude,
    q.latitude AS qgis_latitude,
    q.longitude AS qgis_longitude,

    CASE
        WHEN p.supplier_id IS NULL THEN 'REVIEW'
        WHEN q.supplier_id IS NULL THEN 'REVIEW'
        WHEN p.municipality_code IS NULL THEN 'REVIEW'
        WHEN q.municipality_code IS NULL THEN 'REVIEW'
        WHEN p.municipality_code = q.municipality_code THEN 'PASS'
        ELSE 'REVIEW'
    END AS geo_master_match

FROM iff_esg_assurance.silver.procurement_standardized p

LEFT JOIN iff_esg_assurance.silver.qgis_farm_reference_standardized q
    ON p.supplier_id = q.supplier_id;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records
FROM iff_esg_assurance.silver.geo_validation;

-- COMMAND ----------

SELECT 'FactReportingTransaction' AS object_name, COUNT(*) AS row_count
FROM iff_esg_assurance.gold.fact_reporting_transaction

UNION ALL

SELECT 'FactControlResult', COUNT(*)
FROM iff_esg_assurance.gold.fact_control_result

UNION ALL

SELECT 'FactException', COUNT(*)
FROM iff_esg_assurance.gold.fact_exception

UNION ALL

SELECT 'DimSupplier', COUNT(*)
FROM iff_esg_assurance.gold.dim_supplier

UNION ALL

SELECT 'DimMunicipality', COUNT(*)
FROM iff_esg_assurance.gold.dim_municipality

UNION ALL

SELECT 'DimControl', COUNT(*)
FROM iff_esg_assurance.gold.dim_control;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.fact_reporting_transaction AS
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    municipality_code,
    farm_id,
    material_id,
    reporting_year,
    invoice_date,

    quantity,
    quantity_unit,
    spend_usd,

    emissions_method,
    governed_emission_factor_id,
    governed_factor_value,
    governed_spend_usd_2022,
    governed_spend_based_emissions_tco2e,

    governed_method_eligibility,
    geo_master_match,
    dcf_status,
    manual_override_flag,

    governed_reporting_eligibility,

    governed_final_emissions_tco2e,
    governed_reporting_emissions_tco2e

FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.fact_reporting_transaction;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS unique_source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.fact_reporting_transaction;

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

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.fact_control_result AS
SELECT
    source_record_id,
    transaction_id,
    supplier_id,
    control_id,
    control_result,
    exception_reason
FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS source_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids,
    COUNT(DISTINCT control_id) AS controls
FROM iff_esg_assurance.gold.fact_control_result;

-- COMMAND ----------

SELECT 'procurement_standardized' AS stage,
       COUNT(*) AS rows,
       COUNT(DISTINCT source_record_id) AS unique_source_records
FROM iff_esg_assurance.silver.procurement_standardized

UNION ALL

SELECT 'geo_validation',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.silver.geo_validation

UNION ALL

SELECT 'scope3_method_validation',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.silver.scope3_method_validation

UNION ALL

SELECT 'supplier_specific_validation',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.silver.supplier_specific_validation

UNION ALL

SELECT 'method_eligibility',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.silver.method_eligibility

UNION ALL

SELECT 'reporting_gate',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.silver.reporting_gate

UNION ALL

SELECT 'reporting_transactions',
       COUNT(*),
       COUNT(DISTINCT source_record_id)
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    COUNT(*) AS source_records,
    COUNT(DISTINCT source_record_id) AS technical_records,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM iff_esg_assurance.gold.reporting_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- COMMAND ----------

SELECT
    governed_reporting_eligibility,
    COUNT(*) AS records
FROM iff_esg_assurance.gold.reporting_transactions
GROUP BY governed_reporting_eligibility;

-- COMMAND ----------

SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN governed_reporting_eligibility='ELIGIBLE' THEN 1 ELSE 0 END) AS eligible,
    SUM(CASE WHEN governed_reporting_eligibility='REVIEW' THEN 1 ELSE 0 END) AS review,
    SUM(CASE WHEN governed_reporting_eligibility='HOLD' THEN 1 ELSE 0 END) AS hold
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT
    SUM(governed_final_emissions_tco2e) AS calculated_emissions,
    SUM(governed_reporting_emissions_tco2e) AS reporting_emissions,
    SUM(governed_final_emissions_tco2e)
      - COALESCE(SUM(governed_reporting_emissions_tco2e),0)
      AS excluded_emissions
FROM iff_esg_assurance.gold.reporting_transactions;

-- COMMAND ----------

SELECT COUNT(*) AS gate_failures
FROM iff_esg_assurance.gold.reporting_transactions
WHERE governed_reporting_eligibility <> 'ELIGIBLE'
  AND governed_reporting_emissions_tco2e IS NOT NULL
  AND governed_reporting_emissions_tco2e <> 0;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.reporting_reconciliation;

-- COMMAND ----------

SELECT
    COUNT(*) AS total_exceptions
FROM iff_esg_assurance.gold.exception_register;

-- COMMAND ----------

SELECT
    exception_type,
    COUNT(*) AS exceptions
FROM iff_esg_assurance.gold.exception_register
GROUP BY exception_type
ORDER BY exceptions DESC;

-- COMMAND ----------

SELECT
    (SELECT COUNT(*)
     FROM iff_esg_assurance.gold.reporting_transactions
     WHERE governed_reporting_eligibility <> 'ELIGIBLE') AS noneligible_records,

    (SELECT COUNT(*)
     FROM iff_esg_assurance.gold.exception_register) AS exception_records;

-- COMMAND ----------

SELECT
    workpaper_id,
    control,
    population,
    test_result,
    exception_count
FROM iff_esg_assurance.gold.assurance_workpaper
ORDER BY workpaper_id;

-- COMMAND ----------

SELECT
    test_result,
    COUNT(*) AS tests
FROM iff_esg_assurance.gold.assurance_workpaper
GROUP BY test_result;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.assurance_readiness_final;

-- COMMAND ----------

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT source_record_id) AS source_records,
    COUNT(DISTINCT control_id) AS controls
FROM iff_esg_assurance.gold.control_results;

-- COMMAND ----------

SELECT
    source_record_id,
    COUNT(*) AS controls_per_record
FROM iff_esg_assurance.gold.control_results
GROUP BY source_record_id
HAVING COUNT(*) <> 6;

-- COMMAND ----------

SELECT 'FactReportingTransaction' AS object_name, COUNT(*) AS rows
FROM iff_esg_assurance.gold.fact_reporting_transaction

UNION ALL
SELECT 'FactControlResult', COUNT(*)
FROM iff_esg_assurance.gold.fact_control_result

UNION ALL
SELECT 'FactException', COUNT(*)
FROM iff_esg_assurance.gold.fact_exception

UNION ALL
SELECT 'DimSupplier', COUNT(*)
FROM iff_esg_assurance.gold.dim_supplier

UNION ALL
SELECT 'DimMunicipality', COUNT(*)
FROM iff_esg_assurance.gold.dim_municipality

UNION ALL
SELECT 'DimControl', COUNT(*)
FROM iff_esg_assurance.gold.dim_control;

-- COMMAND ----------

SELECT COUNT(*) AS supplier_orphans
FROM iff_esg_assurance.gold.fact_reporting_transaction f
LEFT JOIN iff_esg_assurance.gold.dim_supplier d
    ON f.supplier_id = d.supplier_id
WHERE f.supplier_id IS NOT NULL
  AND d.supplier_id IS NULL;

-- COMMAND ----------

SELECT COUNT(*) AS control_orphans
FROM iff_esg_assurance.gold.fact_control_result f
LEFT JOIN iff_esg_assurance.gold.dim_control d
    ON f.control_id = d.control_id
WHERE d.control_id IS NULL;

-- COMMAND ----------

SELECT COUNT(*) AS supplier_orphans
FROM iff_esg_assurance.gold.fact_reporting_transaction f
LEFT JOIN iff_esg_assurance.gold.dim_supplier d
    ON f.supplier_id = d.supplier_id
WHERE f.supplier_id IS NOT NULL
  AND d.supplier_id IS NULL;

-- COMMAND ----------

SELECT COUNT(*) AS municipality_orphans
FROM iff_esg_assurance.gold.fact_reporting_transaction f
LEFT JOIN iff_esg_assurance.gold.dim_municipality d
    ON f.municipality_code = d.municipality_code
WHERE f.municipality_code IS NOT NULL
  AND d.municipality_code IS NULL;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_control_result AS
SELECT * FROM VALUES
    ('PASS',1),
    ('REVIEW',2),
    ('FAIL',3),
    ('N/A',4)
AS t(control_result, sort_order);

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.dim_control_result
ORDER BY sort_order;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_control_result AS
SELECT * FROM VALUES
    ('PASS', 1),
    ('REVIEW', 2),
    ('FAIL', 3),
    ('N/A', 4)
AS t(control_result, sort_order);

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.dim_control_result
ORDER BY sort_order;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.dim_control_result AS
SELECT * FROM VALUES
    ('PASS', 1),
    ('REVIEW', 2),
    ('FAIL', 3),
    ('N/A', 4)
AS t(control_result, sort_order);

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.dim_control_result
ORDER BY sort_order;

-- COMMAND ----------

SELECT
    COUNT(*) AS dim_rows,
    COUNT(DISTINCT supplier_id) AS unique_suppliers
FROM iff_esg_assurance.gold.dim_supplier;

-- COMMAND ----------

SELECT
    COUNT(*) AS source_rows,
    COUNT(DISTINCT supplier_id) AS unique_suppliers
FROM iff_esg_assurance.bronze.supplier_master_raw;
