# Power BI Measures

## Why this file exists

The Power BI model uses a small set of DAX measures to keep the dashboard logic consistent across the three report pages.

Rather than rebuilding calculations separately inside each visual, the measures centralize the logic for:

- reporting eligibility
- control performance
- exception management
- supplier-level decision support
- reported vs excluded emissions

This makes the dashboard easier to audit, maintain, and explain.

---

## Core Record Measures

### Source Records

Counts the number of governed source records in the reporting fact table.

```DAX
Source Records =
COUNTROWS(fact_reporting_transaction)
```

Expected project result:

`100`

---

### Unique Transaction IDs

Counts distinct business transaction identifiers.

```DAX
Unique Transaction IDs =
DISTINCTCOUNT(
    fact_reporting_transaction[transaction_id]
)
```

Expected project result:

`98`

This differs from Source Records because two transaction IDs are reused across otherwise distinct source records.

---

## Reporting Eligibility Measures

### Reporting Eligible

```DAX
Reporting Eligible =
CALCULATE(
    [Source Records],
    fact_reporting_transaction[governed_reporting_eligibility] = "ELIGIBLE"
)
```

Expected result:

`15`

---

### Review Transactions

```DAX
Review Transactions =
CALCULATE(
    [Source Records],
    fact_reporting_transaction[governed_reporting_eligibility] = "REVIEW"
)
```

Expected result:

`25`

---

### Hold Transactions

```DAX
Hold Transactions =
CALCULATE(
    [Source Records],
    fact_reporting_transaction[governed_reporting_eligibility] = "HOLD"
)
```

Expected result:

`60`

---

### Reporting Eligibility %

```DAX
Reporting Eligibility % =
DIVIDE(
    [Reporting Eligible],
    [Source Records]
)
```

Expected result:

`15%`

Format this measure as Percentage in Power BI.

---

## Emissions Measures

### Calculated Emissions tCO2e

```DAX
Calculated Emissions tCO2e =
SUM(
    fact_reporting_transaction[governed_final_emissions_tco2e]
)
```

This represents calculated emissions before the final reporting gate.

---

### Reporting Emissions tCO2e

```DAX
Reporting Emissions tCO2e =
SUM(
    fact_reporting_transaction[governed_reporting_emissions_tco2e]
)
```

This represents emissions that are allowed into governed reporting.

---

### Excluded Emissions tCO2e

```DAX
Excluded Emissions tCO2e =
[Calculated Emissions tCO2e]
-
[Reporting Emissions tCO2e]
```

This measure shows the emissions amount excluded because the associated records are not currently reporting-eligible.

---

## Exception Measures

### Open Exceptions

```DAX
Open Exceptions =
CALCULATE(
    COUNTROWS(fact_exception),
    fact_exception[closure_status] <> "CLOSED"
)
```

Expected result:

`85`

---

### Open Exception Count

This measure is used in supplier and exception visuals.

```DAX
Open Exception Count =
CALCULATE(
    COUNTROWS(fact_exception),
    fact_exception[closure_status] <> "CLOSED"
)
```

This is logically the same as Open Exceptions and can be consolidated if preferred.

---

### High Severity Open Exceptions

```DAX
High Severity Open Exceptions =
CALCULATE(
    COUNTROWS(fact_exception),
    fact_exception[severity] = "High",
    fact_exception[closure_status] <> "CLOSED"
)
```

Expected result:

`67`

---

## Control Measures

### Control Tests

```DAX
Control Tests =
COUNTROWS(fact_control_result)
```

Expected result:

`600`

The control fact table contains one row per:

`source_record_id × control_id`

With 100 source records and 6 controls:

`100 × 6 = 600`

---

### Control Test Count

Used in assurance-control visuals.

```DAX
Control Test Count =
COUNTROWS(fact_control_result)
```

---

### Control Pass Rate %

```DAX
Control Pass Rate % =
DIVIDE(
    CALCULATE(
        COUNTROWS(fact_control_result),
        fact_control_result[control_result] = "PASS"
    ),
    CALCULATE(
        COUNTROWS(fact_control_result),
        fact_control_result[control_result] <> "N/A"
    )
)
```

Format this measure as Percentage.

In the current project output, this is approximately:

`44%`

---

## Readiness Measures

### Readiness Level

```DAX
Readiness Level =
SELECTEDVALUE(
    assurance_readiness_final[readiness_level]
)
```

Expected result:

`PARTIALLY READY`

---

### Management Conclusion

```DAX
Management Conclusion =
SELECTEDVALUE(
    assurance_readiness_final[management_conclusion]
)
```

This can be used in a card or text-capable visual to display the narrative conclusion.

---

## Supplier Measures

### Suppliers Assessed

```DAX
Suppliers Assessed =
DISTINCTCOUNT(
    dim_supplier[supplier_id]
)
```

Expected unfiltered result:

`20`

---

### Suppliers with Open Exceptions

```DAX
Suppliers with Open Exceptions =
CALCULATE(
    DISTINCTCOUNT(fact_exception[supplier_id]),
    fact_exception[closure_status] <> "CLOSED"
)
```

Current project result:

`14`

---

### Suppliers with High-Severity Exceptions

```DAX
Suppliers with High-Severity Exceptions =
CALCULATE(
    DISTINCTCOUNT(fact_exception[supplier_id]),
    fact_exception[severity] = "High",
    fact_exception[closure_status] <> "CLOSED"
)
```

Current project result:

`14`

---

### Suppliers with Reporting-Eligible Records

```DAX
Suppliers with Reporting-Eligible Records =
CALCULATE(
    DISTINCTCOUNT(
        fact_reporting_transaction[supplier_id]
    ),
    fact_reporting_transaction[governed_reporting_eligibility] = "ELIGIBLE"
)
```

Current project result:

`8`

---

## Supplier Record Measures

### Supplier Source Records

```DAX
Supplier Source Records =
COUNTROWS(
    fact_reporting_transaction
)
```

When used in a supplier-level table, the supplier dimension filters this measure to the selected supplier.

---

### Supplier Eligible Records

```DAX
Supplier Eligible Records =
CALCULATE(
    COUNTROWS(fact_reporting_transaction),
    fact_reporting_transaction[governed_reporting_eligibility] = "ELIGIBLE"
)
```

---

### Supplier Review Records

```DAX
Supplier Review Records =
CALCULATE(
    COUNTROWS(fact_reporting_transaction),
    fact_reporting_transaction[governed_reporting_eligibility] = "REVIEW"
)
```

---

### Supplier Hold Records

```DAX
Supplier Hold Records =
CALCULATE(
    COUNTROWS(fact_reporting_transaction),
    fact_reporting_transaction[governed_reporting_eligibility] = "HOLD"
)
```

---

### Supplier High Severity Exceptions

```DAX
Supplier High Severity Exceptions =
CALCULATE(
    COUNTROWS(fact_exception),
    fact_exception[severity] = "High",
    fact_exception[closure_status] <> "CLOSED"
)
```

---

### Supplier Calculated Emissions tCO2e

```DAX
Supplier Calculated Emissions tCO2e =
SUM(
    fact_reporting_transaction[governed_final_emissions_tco2e]
)
```

---

### Supplier Reporting Emissions tCO2e

```DAX
Supplier Reporting Emissions tCO2e =
SUM(
    fact_reporting_transaction[governed_reporting_emissions_tco2e]
)
```

---

## Supplier Assurance Decision

This project uses an illustrative supplier-level decision rule.

```DAX
Supplier Assurance Decision =
VAR HoldRecords =
    CALCULATE(
        COUNTROWS(fact_reporting_transaction),
        fact_reporting_transaction[governed_reporting_eligibility] = "HOLD"
    )

VAR ReviewRecords =
    CALCULATE(
        COUNTROWS(fact_reporting_transaction),
        fact_reporting_transaction[governed_reporting_eligibility] = "REVIEW"
    )

VAR HighExceptions =
    CALCULATE(
        COUNTROWS(fact_exception),
        fact_exception[severity] = "High",
        fact_exception[closure_status] <> "CLOSED"
    )

RETURN
SWITCH(
    TRUE(),
    HoldRecords > 0 || HighExceptions > 0, "HOLD",
    ReviewRecords > 0, "REVIEW REQUIRED",
    "ASSURANCE READY"
)
```

### Interpretation

`HOLD`

The supplier has at least one hold record or unresolved high-severity exception.

`REVIEW REQUIRED`

No hard hold condition remains, but review records still require attention.

`ASSURANCE READY`

No hold or review condition remains under the project logic.

This is an illustrative project rule and should not be interpreted as an official IFF decision rule.

---

## Filter Context

Most measures are designed to work with the star schema and respond to dimension filters such as:

- supplier
- municipality
- control
- control result

For example:

`dim_supplier[supplier_name]`

can filter:

- reporting transactions
- control results
- exceptions

without creating direct fact-to-fact relationships.

---

## Design Principle

The main principle behind the DAX model is:

> Business logic should be defined once and reused across visuals.

This makes the Power BI layer easier to reconcile with the Databricks Gold tables and reduces the risk of different visuals using inconsistent logic.
