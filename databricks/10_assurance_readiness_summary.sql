-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.assurance_readiness_summary AS
SELECT
    r.total_transactions,

    r.reporting_eligible_transactions AS reporting_eligible,

    r.review_transactions AS review,

    r.hold_transactions AS hold,

    r.reporting_emissions_tco2e,

    r.excluded_emissions_tco2e,

    (
        SELECT COUNT(*)
        FROM iff_esg_assurance.gold.exception_register
        WHERE closure_status <> 'CLOSED'
    ) AS open_exceptions,

    (
        SELECT COUNT(*)
        FROM iff_esg_assurance.gold.assurance_workpaper
        WHERE test_result = 'PASS'
    ) AS control_tests_passed,

    (
        SELECT COUNT(*)
        FROM iff_esg_assurance.gold.assurance_workpaper
        WHERE test_result = 'FAIL'
    ) AS control_tests_failed,

    CASE
        WHEN r.reconciliation_status <> 'PASS'
        THEN 'NOT READY'

        WHEN (
            SELECT COUNT(*)
            FROM iff_esg_assurance.gold.assurance_workpaper
            WHERE test_result = 'FAIL'
        ) > 0
        THEN 'NOT READY'

        WHEN (
            SELECT COUNT(*)
            FROM iff_esg_assurance.gold.exception_register
            WHERE severity = 'High'
              AND closure_status <> 'CLOSED'
        ) > 0
        THEN 'PARTIALLY READY'

        ELSE 'READY'
    END AS readiness_level

FROM iff_esg_assurance.gold.reporting_reconciliation r;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.assurance_readiness_summary;

-- COMMAND ----------

CREATE OR REPLACE TABLE iff_esg_assurance.gold.assurance_readiness_final AS
SELECT
    *,

    CASE
        WHEN readiness_level = 'READY'
        THEN
        'READY - Key controls operated effectively, reconciliation passed, and no material open exceptions remain.'

        WHEN readiness_level = 'PARTIALLY READY'
        THEN
        'PARTIALLY READY - Key controls and reconciliation are operating, but unresolved high-severity exceptions remain and require remediation before full assurance reliance.'

        ELSE
        'NOT READY - Material control or reconciliation failures require remediation before assurance reliance.'
    END AS management_conclusion

FROM iff_esg_assurance.gold.assurance_readiness_summary;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.assurance_readiness_final;

-- COMMAND ----------

SELECT
    *,
    ROUND(
        100.0 * reporting_eligible / total_transactions,
        1
    ) AS reporting_eligibility_pct

FROM iff_esg_assurance.gold.assurance_readiness_final;

-- COMMAND ----------

SELECT
    *,
    ROUND(
        100.0 * reporting_emissions_tco2e
        /
        NULLIF(
            reporting_emissions_tco2e + excluded_emissions_tco2e,
            0
        ),
        1
    ) AS emissions_inclusion_pct

FROM iff_esg_assurance.gold.assurance_readiness_final;

-- COMMAND ----------

CREATE OR REPLACE VIEW iff_esg_assurance.gold.vw_assurance_executive AS
SELECT
    total_transactions,
    reporting_eligible,
    review,
    hold,

    ROUND(
        100.0 * reporting_eligible / total_transactions,
        1
    ) AS reporting_eligibility_pct,

    reporting_emissions_tco2e,
    excluded_emissions_tco2e,

    ROUND(
        100.0 * reporting_emissions_tco2e
        /
        NULLIF(
            reporting_emissions_tco2e + excluded_emissions_tco2e,
            0
        ),
        1
    ) AS emissions_inclusion_pct,

    open_exceptions,
    control_tests_passed,
    control_tests_failed,
    readiness_level,
    management_conclusion

FROM iff_esg_assurance.gold.assurance_readiness_final;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.vw_assurance_executive;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.assurance_readiness_final;
