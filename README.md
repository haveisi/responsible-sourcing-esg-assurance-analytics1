# ESG Assurance Readiness, Data Governance & Responsible Sourcing Analytics

This portfolio project demonstrates how ESG and sustainability data can be governed, validated, traced, and prepared for assurance before entering external reporting.

The project integrates:

- responsible sourcing controls
- Scope 3 Category 1 emissions
- supplier evidence validation
- geographic deforestation-risk context
- data-quality controls
- exception management
- assurance-readiness assessment
- Databricks Bronze / Silver / Gold architecture
- Power BI decision dashboards
- QGIS geospatial analysis

## Business Question

How can supplier and sourcing data be governed so that responsible-sourcing status, Scope 3 emissions, geographic risk, and supporting evidence can be traced, controlled, reconciled, and used together for reporting and supplier decisions?

## Project Context

IFF public sustainability and responsible-sourcing materials are used only as a business-context reference.

The supplier, procurement, farm, transaction, and evidence records used in the analytical workflow are synthetic.

Public geographic and emissions-factor datasets are used to demonstrate how external information can be integrated into an assurance-ready ESG data pipeline.

## Solution Architecture

```text
Public sourcing requirements
+ Synthetic supplier / procurement / evidence data
+ Public geographic data
+ Public emissions factors
            |
            v
        BRONZE
Raw ingestion and source preservation
            |
            v
        SILVER
Standardization
Data-quality validation
Geographic validation
Scope 3 methodology validation
Supplier evidence validation
            |
            v
         GOLD
Reporting eligibility
Exception register
Control results
Assurance workpaper
Readiness summary
Power BI star schema
            |
            v
       POWER BI
Executive assurance summary
Control & exception management
Supplier risk & assurance decision
```

## Key Results

| Metric | Result |
|---|---:|
| Source records | 100 |
| Unique transaction IDs | 98 |
| Suppliers assessed | 20 |
| Reporting eligible records | 15 |
| Review records | 25 |
| Hold records | 60 |
| Reporting eligibility rate | 15% |
| Control tests | 600 |
| Open exceptions | 85 |
| High-severity open exceptions | 67 |
| Overall assurance readiness | PARTIALLY READY |

## Key Data-Quality Finding

The source contained 100 physical records but only 98 unique business transaction IDs.

Two transaction IDs were reused across otherwise distinct source records.

Rather than deleting those records, the pipeline:

1. preserved all 100 source records,
2. created a unique technical `source_record_id`,
3. retained `transaction_id` as a business identifier,
4. treated transaction-ID uniqueness as a data-quality control issue.

This prevents a business-key quality problem from becoming a pipeline duplication problem.

## Data Governance Framework

The project follows a simple governance sequence:

**Define → Own → Source → Check → Trace → Approve**

The workflow distinguishes among:

- data ownership
- data stewardship
- technical custody
- data production
- data-quality validation
- evidence requirements
- reporting approval

## Assurance Readiness Logic

A control failure does not automatically mean a confirmed ESG misstatement.

The reporting gate applies this logic:

- unresolved material issue → `HOLD`
- unresolved review item → `REVIEW`
- required controls satisfied → `ELIGIBLE`

The project therefore separates:

1. data-quality exceptions,
2. control failures,
3. evidence gaps,
4. reporting eligibility,
5. assurance readiness.

## Geographic Risk Interpretation

Geographic risk indicators are used as due-diligence context.

They do not establish supplier causation, wrongdoing, or direct responsibility for deforestation.

Synthetic farm points are used only to demonstrate the geospatial workflow.

## Technology Stack

- Databricks
- Delta Lake
- SQL
- Python / pandas
- Power BI / DAX
- QGIS
- Excel

## Dashboard Pages

1. **ESG Assurance Readiness — Executive Summary**
2. **Control Performance & Exception Management**
3. **Supplier Risk & Assurance Decision**
```
