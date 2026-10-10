# Limitations

## Why this section matters

This project is designed as a portfolio demonstration of responsible-sourcing analytics, data governance, Scope 3 controls, geospatial risk, and assurance readiness.

It is not an official IFF system, supplier assessment, audit, or assurance engagement.

Being clear about those boundaries is important because some of the project outputs look similar to real enterprise reporting and supplier-risk workflows.

---

## 1. Synthetic operational data

The supplier, procurement, transaction, farm, and evidence records used in this project are synthetic.

They are designed to demonstrate the workflow, not to represent actual IFF operational data.

The project does not contain confidential supplier, procurement, or assurance records.

---

## 2. Public company materials are used only for context

IFF public sustainability and responsible-sourcing materials are used as business-context references.

They help shape the type of controls and sourcing questions explored in the project.

The project does not claim that the workflow, control logic, or decision rules shown here are official IFF processes.

---

## 3. Geographic risk is contextual

The project uses public geographic indicators to support supplier due diligence.

Examples include municipality-level soy deforestation exposure and MapBiomas alert information.

These indicators help answer questions such as:

**Which sourcing areas may deserve additional review?**

They do not answer:

**Did this supplier cause deforestation?**

Geographic risk is therefore treated as landscape-level context, not evidence of supplier wrongdoing or causation.

---

## 4. Synthetic farm points

Farm locations used in the QGIS workflow are synthetic.

They are placed within real Brazilian municipalities to demonstrate:

- supplier-to-farm linkage
- farm-to-municipality linkage
- geographic validation
- responsible-sourcing risk analysis

They should not be interpreted as real supplier farm locations.

---

## 5. Scope 3 methodology is illustrative

The project demonstrates several Scope 3 Category 1 pathways, including:

- spend-based
- supplier-specific
- activity-based

The methodology is intended to show governance and control logic.

It is not a complete corporate Scope 3 inventory or external assurance calculation.

---

## 6. Supplier evidence is illustrative

Supplier evidence records are synthetic.

The project intentionally distinguishes:

- evidence available
- evidence reviewed
- evidence verified
- evidence assurance-ready

This logic demonstrates evidence governance but does not represent actual supplier verification results.

---

## 7. Decision rules are project rules

Statuses such as:

- `ELIGIBLE`
- `REVIEW`
- `HOLD`

and supplier-level decision logic such as:

- `ASSURANCE READY`
- `REVIEW REQUIRED`
- `HOLD`

are project-defined demonstration rules.

They should not be interpreted as official IFF policies or formal assurance criteria.

---

## 8. Control failures are not confirmed misstatements

A failed or unresolved control indicates that additional work may be needed.

It does not automatically mean that:

- the underlying ESG value is wrong,
- the supplier is noncompliant,
- a reporting misstatement has occurred,
- or wrongdoing has taken place.

The project separates control findings from final reporting and assurance conclusions.

---

## 9. Public data can change

External datasets and reference methodologies may change over time.

Examples include:

- emissions factors
- geographic boundaries
- deforestation indicators
- public sourcing requirements
- reference-year assumptions

A production implementation would require version control and periodic updates.

---

## 10. Portfolio scope

The goal of this project is to demonstrate how I approach the full decision chain:

**supplier data → responsible-sourcing controls → evidence → geographic risk → Scope 3 → exceptions → remediation → reporting eligibility**

The emphasis is on integration, governance, traceability, and decision support rather than reproducing a full enterprise responsible-sourcing platform.
