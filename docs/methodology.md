# Methodology

## Overview

This project demonstrates an end-to-end responsible-sourcing analytics workflow that combines supplier master data, procurement transactions, evidence validation, Scope 3 Category 1 emissions, geospatial risk context, data-governance controls, exception management, and assurance-readiness logic.

The project uses public IFF sustainability and responsible-sourcing materials only as business-context references. Supplier, procurement, transaction, farm, and evidence records are synthetic.

---

## 1. Supplier and Sourcing Data Mapping

The workflow begins by defining the core sourcing entities:

- supplier
- transaction
- farm
- municipality
- material
- evidence record
- emissions factor

Each entity is assigned a stable identifier such as:

- `supplier_id`
- `transaction_id`
- `farm_id`
- `municipality_code`
- `material_id`

A separate technical key, `source_record_id`, is used as the fact-table grain.

This distinction is important because business identifiers may contain quality issues such as duplicates or reused transaction IDs.

---

## 2. Data Governance

The project applies the sequence:

**Define → Own → Source → Check → Trace → Approve**

### Define

Standard definitions are established for:

- supplier
- sourcing status
- evidence status
- reporting eligibility
- exception severity
- emissions methodology

### Own

Control responsibilities are assigned to functions such as:

- Responsible Sourcing
- Carbon Accounting
- Data Governance
- Data Steward

### Source

Original source values are preserved before standardization.

### Check

Validation is applied for:

- completeness
- validity
- consistency
- uniqueness
- methodology
- evidence
- geography
- reporting eligibility

### Trace

Each governed output can be traced back to its source record and related control result.

### Approve

Only records meeting required conditions become eligible for governed reporting.

---

## 3. Bronze / Silver / Gold Architecture

### Bronze

Bronze tables preserve raw source structures.

Examples:

- supplier master
- procurement transactions
- evidence register
- emissions-factor master
- municipality reference
- QGIS farm reference

### Silver

Silver tables standardize and validate the data.

Key processes include:

- procurement standardization
- supplier and municipality validation
- geographic validation
- Scope 3 method validation
- evidence validation
- sourcing-status validation
- reporting-gate logic

### Gold

Gold tables provide decision-ready outputs.

Examples:

- reporting transactions
- exception register
- control results
- assurance workpaper
- readiness summary
- Power BI fact and dimension tables

---

## 4. Responsible-Sourcing Control Logic

The project follows a practical responsible-sourcing sequence:

**Map → Scope → Prove → Align → Assure**

### Map

Identify suppliers, farms, municipalities, sourcing relationships, and materials.

### Scope

Define which sourcing requirements, evidence requirements, geographic indicators, and carbon-accounting methods apply.

### Prove

Require supporting evidence for sourcing and emissions claims.

### Align

Standardize identifiers, statuses, methodologies, and reference data.

### Assure

Test controls, document exceptions, assign remediation, and determine reporting eligibility.

---

## 5. Scope 3 Category 1 Methodology

The project demonstrates purchased-goods-and-services emissions using multiple methodological pathways.

### Spend-Based

Spend is aligned to the reference-year basis and multiplied by an approved emissions factor.

Conceptually:

`Aligned Spend × Emission Factor = Scope 3 Emissions`

### Supplier-Specific

Supplier-specific values require acceptable supporting evidence.

Data availability alone does not make a supplier-specific value assurance-ready.

### Activity-Based

Activity-based records require a valid activity-based factor.

If the required factor is not available or approved, the record is placed on hold.

---

## 6. Supplier Evidence Validation

Supplier evidence is evaluated separately from simple evidence availability.

Possible outcomes include:

- evidence available
- evidence approved
- evidence verified
- evidence unresolved
- evidence missing

This distinction prevents an uploaded document from being treated automatically as valid reporting evidence.

---

## 7. Geographic Risk Analysis

QGIS is used to link synthetic supplier and farm records to real Brazilian municipalities.

Public geographic reference sources are used to provide context such as:

- municipality location
- soy deforestation exposure
- MapBiomas alert information
- biome context
- deforestation-related CO2 exposure

Geographic risk is used only as a due-diligence indicator.

It does not establish supplier causation, wrongdoing, or direct responsibility for deforestation.

---

## 8. Control Testing

Six control areas are tested:

1. Responsible-sourcing / DCF status validation
2. Emissions-method validation
3. Reporting-eligibility gate
4. Geographic master-data validation
5. Price-year alignment
6. Supplier GHG evidence validation

With 100 source records and 6 controls, the project generates:

`100 × 6 = 600 control tests`

Control outcomes include:

- PASS
- REVIEW
- FAIL
- N/A

---

## 9. Exception Management

Control failures and review items are converted into an exception register.

Each exception can include:

- exception ID
- source record
- transaction ID
- supplier ID
- exception type
- severity
- reason
- control owner
- remediation action
- evidence required
- retest result
- closure status

This creates a remediation workflow rather than a simple list of failed records.

---

## 10. Reporting Eligibility

The project separates control findings from final reporting decisions.

The logic is:

- unresolved material issue → `HOLD`
- unresolved review item → `REVIEW`
- required conditions satisfied → `ELIGIBLE`

A control failure does not automatically mean a confirmed ESG misstatement.

---

## 11. Data-Quality Finding: Reused Transaction IDs

The source contains:

- 100 physical source records
- 98 unique business transaction IDs

Two transaction IDs are reused across otherwise distinct records.

The pipeline therefore:

1. preserves all source records,
2. creates a unique `source_record_id`,
3. retains `transaction_id` as a business attribute,
4. flags transaction-ID uniqueness as a control issue.

This prevents source-level business-key problems from creating join duplication in downstream analytics.

---

## 12. Power BI Decision Layer

The final Gold tables feed a Power BI star schema.

Core dimensions:

- supplier
- municipality
- control
- control result

Core facts:

- reporting transaction
- control result
- exception

The dashboards support three decision levels:

1. executive assurance readiness
2. control and exception management
3. supplier risk and responsible-sourcing decisions

---

## 13. Limitations

This is a portfolio demonstration.

Key limitations include:

- synthetic supplier data
- synthetic procurement data
- synthetic farm points
- synthetic evidence records
- illustrative project decision rules
- landscape-level geographic risk indicators
- no inference of supplier wrongdoing
- no claim that the workflow represents an official IFF system or assurance process
