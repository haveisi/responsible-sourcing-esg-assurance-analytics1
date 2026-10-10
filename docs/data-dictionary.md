# Data Dictionary

## Why this matters

This project brings together sourcing, supplier, emissions, evidence, geographic, and assurance data.

A data dictionary helps make sure that a field means the same thing across Databricks, Power BI, QGIS, and documentation.

The goal is simple:

**someone reviewing the project should be able to understand what each important field means, where it comes from, and how it is used.**

---

## Core identifiers

| Field | Meaning | Type | Main Use |
|---|---|---|---|
| `source_record_id` | Unique technical identifier for each physical source record | Text | Fact-table grain and technical joins |
| `transaction_id` | Business transaction identifier | Text | Business reference and uniqueness control |
| `supplier_id` | Unique supplier identifier | Text | Supplier master-data linkage |
| `supplier_name` | Supplier display name | Text | Reporting and supplier analysis |
| `farm_id` | Synthetic farm identifier | Text | Farm-to-supplier and farm-to-municipality linkage |
| `municipality_code` | Governed municipality identifier | Text | Geographic validation |
| `material_id` | Material identifier | Text | Material and emissions-factor mapping |
| `control_id` | Unique control identifier | Text | Control-result analysis |
| `exception_id` | Unique exception identifier | Text | Exception tracking and remediation |

---

## Why `source_record_id` matters

The project contains:

- 100 physical source records
- 98 unique `transaction_id` values

Two transaction IDs are reused across otherwise distinct records.

For that reason:

- `source_record_id` is the technical key
- `transaction_id` remains the business identifier

This prevents non-unique business IDs from creating duplicated rows during joins.

---

# Supplier Master Data

## `supplier_id`

Unique supplier identifier.

Used to connect supplier information to:

- procurement transactions
- control results
- exceptions
- responsible-sourcing analysis

---

## `supplier_name`

Human-readable supplier name used in Power BI and supplier-level analysis.

---

## `country_code`

Country associated with the supplier record.

Used for geographic classification and sourcing context.

---

## `municipality_code`

Municipality linked to the supplier or farm record.

Validated against the governed municipality reference table.

---

## `municipality_name`

Human-readable municipality name.

Used in Power BI and geographic analysis.

---

## `supplier_ghg_data_available`

Indicates whether supplier GHG information is available.

Important:

**available does not mean verified or assurance-ready.**

This field is used as an availability indicator only.

---

# Procurement and Transaction Data

## `transaction_id`

Business identifier for the procurement transaction.

Used for business traceability but not as the technical fact-table key.

---

## `source_record_id`

Technical identifier created to preserve one row per physical source record.

Used for downstream joins and control testing.

---

## `material_id`

Identifies the purchased material.

Examples in the project include soy-related materials.

---

## `spend_usd`

Original transaction spend in U.S. dollars.

Used in the spend-based Scope 3 methodology.

---

## `spend_usd_2022`

Spend adjusted to the reference-year basis used by the selected emission factor.

Used to align transaction spend with the factor basis.

---

## `governed_final_emissions_tco2e`

Calculated emissions value after method and factor logic have been applied.

This does not automatically mean the value is reportable.

---

## `governed_reporting_emissions_tco2e`

Emissions allowed into governed reporting after the reporting-eligibility gate.

---

## `governed_reporting_eligibility`

Final reporting status.

Possible values:

- `ELIGIBLE`
- `REVIEW`
- `HOLD`

---

# Scope 3 Methodology Fields

## `emissions_method`

Indicates the selected calculation method.

Examples:

- spend-based
- supplier-specific
- activity-based

---

## `emission_factor`

Approved emission factor used in the calculation.

---

## `emission_factor_source`

Reference source for the emission factor.

In this project, public EPA supply-chain factors are used for spend-based demonstration.

---

## `factor_status`

Indicates whether the factor is approved for use.

---

## `method_validation_status`

Shows whether the selected emissions method passes the required methodology checks.

Possible outcomes may include:

- `PASS`
- `REVIEW`
- `FAIL`
- `HOLD`

depending on the workflow stage.

---

# Supplier Evidence Data

## `evidence_type`

Type of supporting document or evidence.

Examples may include:

- supplier GHG report
- sourcing declaration
- methodology documentation

---

## `review_status`

Indicates whether the evidence has been reviewed.

Examples:

- Approved
- Pending
- Rejected

---

## `verification_status`

Indicates whether the evidence is independently verified.

This is kept separate from review status.

---

## `supplier_specific_validation`

Shows whether supplier-specific GHG information has enough support to be used.

---

## Evidence interpretation

The project deliberately separates:

**evidence exists**

from

**evidence reviewed**

from

**evidence verified**

from

**evidence assurance-ready**

These are not the same thing.

---

# Geographic Reference Data

## `ibge_municipality_code`

Municipality code based on IBGE reference data.

Used as the main geographic reference key.

---

## `municipality_name`

Official municipality name.

---

## `state_code`

State abbreviation.

---

## `state_name`

State name.

---

## `area_km2`

Municipality area in square kilometers.

---

## `trase_municipality_id`

Municipality identifier used in the Trase reference dataset.

---

## `trase_biome`

Biome classification associated with the municipality.

---

## `trase_year`

Reference year for the Trase indicator.

---

## `trase_volume`

Soy-related volume indicator from the public reference source.

---

## `soy_deforestation_5yr_exposure`

Municipality-level soy deforestation exposure over the selected reference period.

Used as a landscape-level due-diligence signal.

---

## `co2_net_deforestation_exposure`

Net deforestation-related CO2 exposure indicator.

---

## `co2_gross_deforestation_exposure`

Gross deforestation-related CO2 exposure indicator.

---

## `mapbiomas_alert_count`

Number of MapBiomas alerts associated with the municipality.

---

## `mapbiomas_alert_area_ha`

Total alert area in hectares.

---

## `mapbiomas_primary_pressure`

Primary pressure or driver identified in the geographic reference data.

---

## `biome_complexity_flag`

Indicator used to flag municipalities with more complex biome context.

---

## Geographic interpretation

These fields are used for responsible-sourcing due diligence.

They do **not** establish supplier causation, wrongdoing, or direct responsibility for deforestation.

---

# Control Results

## `control_id`

Identifier for the assurance control.

Controls used in the project include:

- `CTRL-GEO-001`
- `CTRL-METHOD-001`
- `CTRL-PRICE-001`
- `CTRL-EVID-001`
- `CTRL-DCF-001`
- `CTRL-REPORT-001`

---

## `control_name`

Human-readable control name.

Examples:

- Geography master-data validation
- Emissions method validation
- Price-year alignment
- Supplier GHG evidence validation
- DCF sourcing-status validation
- Final reporting eligibility gate

---

## `control_result`

Outcome of the control test.

Possible values:

- `PASS`
- `REVIEW`
- `FAIL`
- `N/A`

---

## `control_owner`

Function responsible for reviewing or remediating the control issue.

Examples include:

- Responsible Sourcing
- Carbon Accounting
- Data Governance
- Data Steward

---

# Exception Register

## `exception_id`

Unique identifier for the exception.

---

## `exception_type`

Category of the issue.

Examples may include:

- METHOD
- EVIDENCE
- DCF
- GEO
- MANUAL OVERRIDE

---

## `severity`

Priority level assigned to the exception.

Examples:

- High
- Medium

Severity is used for remediation prioritization and does not automatically mean a confirmed reporting misstatement.

---

## `exception_reason`

Plain-language description of why the record requires remediation.

---

## `remediation_action`

Action required to address the exception.

---

## `evidence_required`

Evidence needed before the issue can be reconsidered or closed.

---

## `retest_result`

Outcome of the post-remediation retest.

---

## `closure_status`

Shows whether the exception remains open or has been closed.

---

# Power BI Dimensions

## `dim_supplier`

One row per governed supplier.

Used for:

- supplier slicers
- supplier-level analysis
- supplier decision tables

---

## `dim_municipality`

One row per municipality.

Used for geographic and responsible-sourcing analysis.

---

## `dim_control`

One row per assurance control.

---

## `dim_control_result`

One row per possible control outcome.

Typical values:

- PASS
- REVIEW
- FAIL
- N/A

---

# Power BI Facts

## `fact_reporting_transaction`

One row per governed source record.

Technical grain:

`source_record_id`

Contains:

- supplier information
- sourcing status
- Scope 3 results
- reporting eligibility
- reportable emissions

---

## `fact_control_result`

One row per:

`source_record_id × control_id`

With:

- 100 source records
- 6 controls

the table contains:

**600 control-test records**

---

## `fact_exception`

One row per recorded exception.

Used for:

- exception counts
- severity analysis
- remediation ownership
- exception register reporting

---

# Key Status Fields

## Reporting status

`ELIGIBLE`

The record satisfies the required conditions for governed reporting.

`REVIEW`

Additional evidence or judgment is required.

`HOLD`

The record should not enter governed reporting until the issue is resolved.

---

## Assurance readiness

The overall project readiness status is:

`PARTIALLY READY`

This means the control structure and reporting process exist, but unresolved exceptions remain.

---

# Final note

This dictionary focuses on the fields that matter most for understanding the responsible-sourcing, Scope 3, governance, and assurance workflow.

It is intentionally written as a practical project reference rather than a full enterprise metadata catalog.
