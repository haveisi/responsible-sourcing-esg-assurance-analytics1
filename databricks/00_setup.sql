-- Databricks notebook source
CREATE CATALOG IF NOT EXISTS iff_esg_assurance;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS iff_esg_assurance.bronze;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS iff_esg_assurance.silver;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS iff_esg_assurance.gold;

-- COMMAND ----------

SHOW SCHEMAS IN iff_esg_assurance;

-- COMMAND ----------

create volume if not exists iff_esg_assurance.bronze.source_files;