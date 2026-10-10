-- Databricks notebook source
-- MAGIC %python
-- MAGIC import pandas as pd
-- MAGIC
-- MAGIC file_path = "/Volumes/iff_esg_assurance/bronze/source_files/IFF_Synthetic_Supplier_Procurement_Data_Step4_Validated_All3Sources.xlsx"

-- COMMAND ----------

-- MAGIC %python
-- MAGIC %pip install openpyxl

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.library.restartPython()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import pandas as pd
-- MAGIC
-- MAGIC file_path = "/Volumes/iff_esg_assurance/bronze/source_files/IFF_Synthetic_Supplier_Procurement_Data_Step4_Validated_All3Sources.xlsx"

-- COMMAND ----------

-- MAGIC %python
-- MAGIC xls = pd.ExcelFile(file_path, engine="openpyxl")
-- MAGIC xls.sheet_names

-- COMMAND ----------

-- MAGIC %python
-- MAGIC supplier_master = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Supplier_Master",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC procurement = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Procurement_Transactions",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC evidence = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Evidence_Register",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC factors = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Emission_Factor_Master",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC municipality = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Municipality_Reference",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC qgis_farms = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="QGIS_Farm_Reference",
-- MAGIC     engine="openpyxl"
-- MAGIC )

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print("Supplier_Master:", supplier_master.shape)
-- MAGIC print("Procurement_Transactions:", procurement.shape)
-- MAGIC print("Evidence_Register:", evidence.shape)
-- MAGIC print("Emission_Factor_Master:", factors.shape)
-- MAGIC print("Municipality_Reference:", municipality.shape)
-- MAGIC print("QGIS_Farm_Reference:", qgis_farms.shape)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(procurement.columns.tolist())

-- COMMAND ----------

-- MAGIC %python
-- MAGIC spark.createDataFrame(supplier_master).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.supplier_master_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(procurement).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.procurement_transactions_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(evidence).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.evidence_register_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(factors).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.emission_factor_master_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(municipality).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.municipality_reference_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(qgis_farms).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.qgis_farm_reference_raw"
-- MAGIC )

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.library.restartPython()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import pandas as pd
-- MAGIC
-- MAGIC file_path = "/Volumes/iff_esg_assurance/bronze/source_files/IFF_Synthetic_Supplier_Procurement_Data_Step4_Validated_All3Sources.xlsx"
-- MAGIC
-- MAGIC supplier_master = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Supplier_Master",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC procurement = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Procurement_Transactions",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC evidence = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Evidence_Register",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC factors = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Emission_Factor_Master",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC municipality = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="Municipality_Reference",
-- MAGIC     engine="openpyxl"
-- MAGIC )
-- MAGIC
-- MAGIC qgis_farms = pd.read_excel(
-- MAGIC     file_path,
-- MAGIC     sheet_name="QGIS_Farm_Reference",
-- MAGIC     engine="openpyxl"
-- MAGIC )

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import re
-- MAGIC
-- MAGIC def clean_columns(df):
-- MAGIC     df = df.copy()
-- MAGIC
-- MAGIC     df.columns = [
-- MAGIC         re.sub(r'[^A-Za-z0-9_]', '_', str(col).strip())
-- MAGIC         for col in df.columns
-- MAGIC     ]
-- MAGIC
-- MAGIC     # collapse repeated underscores
-- MAGIC     df.columns = [
-- MAGIC         re.sub(r'_+', '_', col).strip('_')
-- MAGIC         for col in df.columns
-- MAGIC     ]
-- MAGIC
-- MAGIC     return df

-- COMMAND ----------

-- MAGIC %python
-- MAGIC supplier_master = clean_columns(supplier_master)
-- MAGIC procurement = clean_columns(procurement)
-- MAGIC evidence = clean_columns(evidence)
-- MAGIC factors = clean_columns(factors)
-- MAGIC municipality = clean_columns(municipality)
-- MAGIC qgis_farms = clean_columns(qgis_farms)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(qgis_farms.columns.tolist())

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(supplier_master.columns.tolist())

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import re
-- MAGIC
-- MAGIC def clean_columns(df):
-- MAGIC     df = df.copy()
-- MAGIC
-- MAGIC     cleaned = []
-- MAGIC
-- MAGIC     for col in df.columns:
-- MAGIC         col = str(col).strip().lower()
-- MAGIC         col = re.sub(r'[^a-z0-9_]', '_', col)
-- MAGIC         col = re.sub(r'_+', '_', col)
-- MAGIC         col = col.strip('_')
-- MAGIC         cleaned.append(col)
-- MAGIC
-- MAGIC     df.columns = cleaned
-- MAGIC
-- MAGIC     return df

-- COMMAND ----------

-- MAGIC %python
-- MAGIC supplier_master = clean_columns(supplier_master)
-- MAGIC procurement = clean_columns(procurement)
-- MAGIC evidence = clean_columns(evidence)
-- MAGIC factors = clean_columns(factors)
-- MAGIC municipality = clean_columns(municipality)
-- MAGIC qgis_farms = clean_columns(qgis_farms)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC for name, df in {
-- MAGIC     "supplier_master": supplier_master,
-- MAGIC     "procurement": procurement,
-- MAGIC     "evidence": evidence,
-- MAGIC     "factors": factors,
-- MAGIC     "municipality": municipality,
-- MAGIC     "qgis_farms": qgis_farms
-- MAGIC }.items():
-- MAGIC     print(name)
-- MAGIC     print(df.columns.tolist())
-- MAGIC     print()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC spark.createDataFrame(supplier_master).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.supplier_master_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(procurement).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.procurement_transactions_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(evidence).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.evidence_register_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(factors).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.emission_factor_master_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(municipality).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.municipality_reference_raw"
-- MAGIC )
-- MAGIC
-- MAGIC spark.createDataFrame(qgis_farms).write.mode("overwrite").saveAsTable(
-- MAGIC     "iff_esg_assurance.bronze.qgis_farm_reference_raw"
-- MAGIC )

-- COMMAND ----------

SHOW TABLES IN iff_esg_assurance.bronze;


-- COMMAND ----------

SELECT 'supplier_master_raw' AS table_name, COUNT(*) AS row_count
FROM iff_esg_assurance.bronze.supplier_master_raw

UNION ALL

SELECT 'procurement_transactions_raw', COUNT(*)
FROM iff_esg_assurance.bronze.procurement_transactions_raw

UNION ALL

SELECT 'evidence_register_raw', COUNT(*)
FROM iff_esg_assurance.bronze.evidence_register_raw

UNION ALL

SELECT 'emission_factor_master_raw', COUNT(*)
FROM iff_esg_assurance.bronze.emission_factor_master_raw

UNION ALL

SELECT 'municipality_reference_raw', COUNT(*)
FROM iff_esg_assurance.bronze.municipality_reference_raw

UNION ALL

SELECT 'qgis_farm_reference_raw', COUNT(*)
FROM iff_esg_assurance.bronze.qgis_farm_reference_raw;

-- COMMAND ----------

DESCRIBE TABLE iff_esg_assurance.bronze.supplier_master_raw;