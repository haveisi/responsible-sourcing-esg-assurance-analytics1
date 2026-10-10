# Power BI Model Relationships

## Why this model is structured this way

The Power BI model follows a simple star-schema design.

The goal is to keep supplier, geography, control, and exception logic easy to understand and avoid direct fact-to-fact relationships that can create ambiguous filtering or incorrect totals.

The model uses shared dimensions to describe the business entities and fact tables to store events, tests, and exceptions.

A simple rule I follow is:

> **Dimensions describe. Facts measure.**

---

## Core Dimensions

The model uses four main dimensions:

- `dim_supplier`
- `dim_municipality`
- `dim_control`
- `dim_control_result`

These dimensions provide the descriptive fields used in slicers, labels, grouping, and filtering.

---

## Core Fact Tables

The model uses three main fact tables:

- `fact_reporting_transaction`
- `fact_control_result`
- `fact_exception`

Each fact table has a different business purpose.

---

# 1. Supplier Relationships

`dim_supplier` is the main supplier dimension.

It contains one row per governed supplier.

Relationship pattern:

```text
dim_supplier[supplier_id]
        1
        |
        *
fact_reporting_transaction[supplier_id]
```

```text
dim_supplier[supplier_id]
        1
        |
        *
fact_control_result[supplier_id]
```

```text
dim_supplier[supplier_id]
        1
        |
        *
fact_exception[supplier_id]
```

### Relationship settings

For each relationship:

- Cardinality: `One-to-many`
- Cross-filter direction: `Single`
- Active: `Yes`

The filter direction should flow from:

`dim_supplier → fact`

not from fact tables back into the supplier dimension.

---

## Why supplier filtering matters

Using the supplier dimension allows one supplier selection to filter:

- sourcing records
- control tests
- exceptions

without creating direct relationships among those three fact tables.

That keeps the model simpler and reduces ambiguity.

---

# 2. Municipality Relationship

`dim_municipality` contains one row per governed municipality.

The relationship is:

```text
dim_municipality[municipality_code]
        1
        |
        *
fact_reporting_transaction[municipality_code]
```

### Relationship settings

- Cardinality: `One-to-many`
- Cross-filter direction: `Single`
- Active: `Yes`

The municipality dimension supports:

- geographic validation
- municipality-level risk analysis
- deforestation-exposure visuals
- responsible-sourcing due-diligence context

---

## Why municipality is linked primarily to the reporting fact

The governed transaction fact already contains the municipality associated with each source record.

This makes it possible to analyze:

- reporting eligibility by geography
- emissions by geography
- supplier records by municipality
- geographic risk context

without duplicating municipality logic across every fact table.

---

# 3. Control Relationship

`dim_control` contains one row per assurance control.

The relationship is:

```text
dim_control[control_id]
        1
        |
        *
fact_control_result[control_id]
```

### Relationship settings

- Cardinality: `One-to-many`
- Cross-filter direction: `Single`
- Active: `Yes`

This relationship allows Power BI to group control-test results by control name and category.

Controls in the project include:

- geography master-data validation
- emissions-method validation
- price-year alignment
- supplier GHG evidence validation
- responsible-sourcing / DCF validation
- final reporting eligibility gate

---

# 4. Control Result Relationship

`dim_control_result` contains one row per possible control result.

Typical values are:

- `PASS`
- `REVIEW`
- `FAIL`
- `N/A`

The relationship is:

```text
dim_control_result[control_result]
        1
        |
        *
fact_control_result[control_result]
```

### Relationship settings

- Cardinality: `One-to-many`
- Cross-filter direction: `Single`
- Active: `Yes`

This dimension is used for:

- control-result slicers
- PASS / REVIEW / FAIL / N/A legends
- control-performance filtering

---

# Model Overview

The overall model looks like this:

```text
                    dim_supplier
                         |
           +-------------+-------------+
           |             |             |
           v             v             v
fact_reporting     fact_control     fact_exception
transaction          result

      ^
      |
dim_municipality


dim_control
     |
     v
fact_control_result
     ^
     |
dim_control_result
```

A more complete view is:

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

---

# Fact Table Grain

Understanding grain is important because each fact table represents something different.

## `fact_reporting_transaction`

Grain:

`1 row per source_record_id`

This table contains the governed record used for reporting and supplier decision support.

It includes:

- supplier
- geography
- sourcing status
- emissions method
- calculated emissions
- reporting emissions
- reporting eligibility

---

## `fact_control_result`

Grain:

`1 row per source_record_id × control_id`

With:

- 100 source records
- 6 controls

the table contains:

`600 control-test rows`

This structure makes it possible to analyze control performance independently from the transaction fact.

---

## `fact_exception`

Grain:

`1 row per exception`

A source record may have:

- no exception
- one exception
- multiple exceptions

This table is used for:

- exception counts
- severity analysis
- ownership
- remediation
- retesting
- closure

---

# Technical Key vs Business Key

The reporting fact uses:

`source_record_id`

as the technical key.

The project discovered:

- 100 physical source records
- 98 unique `transaction_id` values

Two transaction IDs are reused across otherwise distinct records.

For that reason:

- `source_record_id` is used for technical joins
- `transaction_id` is retained as a business identifier
- transaction-ID uniqueness is treated as a data-quality control issue

This prevents the business-key issue from creating join duplication.

---

# Why I Avoid Fact-to-Fact Relationships

The model intentionally avoids relationships such as:

```text
fact_reporting_transaction
↔
fact_control_result
```

or:

```text
fact_exception
↔
fact_control_result
```

These relationships can cause:

- ambiguous filter paths
- double counting
- incorrect totals
- difficult-to-explain visual behavior

Instead, shared dimensions are used to connect related business entities.

---

# Filter Direction

The model uses single-direction filtering.

The preferred pattern is:

```text
Dimension
   |
   v
Fact
```

Examples:

```text
dim_supplier
→ fact_exception
```

```text
dim_control
→ fact_control_result
```

This helps prevent fact tables from unexpectedly filtering dimensions or each other.

---

# Example: Supplier Filtering

If a user selects one supplier from:

`dim_supplier[supplier_name]`

Power BI can filter:

- that supplier's reporting records
- that supplier's control results
- that supplier's exceptions

because the supplier dimension connects to all three facts.

No direct fact-to-fact relationship is needed.

---

# Example: Control Result Filtering

If a user selects:

`FAIL`

from:

`dim_control_result[control_result]`

the filter applies to:

`fact_control_result`

and therefore updates:

- control performance charts
- control-result counts
- control-related visuals

It does not automatically filter unrelated fact tables unless a separate shared dimension or measure is designed to do so.

This is intentional.

---

# Why Some Slicers Should Not Filter Every KPI

Some KPIs describe the total governed population.

For example:

`Suppliers Assessed`

should normally represent all governed suppliers.

A control-result or exception slicer should not necessarily reduce that number.

For this reason, some executive measures may use filter-removal logic or controlled visual interactions.

This helps distinguish:

- population metrics
from
- issue-specific metrics

---

# Power BI Slicer Design

Recommended slicers include:

- supplier
- municipality
- control result
- control owner
- exception type
- severity
- closure status

Where possible, slicers should use dimension fields rather than fact-table fields.

Examples:

Use:

`dim_supplier[supplier_name]`

instead of:

`fact_exception[supplier_id]`

and use:

`dim_control_result[control_result]`

instead of:

`fact_control_result[control_result]`

This keeps the model consistent.

---

# Relationship QA

Before publishing the dashboard, the model was checked for orphan records.

Key checks included:

- transaction → supplier
- transaction → municipality
- control result → control

The target is:

`0 orphan records`

This confirms that the fact tables can resolve to their governed dimensions.

---

# Why this structure matters

The star schema supports three different decision layers:

## Executive View

Uses governed measures to summarize:

- reporting eligibility
- exceptions
- readiness
- emissions

## Control View

Uses:

- `dim_control`
- `dim_control_result`
- `fact_control_result`
- `fact_exception`

to support remediation and control monitoring.

## Supplier View

Uses:

- `dim_supplier`
- `dim_municipality`
- `fact_reporting_transaction`
- `fact_exception`

to support responsible-sourcing and supplier decisions.

---

# Final Model Principle

The model is intentionally simple.

The objective is not to create as many relationships as possible.

The objective is to make the relationships:

- clear
- traceable
- stable
- easy to explain
- difficult to misuse

That makes the reporting layer easier to reconcile with the Databricks Gold tables and easier to defend during review or assurance.
```
