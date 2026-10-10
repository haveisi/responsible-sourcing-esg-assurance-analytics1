-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.silver.procurement_standardized AS
SELECT
    CAST(transaction_id AS STRING) AS transaction_id,
    NULLIF(TRIM(CAST(supplier_id AS STRING)), '') AS supplier_id,
    CAST(material_id AS STRING) AS material_id,
    CAST(invoice_date AS DATE) AS invoice_date,
    CAST(reporting_year AS INT) AS reporting_year,
    UPPER(TRIM(CAST(country_code AS STRING))) AS country_code,
    TRIM(CAST(municipality_name AS STRING)) AS municipality_name,
    LPAD(CAST(municipality_code AS STRING), 7, '0') AS municipality_code,
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

FROM iff_esg_assurance.bronze.procurement_transactions_raw;

-- COMMAND ----------

SELECT COUNT(*) AS total_rows
FROM iff_esg_assurance.silver.procurement_standardized;

-- COMMAND ----------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS distinct_transactions,
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS missing_transaction_id,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS missing_supplier_id
FROM iff_esg_assurance.silver.procurement_standardized;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.silver.method_eligibility;