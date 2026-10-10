-- Databricks notebook source
CREATE OR REPLACE TABLE iff_esg_assurance.gold.assurance_workpaper AS

-- WP-001 Geography
SELECT
    'WP-001' AS workpaper_id,
    'Supplier geography is valid' AS assertion,
    'Supplier/farm linked to wrong municipality' AS risk,
    'geo_master_match' AS control,
    'Compare farm municipality to governed municipality master' AS test_procedure,

    COUNT(*) AS population,

    'Supplier_Master + QGIS_Farm_Reference + Municipality_Reference' AS evidence_source,

    CASE
        WHEN
            SUM(CASE WHEN geo_master_match <> 'PASS' THEN 1 ELSE 0 END)
            =
            (
                SELECT COUNT(*)
                FROM iff_esg_assurance.gold.exception_register
                WHERE exception_type = 'GEO'
            )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result,

    (
        SELECT COUNT(*)
        FROM iff_esg_assurance.gold.exception_register
        WHERE exception_type = 'GEO'
    ) AS exception_count,

    CASE
        WHEN (
            SELECT COUNT(*)
            FROM iff_esg_assurance.gold.exception_register
            WHERE exception_type = 'GEO'
        ) = 0
        THEN 'None'
        ELSE 'Exception_Register - GEO'
    END AS exception_reference,

    'Project Reviewer' AS reviewer,
    DATE('2026-10-09') AS review_date,

    CASE
        WHEN
            SUM(CASE WHEN geo_master_match <> 'PASS' THEN 1 ELSE 0 END)
            =
            (
                SELECT COUNT(*)
                FROM iff_esg_assurance.gold.exception_register
                WHERE exception_type = 'GEO'
            )
        THEN 'PASS - Geography control operated as designed; identified exceptions were routed for remediation.'
        ELSE 'FAIL - Geography control did not reconcile to the exception register.'
    END AS conclusion

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- WP-002 Spend-based factor validation
SELECT
    'WP-002',
    'Spend-based emissions use approved factors',
    'Wrong or missing emission factor',
    'method_validation_status',
    'Verify factor ID, factor value, factor status, year, and material mapping',

    SUM(CASE WHEN emissions_method = 'Spend-based' THEN 1 ELSE 0 END),

    'Procurement_Transactions + Emission_Factor_Master',

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND method_validation_status <> 'PASS'
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,

    SUM(
        CASE
            WHEN emissions_method = 'Spend-based'
             AND method_validation_status <> 'PASS'
            THEN 1 ELSE 0
        END
    ),

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND method_validation_status <> 'PASS'
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'None'
        ELSE 'Spend-based method validation exceptions'
    END,

    'Project Reviewer',
    DATE('2026-10-09'),

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND method_validation_status <> 'PASS'
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS - All spend-based transactions used valid governed emission factors.'
        ELSE 'FAIL - One or more spend-based transactions failed factor validation.'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- WP-003 Price-year alignment
SELECT
    'WP-003',
    'EPA spend factors use compatible price year',
    '2025 spend multiplied directly by a 2022-dollar emission factor',
    'price-year adjustment control',
    'Verify 2025 spend is converted to 2022-dollar basis before emissions calculation',

    SUM(CASE WHEN emissions_method = 'Spend-based' THEN 1 ELSE 0 END),

    'Procurement_Transactions + Price_Year_Reference',

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND (
                     governed_spend_usd_2022 IS NULL
                     OR ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
                 )
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,

    SUM(
        CASE
            WHEN emissions_method = 'Spend-based'
             AND (
                 governed_spend_usd_2022 IS NULL
                 OR ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
             )
            THEN 1 ELSE 0
        END
    ),

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND (
                     governed_spend_usd_2022 IS NULL
                     OR ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
                 )
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'None'
        ELSE 'Price-year validation exceptions'
    END,

    'Project Reviewer',
    DATE('2026-10-09'),

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Spend-based'
                 AND (
                     governed_spend_usd_2022 IS NULL
                     OR ABS(governed_price_year_adjustment_factor - 0.92053) > 0.000001
                 )
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS - All spend-based transactions were aligned to the 2022-dollar factor basis.'
        ELSE 'FAIL - Price-year alignment exceptions remain.'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- WP-004 Supplier evidence
SELECT
    'WP-004',
    'Supplier-specific emissions rely on acceptable evidence',
    'Unverified supplier report is used as assurance-ready evidence',
    'supplier GHG evidence validation',
    'Test supplier GHG evidence for verified and approved status',

    SUM(CASE WHEN emissions_method = 'Supplier-specific' THEN 1 ELSE 0 END),

    'Evidence_Register + Supplier_Master',

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Supplier-specific'
                 AND governed_method_eligibility = 'ELIGIBLE'
                 AND supplier_specific_validation <> 'PASS'
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,

    (
        SELECT COUNT(*)
        FROM iff_esg_assurance.gold.exception_register
        WHERE exception_type = 'EVIDENCE'
    ),

    CASE
        WHEN (
            SELECT COUNT(*)
            FROM iff_esg_assurance.gold.exception_register
            WHERE exception_type = 'EVIDENCE'
        ) = 0
        THEN 'None'
        ELSE 'Exception_Register - EVIDENCE'
    END,

    'Project Reviewer',
    DATE('2026-10-09'),

    CASE
        WHEN SUM(
            CASE
                WHEN emissions_method = 'Supplier-specific'
                 AND governed_method_eligibility = 'ELIGIBLE'
                 AND supplier_specific_validation <> 'PASS'
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS - Unverified supplier evidence was prevented from becoming reporting-eligible.'
        ELSE 'FAIL - Unsupported supplier-specific data entered the eligible population.'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- WP-005 Reporting gate
SELECT
    'WP-005',
    'Only controlled transactions enter reporting',
    'HOLD or REVIEW records are included in reporting emissions',
    'reporting_eligibility gate',
    'Test that non-eligible records have no reporting emissions',

    COUNT(*),

    'Reporting_Transactions',

    CASE
        WHEN SUM(
            CASE
                WHEN governed_reporting_eligibility <> 'ELIGIBLE'
                 AND governed_reporting_emissions_tco2e IS NOT NULL
                 AND governed_reporting_emissions_tco2e <> 0
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,

    SUM(
        CASE
            WHEN governed_reporting_eligibility <> 'ELIGIBLE'
             AND governed_reporting_emissions_tco2e IS NOT NULL
             AND governed_reporting_emissions_tco2e <> 0
            THEN 1 ELSE 0
        END
    ),

    CASE
        WHEN SUM(
            CASE
                WHEN governed_reporting_eligibility <> 'ELIGIBLE'
                 AND governed_reporting_emissions_tco2e IS NOT NULL
                 AND governed_reporting_emissions_tco2e <> 0
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'None'
        ELSE 'Reporting gate failures'
    END,

    'Project Reviewer',
    DATE('2026-10-09'),

    CASE
        WHEN SUM(
            CASE
                WHEN governed_reporting_eligibility <> 'ELIGIBLE'
                 AND governed_reporting_emissions_tco2e IS NOT NULL
                 AND governed_reporting_emissions_tco2e <> 0
                THEN 1 ELSE 0
            END
        ) = 0
        THEN 'PASS - REVIEW and HOLD records were excluded from governed reporting emissions.'
        ELSE 'FAIL - One or more non-eligible records entered reporting emissions.'
    END

FROM iff_esg_assurance.gold.reporting_transactions

UNION ALL

-- WP-006 Population reconciliation
SELECT
    'WP-006',
    'All transactions receive a governed disposition',
    'Records fall outside the Eligible / Review / Hold control process',
    'reconciliation control',
    'Prove Total Transactions = Eligible + Review + Hold',

    total_transactions,

    'Reporting_Reconciliation',

    reconciliation_status,

    CASE
        WHEN reconciliation_status = 'PASS'
        THEN 0
        ELSE 1
    END,

    CASE
        WHEN reconciliation_status = 'PASS'
        THEN 'None'
        ELSE 'Reporting_Reconciliation'
    END,

    'Project Reviewer',
    DATE('2026-10-09'),

    CASE
        WHEN reconciliation_status = 'PASS'
        THEN CONCAT(
            'PASS - Population reconciles: ',
            CAST(reporting_eligible_transactions AS STRING),
            ' Eligible + ',
            CAST(review_transactions AS STRING),
            ' Review + ',
            CAST(hold_transactions AS STRING),
            ' Hold = ',
            CAST(total_transactions AS STRING),
            ' total transactions.'
        )
        ELSE 'FAIL - Transaction population does not fully reconcile.'
    END

FROM iff_esg_assurance.gold.reporting_reconciliation;

-- COMMAND ----------

SELECT *
FROM iff_esg_assurance.gold.assurance_workpaper
ORDER BY workpaper_id;

-- COMMAND ----------

SELECT
    test_result,
    COUNT(*) AS control_tests
FROM iff_esg_assurance.gold.assurance_workpaper
GROUP BY test_result;

-- COMMAND ----------

SELECT
    workpaper_id,
    control,
    population,
    test_result,
    exception_count,
    exception_reference,
    conclusion
FROM iff_esg_assurance.gold.assurance_workpaper
ORDER BY workpaper_id;

-- COMMAND ----------

SELECT
    workpaper_id,
    population,
    test_result,
    exception_count,
    conclusion
FROM iff_esg_assurance.gold.assurance_workpaper
ORDER BY workpaper_id;