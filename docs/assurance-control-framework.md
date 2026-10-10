# Assurance Control Framework

## Why this framework exists

Responsible-sourcing and ESG data can look complete on the surface and still have important gaps.

A supplier record may exist, but the location may be wrong.  
An emissions value may be calculated, but the method may not be supported.  
A supplier report may be available, but not verified.  
A sourcing record may contain a status, but the evidence behind that status may still be missing.

This framework was built to answer a simple question:

**Can this record be trusted enough to support responsible-sourcing decisions and ESG reporting?**

The goal is not to treat every issue as a failure. The goal is to make problems visible, assign ownership, document what needs to be fixed, and determine whether a record can move forward.

This is a portfolio demonstration and does not represent an official IFF control environment.

---

## How I think about assurance readiness

I separate four things that are often mixed together:

1. **Data quality** — Is the source record complete and valid?
2. **Control performance** — Did the record pass the required checks?
3. **Reporting eligibility** — Can the record enter governed ESG reporting?
4. **Assurance readiness** — Is there enough traceability and evidence for an independent reviewer to understand and reproduce the result?

A failed control does not automatically mean a confirmed ESG misstatement.

Instead, the result tells us whether the record can move forward, needs additional review, or should remain on hold.

---

## Control outcomes

Each record can receive one of four control outcomes:

- `PASS` — the control requirement is satisfied
- `REVIEW` — the issue is not necessarily a failure, but more evidence or judgment is needed
- `FAIL` — the control requirement is not satisfied
- `N/A` — the control does not apply to that record

These outcomes are tested separately so that one issue does not hide another.

---

# 1. Geographic Master-Data Validation

**Control ID:** `CTRL-GEO-001`

### What this control is trying to answer

**Can I confidently connect this supplier or farm record to the correct geographic reference data?**

This matters because the geographic risk analysis depends on accurate municipality linkage.

### What I check

Examples include:

- Does the municipality code exist?
- Does the municipality name match the reference table?
- Can the supplier or farm be linked to a valid municipality?
- Are the geographic fields needed for the analysis available?

### What can go wrong

Typical issues include:

- missing municipality code
- invalid municipality code
- inconsistent municipality name
- unresolved farm-to-municipality linkage

### Who would normally own it

**Data Governance / Data Steward**

### Why it matters

If the geography cannot be trusted, the related deforestation-risk or due-diligence signal should not automatically be used in supplier decisions.

---

# 2. Emissions Method Validation

**Control ID:** `CTRL-METHOD-001`

### What this control is trying to answer

**Is the selected Scope 3 method appropriate and supported by the information available?**

The project demonstrates three possible pathways:

- spend-based
- supplier-specific
- activity-based

### What I check

Examples include:

- Is the method recognized?
- Is the required emission factor available?
- Is the factor appropriate for the material?
- Does supplier-specific data have acceptable supporting evidence?
- Does activity-based data have a valid activity factor?

### What can go wrong

Examples include:

- activity data exist, but no valid activity factor is available
- supplier-specific emissions are reported, but the evidence is not verified
- the selected method does not match the available data
- the factor reference is missing

### Who would normally own it

**Carbon Accounting**

### Why it matters

An emissions number should not become reportable simply because it can be calculated.

The method behind the number has to be defensible.

---

# 3. Price-Year Alignment

**Control ID:** `CTRL-PRICE-001`

### What this control is trying to answer

**Are spend-based emissions being calculated on the same monetary basis as the emission factor?**

Spend-based factors are often tied to a specific reference year.

If transaction spend and the factor are based on different price years, the calculation may need an adjustment.

### What I check

Examples include:

- Is the transaction spend year known?
- Is the emission-factor reference year known?
- Has the required adjustment been applied?
- Is the aligned spend value traceable?

### Who would normally own it

**Carbon Accounting**

### Why it matters

A small methodology mismatch can become a large reporting issue when it is repeated across thousands of transactions.

---

# 4. Supplier GHG Evidence Validation

**Control ID:** `CTRL-EVID-001`

### What this control is trying to answer

**Do we have enough evidence to rely on supplier-specific GHG information?**

One of the most important lessons in this project is:

> **Evidence available does not mean evidence verified, and evidence verified does not automatically mean assurance-ready.**

### Evidence states used in the project

Examples include:

- evidence available
- evidence approved
- evidence verified
- evidence unresolved
- evidence missing

### What can go wrong

Typical issues include:

- no supplier GHG evidence
- report exists but is unverified
- review status is still pending
- evidence has been rejected
- supplier-specific emissions are provided without enough support

### Who would normally own it

**Responsible Sourcing / Carbon Accounting**

### Why it matters

Supplier-specific data can be more useful than spend-based estimates, but only when the supporting evidence is strong enough to rely on.

---

# 5. Responsible-Sourcing / DCF Validation

**Control ID:** `CTRL-DCF-001`

### What this control is trying to answer

**Is the sourcing-status information complete, valid, and supported well enough for responsible-sourcing review?**

### What I check

Examples include:

- Is the sourcing-status field populated?
- Does the value belong to an approved set of statuses?
- Is supporting evidence available where required?
- Is the sourcing status consistent with the current review decision?

### Who would normally own it

**Responsible Sourcing**

### Why it matters

A sourcing status should be more than a label in a spreadsheet.

It needs to connect to the evidence and controls that support it.

---

# 6. Final Reporting Eligibility Gate

**Control ID:** `CTRL-REPORT-001`

### What this control is trying to answer

**After all upstream checks, should this record be allowed into governed reporting?**

This is the final decision point.

The gate uses three outcomes:

- unresolved material issue → `HOLD`
- unresolved review item → `REVIEW`
- required conditions satisfied → `ELIGIBLE`

### Who would normally own it

**Data Governance / Sustainability Reporting**

### Why it matters

The final gate keeps calculation and reporting separate.

A record can have a calculated emissions value and still be excluded from reporting because its evidence, method, geography, or sourcing status is not sufficiently supported.

---

## Control-test population

The project contains:

- **100 source records**
- **6 controls**

That creates:

**100 × 6 = 600 control tests**

Each test is stored separately so the Power BI dashboard can show exactly which controls are passing, failing, or requiring review.

---

## Why I use `source_record_id`

During the project, I found an important data-quality issue:

- 100 physical source records
- 98 unique `transaction_id` values

Two transaction IDs were reused across otherwise different records.

If I had used `transaction_id` as the technical join key, the pipeline could create duplicate rows during joins.

Instead, I created:

`source_record_id`

and used it as the technical fact grain.

The original `transaction_id` is still retained as a business identifier and is tested separately for uniqueness.

This became one of the strongest data-governance lessons in the project:

> **A problem in a business identifier should remain a data-quality exception. It should not become a pipeline problem.**

---

## How exceptions are managed

A control issue is only useful if someone knows what to do next.

That is why the project converts failed or unresolved controls into an exception register.

Each exception can include:

- source record ID
- transaction ID
- supplier ID
- control ID
- exception type
- severity
- reason
- control owner
- remediation action
- evidence required
- retest result
- closure status

This turns data validation into an operational remediation process.

---

## Severity and prioritization

The project uses severity levels such as:

- High
- Medium

Severity is used to prioritize work.

It does **not** mean that a high-severity exception is automatically a confirmed reporting misstatement.

It means the issue deserves faster or more careful remediation because it has a greater potential impact on responsible-sourcing or reporting decisions.

---

## Retesting and closure

An issue is not complete just because someone has proposed a fix.

The workflow distinguishes among:

- remediation planned
- evidence received
- retest pending
- retest completed
- closed

This matters because assurance readiness depends on showing that the issue was actually resolved, not simply discussed.

---

## Control result vs reporting status

A record can have several control outcomes but only one final reporting status.

For example:

```text
PASS
PASS
REVIEW
PASS
PASS
REVIEW
```

may lead to:

`REVIEW`

while:

```text
PASS
FAIL
PASS
PASS
PASS
HOLD
```

may lead to:

`HOLD`

This is why the project keeps control results and reporting eligibility separate.

---

## How this appears in Power BI

The control and exception page uses:

- `dim_control`
- `dim_control_result`
- `fact_control_result`
- `fact_exception`

The dashboard shows:

- total control tests
- control pass rate
- PASS / REVIEW / FAIL / N/A results by control
- exceptions by type
- exceptions by owner
- exceptions by severity
- remediation actions
- evidence requirements
- retest status
- closure status

The goal is to make the control framework useful for both management and operational follow-up.

---

## What I learned from building this

The main lesson is that assurance readiness is not just about having clean numbers.

It requires a visible chain:

**source → definition → owner → control → evidence → exception → remediation → reporting decision**

Responsible sourcing becomes much more useful when the same data can answer both:

**“What is the risk?”**

and

**“Can I trust the information behind that decision?”**

That is the purpose of this framework.
