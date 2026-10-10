-- Databricks notebook source
DESCRIBE TABLE iff_esg_assurance.bronze.qgis_farm_reference_raw;

-- COMMAND ----------

SELECT
    supplier_id,
    farm_id,
    cd_mun,
    latitude,
    longitude
FROM iff_esg_assurance.bronze.qgis_farm_reference_raw
LIMIT 10;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.qgis_farm_reference_standardized AS
SELECT
    TRIM(CAST(supplier_id AS STRING)) AS supplier_id,
    TRIM(CAST(farm_id AS STRING)) AS farm_id,
    LPAD(CAST(cd_mun AS STRING), 7, '0') AS municipality_code,
    CAST(latitude AS DOUBLE) AS latitude,
    CAST(longitude AS DOUBLE) AS longitude
FROM iff_esg_assurance.bronze.qgis_farm_reference_raw;

-- COMMAND ----------

SELECT COUNT(*) AS rows
FROM iff_esg_assurance.silver.qgis_farm_reference_standardized;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.silver.geo_validation AS
SELECT
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
    geo_master_match,
    COUNT(*) AS transaction_count
FROM iff_esg_assurance.silver.geo_validation
GROUP BY geo_master_match
ORDER BY geo_master_match;

-- COMMAND ----------

SELECT
    p.transaction_id,
    p.supplier_id,
    p.excel_geo_master_match,
    g.geo_master_match AS databricks_geo_master_match,

    CASE
        WHEN COALESCE(p.excel_geo_master_match,'NULL')
           = COALESCE(g.geo_master_match,'NULL')
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS qa_result

FROM iff_esg_assurance.silver.procurement_standardized p

LEFT JOIN iff_esg_assurance.silver.geo_validation g
    ON p.transaction_id = g.transaction_id;

-- COMMAND ----------

SELECT
    qa_result,
    COUNT(*) AS records
FROM (
    SELECT
        p.transaction_id,

        CASE
            WHEN COALESCE(p.excel_geo_master_match,'NULL')
               = COALESCE(g.geo_master_match,'NULL')
            THEN 'MATCH'
            ELSE 'MISMATCH'
        END AS qa_result

    FROM iff_esg_assurance.silver.procurement_standardized p

    LEFT JOIN iff_esg_assurance.silver.geo_validation g
        ON p.transaction_id = g.transaction_id
)
GROUP BY qa_result;

-- COMMAND ----------

SELECT
    p.transaction_id,
    p.supplier_id,
    p.farm_id,
    p.municipality_code,
    p.excel_geo_master_match,
    g.qgis_municipality_code,
    g.geo_master_match

FROM iff_esg_assurance.silver.procurement_standardized p

LEFT JOIN iff_esg_assurance.silver.geo_validation g
    ON p.transaction_id = g.transaction_id

WHERE COALESCE(p.excel_geo_master_match,'NULL')
   <> COALESCE(g.geo_master_match,'NULL');

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.silver.geo_validation;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.silver.method_eligibility;

-- COMMAND ----------

SELECT column_name
FROM iff_esg_assurance.information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'method_eligibility'
  AND column_name = 'source_record_id';