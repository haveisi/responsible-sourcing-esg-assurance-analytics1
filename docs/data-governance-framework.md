# Data Governance Framework

## Why data governance matters here

Responsible-sourcing analysis depends on many different pieces of information working together:

- supplier IDs
- transaction records
- sourcing status
- farm and municipality information
- emissions factors
- supplier evidence
- control results

If those pieces are defined differently, owned by different teams, or joined incorrectly, the final dashboard may still look polished while the underlying decision is unreliable.

For this project, I treat data governance as the rules that make the data understandable, controlled, traceable, and usable.

A simple way I summarize it is:

**Define → Own → Source → Check → Trace → Approve**

---

## 1. Define

The first question is:

**What exactly does each field mean?**

Examples include:

- What is a supplier?
- What counts as a transaction?
- What does `HOLD` mean?
- What qualifies as supplier GHG evidence?
- What does “reporting eligible” mean?
- Which municipality code is the governed reference?

Without clear definitions, two teams can use the same field name but mean different things.

In this project, definitions are standardized before the data moves into reporting.

---

## 2. Own

The second question is:

**Who is responsible for the data and the decision?**

I separate several roles.

### Data owner

Accountable for the business meaning and use of the data.

Example:
Responsible Sourcing may own sourcing-status requirements.

### Data steward

Helps maintain quality, definitions, reference values, and issue resolution.

### Data custodian

Maintains the technical system, tables, access, and pipelines.

### Data producer

Creates or supplies the original data.

This matters because an exception should have a clear owner rather than simply appearing in a dashboard.

---

## 3. Source

The next question is:

**Where did the value come from?**

The pipeline preserves the distinction between:

- source value
- standardized value
- governed value
- calculated value
- reporting value

For example, a transaction may have an original municipality field from the source file, but the governed reporting value should come from a validated municipality reference.

This allows the workflow to preserve lineage instead of overwriting the original data.

---

## 4. Check

Once the data are standardized, the next question is:

**Is the data good enough to use?**

The project checks several dimensions of data quality.

### Completeness

Are required fields present?

### Validity

Does the value belong to an accepted domain or reference list?

### Consistency

Do related fields agree with each other?

### Uniqueness

Should this identifier appear only once?

### Traceability

Can the value be connected to its source and supporting evidence?

### Methodological validity

Is the selected calculation or sourcing method appropriate?

---

## 5. Trace

The next question is:

**Can someone follow the record from source to decision?**

The project preserves a chain like:

`source record → standardized record → control result → exception → remediation → reporting decision`

This is especially important for assurance.

An independent reviewer should be able to understand:

- where the value came from
- which rule was applied
- what failed
- what evidence was reviewed
- who owned remediation
- why the final status changed

---

## 6. Approve

The final governance question is:

**Who decides whether the record can move forward?**

The project separates calculation from approval.

A record may have a calculated Scope 3 emissions value but still be placed on hold because:

- the supplier evidence is insufficient
- the sourcing status is unresolved
- the geography is invalid
- the methodology is unsupported

This prevents calculated values from automatically becoming reportable values.

---

## Master Data

Several fields function as master or reference data in the project.

Examples include:

- supplier ID
- material ID
- farm ID
- municipality code
- emissions-factor ID
- control ID

These fields are important because they connect different parts of the workflow.

Master data should be:

- standardized
- unique where required
- governed
- documented
- used consistently across facts

---

## Why the technical key matters

One of the strongest governance findings in the project was the difference between a business key and a technical key.

The source contains:

- 100 physical records
- 98 unique transaction IDs

Two `transaction_id` values are reused across otherwise distinct records.

That means `transaction_id` is useful as a business identifier but is not safe as the technical fact-table key.

The pipeline therefore creates:

`source_record_id`

and uses it as the technical grain.

The original transaction ID is preserved and tested separately.

This avoids turning a source data-quality issue into a join or duplication problem.

---

## Reference Data

The project also relies on reference data such as:

- municipality codes
- municipality names
- state codes
- material mappings
- emissions factors
- control definitions
- accepted result values

Reference data help keep interpretation consistent across systems and teams.

---

## Data Lineage

For every governed value, the goal is to know:

**Where did it come from?**

For example:

```text
Procurement transaction
        ↓
Spend value
        ↓
Price-year adjustment
        ↓
Approved emission factor
        ↓
Calculated emissions
        ↓
Method validation
        ↓
Reporting gate
        ↓
Reported or excluded emissions
```

The same idea applies to responsible-sourcing fields and geographic risk.

---

## Exception Ownership

Data governance is not complete when an error is found.

The next question is:

**Who owns the fix?**

The project assigns exceptions to functions such as:

- Responsible Sourcing
- Carbon Accounting
- Data Governance
- Data Steward

This creates accountability and helps move the issue from detection to remediation.

---

## Access and Separation of Duties

Although this portfolio project does not implement a full enterprise access-control model, a production environment would normally separate:

- data entry
- data validation
- approval
- reporting
- assurance review

This reduces the risk that the same person can create, approve, and report the same record without independent review.

---

## Governance in the Databricks Architecture

The Bronze / Silver / Gold structure supports governance in a practical way.

### Bronze

Preserves what arrived from the source.

### Silver

Standardizes, validates, and applies business rules.

### Gold

Publishes controlled outputs for reporting and decision-making.

This structure helps separate raw information from governed information.

---

## Governance in Power BI

Power BI should consume governed Gold tables rather than reconstructing business logic independently.

The reporting model uses dimensions such as:

- supplier
- municipality
- control
- control result

and facts such as:

- reporting transaction
- control result
- exception

This reduces duplicated logic and makes dashboard results easier to reconcile with Databricks.

---

## Governance vs Data Management

I treat these as related but different.

**Data management** is about moving, storing, transforming, and maintaining data.

**Data governance** is about deciding:

- what the data means
- who owns it
- which rules apply
- who can approve it
- what happens when it fails

A useful analogy is:

> Data management is driving the car.  
> Data governance is the traffic rules, road signs, licensing, and accountability system that determine how the car should be driven.

Both are necessary.

---

## What I learned from building this

The biggest lesson is that data governance is not mainly about documentation.

It becomes useful when governance changes what the system actually does.

In this project, governance determines:

- which identifiers are trusted
- which evidence is sufficient
- which methodology is accepted
- which exception needs an owner
- which record is eligible
- which record must remain on hold

That is the point where governance becomes part of the decision process rather than a policy sitting beside it.
```
