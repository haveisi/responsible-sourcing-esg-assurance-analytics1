# Responsible Sourcing, Supplier Risk & ESG Assurance Analytics

This portfolio project demonstrates how responsible-sourcing data can be governed, validated, traced, and combined with Scope 3 emissions, supplier evidence, geographic risk, and assurance controls to support supplier due diligence, remediation, and reporting decisions.

The project integrates responsible sourcing, supplier risk, Scope 3 Category 1 emissions, geospatial analysis, data governance, control testing, exception management, and assurance readiness in a Databricks + Power BI workflow.

> **Important:** Public IFF sustainability and responsible-sourcing materials are used only as a business-context reference. Supplier, procurement, transaction, farm, and evidence records used in this project are synthetic. Geographic risk indicators provide landscape-level due-diligence context and do not establish supplier causation or wrongdoing.

---

## Business Question

**How can supplier, sourcing, emissions, evidence, and geographic-risk data be governed together to identify responsible-sourcing risks, prioritize supplier review, and determine whether records are ready for ESG reporting?**

The project is designed around a practical responsible-sourcing problem:

- Which suppliers or sourcing records require additional due diligence?
- Is required sourcing or supplier evidence available?
- Are Scope 3 calculations methodologically valid?
- Are suppliers linked to geographic areas with elevated landscape-level risk?
- Which exceptions are high priority?
- Who owns remediation?
- Which records can enter governed reporting?
- Which records must remain under review or on hold?

---

## Project Objectives

The project has five primary objectives:

1. **Strengthen responsible-sourcing governance** by defining master data, ownership, validation, and approval logic.
2. **Integrate supplier due-diligence evidence** with sourcing and procurement records.
3. **Connect responsible sourcing with Scope 3 Category 1 accounting** without mixing unsupported methodologies.
4. **Add geographic risk context** using public municipality-level and deforestation-related data.
5. **Build an assurance-ready control framework** that identifies exceptions, assigns remediation, and determines reporting eligibility.

---

## Responsible Sourcing Framework

The project follows a practical responsible-sourcing workflow:

**Map → Scope → Prove → Align → Assure**

### Map

Identify:

- suppliers
- sourcing locations
- farms
- municipalities
- materials
- transactions
- sourcing relationships

### Scope

Define:

- responsible-sourcing requirements
- supplier evidence requirements
- sourcing-status requirements
- emissions methodology
- geographic-risk indicators
- reporting boundaries

### Prove

Require supporting evidence such as:

- sourcing declarations
- supplier GHG information
- methodology documentation
- approved emissions factors
- geographic reference data

### Align

Standardize:

- supplier IDs
- municipality codes
- farm IDs
- material IDs
- transaction records
- emissions methodology
- sourcing-status fields
- evidence status

### Assure

Test:

- completeness
- validity
- traceability
- evidence sufficiency
- methodology
- geography
- reporting eligibility
- exception closure

---

## Data Governance Approach

The project applies the governance sequence:

**Define → Own → Source → Check → Trace → Approve**

### Define

Establish clear definitions for:

- supplier
- transaction
- sourcing status
- evidence status
- emissions method
- reporting eligibility
- exception severity

### Own

Assign responsibilities across roles such as:

- Responsible Sourcing
- Carbon Accounting
- Data Governance
- Data Steward
- technical data custodian

### Source

Preserve source-system values and distinguish:

- original source values
- standardized values
- governed values
- derived analytical outputs

### Check

Apply controls for:

- completeness
- validity
- consistency
- uniqueness
- methodology
- evidence
- geography
- reporting eligibility

### Trace

Maintain lineage from:

**source record → control result → exception → remediation → reporting decision**

### Approve

Only records satisfying the required governance and control conditions become eligible for governed reporting.

---

## Solution Architecture

```text
IFF public responsible-sourcing requirements
+ Synthetic supplier / procurement / evidence data
+ Public geographic datasets
+ Public emissions factors
                |
                v
             BRONZE
     Raw ingestion and preservation
                |
                v
             SILVER
     Standardization
     Supplier master-data validation
     Geographic validation
     Scope 3 methodology validation
     Supplier evidence validation
     Responsible-sourcing controls
                |
                v
              GOLD
     Reporting eligibility
     Control results
     Exception register
     Assurance workpaper
     Readiness assessment
     Power BI star schema
                |
                v
            POWER BI
     Executive readiness summary
     Control & exception management
     Supplier risk & sourcing decision
```

---

## Data Sources

The project combines public reference data with synthetic operational records.

### Public / External Sources

The workflow uses public sources for:

- responsible-sourcing business context
- municipality reference data
- soybean deforestation exposure
- deforestation-alert information
- emissions factors

Examples include:

- IFF public sustainability and responsible-sourcing materials
- IBGE municipality reference data
- Trase soy / deforestation-related data
- MapBiomas Alerta
- U.S. EPA Supply Chain GHG Emission Factors

### Synthetic Data

Synthetic records include:

- supplier master data
- procurement transactions
- farm IDs
- supplier-farm relationships
- evidence records
- sourcing-status records

These synthetic data are designed only to demonstrate the analytical and control workflow.

---

## Scope 3 Category 1 Methodology

The project incorporates purchased-goods-and-services emissions as one input to responsible-sourcing decision support.

The demonstration includes:

- spend-based calculations
- supplier-specific methodology validation
- activity-based methodology validation
- emissions-factor governance
- price-year alignment
- reporting eligibility

For spend-based records:

```text
Aligned Spend
×
Approved Emission Factor
=
Calculated Scope 3 Emissions
```

A record is not automatically reporting-ready simply because an emissions value can be calculated.

Methodology, evidence, and governance controls must also pass.

---

## Supplier Evidence Logic

Supplier evidence is treated separately from simple data availability.

For example:

```text
Evidence exists
≠
Evidence verified
≠
Evidence assurance-ready
```

The project distinguishes:

- evidence available
- evidence approved
- evidence verified
- evidence unresolved
- evidence missing

This is important because supplier-specific reporting requires stronger evidence than simply having a document on file.

---

## Geographic Risk Analytics

The project integrates supplier and farm locations with municipality-level geographic indicators.

Geographic variables include examples such as:

- municipality
- biome context
- soybean deforestation exposure
- MapBiomas alert count
- MapBiomas alert area
- net deforestation-related CO2 exposure

Synthetic farm points are spatially linked to real Brazilian municipalities.

### Interpretation Rule

**Geographic risk is a due-diligence indicator, not evidence of supplier wrongdoing.**

A supplier associated with a higher-risk municipality may require additional review, evidence, or engagement, but the geographic signal does not establish causation.

---

## Assurance Control Framework

The project tests six control areas:

1. **Responsible-sourcing / DCF status validation**
2. **Emissions-method validation**
3. **Final reporting-eligibility gate**
4. **Geographic master-data validation**
5. **Price-year alignment**
6. **Supplier GHG evidence validation**

Each source record is tested against each control.

With:

```text
100 source records
×
6 controls
=
600 control tests
```

Control outcomes include:

- `PASS`
- `REVIEW`
- `FAIL`
- `N/A`

---

## Exception Management

Control failures and review items are converted into an exception register.

Each exception includes:

- exception ID
- transaction ID
- supplier ID
- exception type
- severity
- exception reason
- control owner
- remediation action
- evidence required
- status
- retest result
- closure status

This creates a traceable remediation workflow rather than simply identifying bad data.

---

## Reporting Eligibility Logic

The project separates control findings from the final reporting decision.

A control failure does not automatically mean a confirmed ESG misstatement.

The reporting gate uses:

```text
Unresolved material issue
→ HOLD

Unresolved review item
→ REVIEW

Required controls satisfied
→ ELIGIBLE
```

This distinction supports more defensible management and assurance decisions.

---

## Key Results

| Metric | Result |
|---|---:|
| Source records | 100 |
| Unique transaction IDs | 98 |
| Suppliers assessed | 20 |
| Reporting-eligible records | 15 |
| Review records | 25 |
| Hold records | 60 |
| Reporting eligibility rate | 15% |
| Control tests | 600 |
| Open exceptions | 85 |
| High-severity open exceptions | 67 |
| Overall assurance readiness | PARTIALLY READY |

---

## Key Data-Quality Finding

The source population contained:

```text
100 physical source records
98 unique business transaction IDs
```

Two transaction IDs were reused across otherwise distinct records.

Instead of deleting the records, the pipeline:

1. preserved all 100 physical records,
2. created a unique technical `source_record_id`,
3. retained `transaction_id` as a business identifier,
4. flagged transaction-ID uniqueness as a data-quality issue.

This distinction became an important architectural lesson:

> **A source business-key problem should remain a controlled data-quality exception; it should not become a pipeline duplication problem.**

The technical `source_record_id` is therefore used as the analytical fact grain and technical join key.

---

## Bronze / Silver / Gold Databricks Architecture

### Bronze

Preserves raw source structures:

- supplier master
- procurement transactions
- evidence register
- emissions-factor master
- municipality reference
- QGIS farm reference

### Silver

Applies governance and validation:

- standardized procurement
- geographic validation
- emissions-factor standardization
- price-year alignment
- Scope 3 method validation
- supplier evidence validation
- method eligibility
- reporting gate

### Gold

Produces decision-ready outputs:

- reporting transactions
- reporting reconciliation
- exception register
- assurance workpaper
- readiness summary
- control results
- Power BI fact tables
- Power BI dimensions

---

## Power BI Model

The reporting model uses a star-schema structure.

### Dimensions

- `dim_supplier`
- `dim_municipality`
- `dim_control`
- `dim_control_result`

### Facts

- `fact_reporting_transaction`
- `fact_control_result`
- `fact_exception`

Core relationship pattern:

```text
dim_supplier
     |
     +----> fact_reporting_transaction
     |
     +----> fact_control_result
     |
     +----> fact_exception

dim_municipality
     |
     +----> fact_reporting_transaction

dim_control
     |
     +----> fact_control_result

dim_control_result
     |
     +----> fact_control_result
```

Single-direction filtering is used from dimensions to facts to avoid ambiguous fact-to-fact relationships.

---

## Dashboard 1 — Responsible Sourcing & ESG Readiness Executive Summary

This page summarizes:

- source-record population
- reporting eligibility
- review and hold populations
- open exceptions
- high-severity exceptions
- reporting eligibility mix
- exception types
- control-test results
- reporting vs excluded emissions
- overall readiness

![Executive Summary](dashboards/page1_executive_summary.png)

---

## Dashboard 2 — Supplier Controls & Exception Management

This page supports operational remediation and control oversight.

It includes:

- total control tests
- control pass rate
- open exceptions
- high-severity exceptions
- exceptions by type
- exceptions by control owner
- exceptions by severity
- control performance
- detailed exception register
- remediation actions
- evidence requirements
- retest and closure status

![Control Performance & Exception Management](dashboards/page2_control_exception_management.png)

---

## Dashboard 3 — Supplier Risk & Responsible Sourcing Decision

This is the main supplier decision-support page.

It combines:

- suppliers assessed
- suppliers with open exceptions
- suppliers with high-severity exceptions
- suppliers with reporting-eligible records
- open exceptions by supplier
- supplier assurance status
- supplier GHG evidence availability
- municipality-level deforestation exposure
- supplier-level calculated emissions
- reportable emissions
- assurance decision logic

![Supplier Risk & Assurance Decision](dashboards/page3_supplier_risk_assurance_decision.png)

---

## Supplier-Level Decision Logic

The final page converts governance and control results into a supplier review decision.

Illustrative decision logic:

```text
HOLD
→ one or more HOLD records
or unresolved high-severity exception

REVIEW REQUIRED
→ no hard HOLD issue
but unresolved review records remain

ASSURANCE READY
→ required conditions satisfied
and no material unresolved exceptions
```

This decision logic is a project demonstration and should not be interpreted as an official IFF policy or decision rule.

---

## Why This Project Matters

Responsible sourcing is often treated separately from carbon accounting, geospatial risk, and ESG reporting.

This project demonstrates a more integrated approach.

Instead of asking only:

> How much Scope 3 carbon do we have?

the project asks:

> Can the sourcing record be trusted, traced, supported with evidence, geographically contextualized, and responsibly used in reporting and supplier decisions?

This creates a bridge between:

- procurement
- sustainability
- responsible sourcing
- carbon accounting
- data governance
- risk management
- audit / assurance

---

## Key Governance Lessons

### 1. Master data comes first

Supplier, municipality, farm, material, and transaction identifiers must be standardized before reliable analysis is possible.

### 2. Data availability is not evidence quality

A supplier report can exist but still be unverified or unsuitable for reporting.

### 3. Calculated emissions are not automatically reportable

Methodology, evidence, controls, and governance determine reporting eligibility.

### 4. Geographic risk is contextual

Landscape-level risk can support due diligence but should not be misinterpreted as proof of supplier behavior.

### 5. Exceptions need ownership

A useful control framework identifies:

- what failed
- why it failed
- who owns remediation
- what evidence is required
- whether the issue was retested
- whether it was closed

### 6. Technical keys and business keys serve different purposes

`source_record_id` protects fact-table grain.

`transaction_id` remains a business identifier that is itself subject to quality controls.

---

## Technology Stack

### Data Engineering

- Databricks
- Delta Lake
- SQL
- Python
- pandas

### Analytics & Visualization

- Power BI
- DAX
- Excel

### Geospatial Analysis

- QGIS
- IBGE geographic data
- Trase
- MapBiomas Alerta

### Sustainability & ESG

- Scope 3 Category 1
- supplier evidence governance
- responsible sourcing
- ESG data governance
- control testing
- assurance readiness

---

## Repository Structure

```text
responsible-sourcing-esg-assurance-analytics/
│
├── README.md
├── .gitignore
├── LICENSE
│
├── dashboards/
│   ├── page1_executive_summary.png
│   ├── page2_control_exception_management.png
│   └── page3_supplier_risk_assurance_decision.png
│
├── databricks/
│   ├── 00_setup.sql
│   ├── 01_bronze_ingestion.py
│   ├── 02_silver_standardization.sql
│   ├── 03_geo_validation.sql
│   ├── 04_scope3_method_validation.sql
│   ├── 05_evidence_validation.sql
│   ├── 06_reporting_gate.sql
│   ├── 07_reconciliation.sql
│   ├── 08_exception_register.sql
│   ├── 09_assurance_workpaper.sql
│   ├── 10_assurance_readiness_summary.sql
│   ├── 11_control_results.sql
│   └── 12_powerbi_star_schema.sql
│
├── docs/
│   ├── methodology.md
│   ├── data-governance-framework.md
│   ├── assurance-control-framework.md
│   ├── data-dictionary.md
│   └── limitations.md
│
├── powerbi/
│   ├── measures.md
│   └── model_relationships.md
│
├── architecture/
│   └── responsible_sourcing_assurance_architecture.png
│
├── sample_data/
│   └── README.md
│
└── assets/
```

---

## Limitations

This is a portfolio demonstration and not an official IFF system, assessment, or assurance engagement.

Key limitations include:

- supplier records are synthetic
- procurement transactions are synthetic
- farm locations are synthetic points constrained to real municipalities
- supplier evidence records are synthetic
- geographic indicators are landscape-level contextual signals
- project decision logic is illustrative
- the workflow does not establish supplier wrongdoing or legal noncompliance
- public data availability and methodology may change over time

---

## Data Ethics and Interpretation

This project intentionally separates:

**risk indicator**

from

**evidence of causation**

and separates:

**control failure**

from

**confirmed reporting misstatement**

These distinctions are important for responsible supplier engagement, ESG governance, and defensible assurance processes.

---

## Portfolio Summary

This project demonstrates an end-to-end responsible-sourcing analytics workflow:

**supplier master data  
→ sourcing controls  
→ supplier evidence  
→ Scope 3 methodology  
→ geographic risk  
→ data governance  
→ exception management  
→ assurance readiness  
→ supplier decision support**

The central idea is that responsible sourcing requires more than collecting supplier data.

It requires making that data:

**defined, owned, validated, traceable, evidence-supported, reviewable, and decision-ready.**
