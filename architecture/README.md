# Responsible Sourcing & ESG Assurance Architecture

This project connects responsible sourcing, supplier evidence, Scope 3 accounting, geospatial risk, data governance, and assurance controls in one governed workflow.

```mermaid
flowchart TD

A[IFF public responsible-sourcing context] --> D[Bronze Layer]
B[Synthetic supplier, procurement & evidence data] --> D
C[Public geographic & emission-factor data] --> D

D --> E[Silver Layer]

E --> E1[Supplier & transaction standardization]
E --> E2[Geographic validation]
E --> E3[Scope 3 method validation]
E --> E4[Supplier evidence validation]
E --> E5[Responsible-sourcing / DCF validation]

E1 --> F[Gold Layer]
E2 --> F
E3 --> F
E4 --> F
E5 --> F

F --> F1[Reporting Transactions]
F --> F2[Control Results]
F --> F3[Exception Register]
F --> F4[Assurance Workpaper]
F --> F5[Readiness Summary]

F1 --> G[Power BI]
F2 --> G
F3 --> G
F4 --> G
F5 --> G

G --> G1[Executive Summary]
G --> G2[Control & Exception Management]
G --> G3[Supplier Risk & Responsible Sourcing Decision]

C --> H[QGIS]
H --> E2
```

## Core Design Logic

The architecture separates four stages:

### 1. Source

The project combines:

- public responsible-sourcing context
- synthetic supplier and procurement data
- synthetic supplier evidence
- public geographic reference data
- public emission factors

### 2. Govern

Databricks Silver tables standardize and validate the records.

Key controls include:

- supplier and municipality validation
- emissions-method validation
- supplier-evidence validation
- sourcing-status validation
- price-year alignment

### 3. Assure

Gold tables turn validation results into:

- control outcomes
- exceptions
- remediation requirements
- reporting eligibility
- assurance-readiness conclusions

### 4. Decide

Power BI turns the governed data into three decision views:

1. Executive readiness
2. Control and exception management
3. Supplier risk and responsible-sourcing decisions

## Key Principle

The architecture deliberately separates:

**raw data → governed data → controlled data → reporting decision**

This prevents a value from becoming reportable simply because it exists or can be calculated.
```
