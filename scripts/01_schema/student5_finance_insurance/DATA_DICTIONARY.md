# Student 5: Data Dictionary & Mini-Schema Specification
**Subsystem:** Finance and Insurance Management  
**Entities Owned:** `Supplier`, `Insurance`, `Invoice`, `Payment`  
**Boundary Dependencies:** `Patient` (Owner: Student 2), `Medication` (Owner: Student 4)  
**Normalization Level:** Third Normal Form (3NF)

---

## 1. Entity: `Supplier`
Stores approved vendors and pharmaceutical suppliers providing medical supplies and drugs.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `SupplierID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_supplier`; `chk_supp_id`: `REGEXP_LIKE(SupplierID, '^[A-Za-z0-9_-]+$')` |
| `CompanyName` | `VARCHAR2(100)` | NO | Candidate | — | — | `uq_supp_name`; `chk_supp_company_len`: `LENGTH(TRIM(CompanyName)) >= 2` |
| `ContactPerson` | `VARCHAR2(100)` | NO | None | — | — | `chk_supp_contact_fmt`: `REGEXP_LIKE(ContactPerson, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(ContactPerson)) >= 3` |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique contact telephone number (`uq_supp_phone`) |
| `PhoneType` | `VARCHAR2(10)` | NO | None | — | `'Landline'` | `chk_supp_phone_type`: IN (`'Landline'`, `'Mobile'`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | `uq_supp_email`; `chk_supp_email_fmt`: `LIKE '%_@__%.__%'` |
| `BuildingNumber` | `VARCHAR2(20)` | YES | None | — | — | Building/Premises number or name |
| `Street` | `VARCHAR2(100)` | NO | None | — | — | `chk_supp_street_len`: `LENGTH(TRIM(Street)) >= 3` |
| `City` | `VARCHAR2(50)` | NO | None | — | — | `chk_supp_city_fmt`: `REGEXP_LIKE(City, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(City)) >= 2` |
| `PostalCode` | `VARCHAR2(20)` | NO | None | — | — | `chk_supp_postal`: `REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$')` |
| `Address` | `VARCHAR2(250)` | VIRTUAL | Derived | — | Auto-derived | Derived column: `NVL2(BuildingNumber, BuildingNumber \|\| ' ', '') \|\| Street \|\| ', ' \|\| City \|\| ' ' \|\| PostalCode` |
| `ContractStatus` | `VARCHAR2(20)` | NO | None | — | `'Active'` | `chk_supp_status`: IN (`'Active'`, `'Inactive'`, `'Terminated'`, `'Under Review'`) |

**Table-Level Constraints for `Supplier`:**
* `chk_supp_phone`: Pure digits (`^[0-9]+$`). Egyptian landlines must be 9–10 digits starting with `0`; mobile numbers must be 11 digits starting with `01`.

---

## 2. Entity: `Insurance`
Stores health insurance policies linked to patients for claim settlements.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `InsuranceID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_insurance`; `chk_ins_id`: `REGEXP_LIKE(InsuranceID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient covered by this policy (`fk_ins_patient`) |
| `InsuranceCompany` | `VARCHAR2(100)` | NO | Candidate | — | — | `chk_ins_company`: IN (`'AXA Egypt'`, `'Bupa Egypt'`, `'Allianz Egypt'`, `'MetLife Egypt'`, `'Misr Insurance'`, `'GIG Egypt'`, `'Delta Insurance'`, `'Universal Health Insurance'`) |
| `PolicyNumber` | `VARCHAR2(50)` | NO | Candidate | — | — | `uq_ins_policy`; `chk_ins_policy_fmt`: `REGEXP_LIKE(PolicyNumber, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(PolicyNumber)) >= 4` |
| `CoveragePercentage` | `NUMBER(5,2)` | NO | None | — | — | `chk_ins_cov`: `BETWEEN 0 AND 100` |
| `StartDate` | `DATE` | NO | Candidate | — | — | `chk_ins_start_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_ins_start_date_max` |
| `ExpirationDate` | `DATE` | NO | None | — | — | `chk_ins_dates`: `ExpirationDate > StartDate` |
| `InsuranceStatus` | `VARCHAR2(20)` | NO | None | — | `'Active'` | `chk_ins_status`: IN (`'Active'`, `'Expired'`, `'Cancelled'`, `'Suspended'`) |

**Table-Level Constraints & Indexes for `Insurance`:**
* `uq_ins_pat_comp_start`: `UNIQUE (PatientID, InsuranceCompany, StartDate)`.
* `uq_ins_one_active_comp`: Function-based unique index preventing more than one `'Active'` policy per `(PatientID, InsuranceCompany)`.

---

## 3. Entity: `Invoice`
Records billing summaries issued to patients for hospital consultations, procedures, and stays.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `InvoiceID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_invoice`; `chk_inv_id`: `REGEXP_LIKE(InvoiceID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Debtor / patient receiving bill (`fk_inv_patient`) |
| `InvoiceDate` | `DATE` | NO | None | — | `SYSDATE` | `chk_inv_date_lower`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_inv_date_max` |
| `TotalAmount` | `NUMBER(10,2)` | NO | None | — | — | `chk_inv_total`: `TotalAmount > 0` |
| `TaxAmount` | `NUMBER(10,2)` | VIRTUAL | Derived | — | Auto-derived | Tiered virtual tax: `5%` (`< 1000`), `10%` (`1000..10000`), `14%` (`> 10000`) |
| `Discount` | `NUMBER(10,2)` | NO | None | — | `0.00` | `chk_inv_disc`: `Discount >= 0 AND Discount <= TotalAmount` |
| `NetAmount` | `NUMBER(12,2)` | VIRTUAL | Derived | — | Auto-derived | Virtual column: `TotalAmount + TaxAmount - Discount` (3NF compliant) |
| `DueDate` | `DATE` | NO | None | — | `SYSDATE + 3` | `chk_inv_dates`: `DueDate >= InvoiceDate AND DueDate <= InvoiceDate + 3` |
| `PaymentStatus` | `VARCHAR2(20)` | NO | None | — | `'Unpaid'` | `chk_inv_status`: IN (`'Unpaid'`, `'Overdue'`, `'Partially Paid'`, `'Paid'`) |

---

## 4. Entity: `Payment`
Tracks financial transactions and payment receipts made against issued invoices.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `PaymentID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_payment`; `chk_pay_id`: `REGEXP_LIKE(PaymentID, '^[A-Za-z0-9_-]+$')` |
| `InvoiceID` | `VARCHAR2(10)` | NO | **FK** | `Invoice(InvoiceID)` | — | Associated invoice (`fk_pay_invoice`) |
| `PaymentDate` | `DATE` | NO | None | — | `SYSDATE` | `chk_pay_date_lower`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_pay_date_max`; `>= Invoice.InvoiceDate` via `trg_pay_balance_and_status` |
| `AmountPaid` | `NUMBER(10,2)` | NO | None | — | — | `chk_pay_amt`: `AmountPaid > 0` |
| `PaymentMethod` | `VARCHAR2(30)` | NO | None | — | — | `chk_pay_method`: IN (`'Cash'`, `'Credit Card'`, `'Debit Card'`, `'Bank Transfer'`, `'Insurance Claim'`) |
| `TransactionReference` | `VARCHAR2(100)` | NO | Candidate | — | — | `uq_pay_ref`; `chk_pay_ref_fmt`: `REGEXP_LIKE(TransactionReference, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(TransactionReference)) >= 4` |
| `PaymentStatus` | `VARCHAR2(20)` | NO | None | — | `'Completed'` | `chk_pay_status`: IN (`'Completed'`, `'Pending'`, `'Failed'`, `'Refunded'`) |

---

## 5. Relationships & Integration Map

```
                  ┌───────────────────────┐
                  │ Patient (Student 2)   │
                  └───────────┬───────────┘
                              │
             ┌────────────────┴────────────────┐
        1 : M│                             1 : M│
             ▼                                  ▼
      ┌─────────────┐                    ┌─────────────┐
      │  Insurance  │                    │   Invoice   │
      └─────────────┘                    └──────┬──────┘
                                                │
                                           1 : M│
                                                ▼
                                         ┌─────────────┐
                                         │   Payment   │
                                         └─────────────┘

      ┌─────────────┐
      │  Supplier   │
      └──────┬──────┘
             │
        1 : M│
             ▼
  Medication (Student 4)
```
