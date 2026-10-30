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
| `SupplierID` | `NUMBER(5)` | NO | **PK** | — | — | Primary identifier (Range: `1..15+`) |
| `CompanyName` | `VARCHAR2(100)` | NO | Candidate | — | — | Must be unique (`uq_supp_name`) |
| `ContactPerson` | `VARCHAR2(100)` | NO | None | — | — | Name of vendor representative |
| `Phone` | `VARCHAR2(20)` | NO | None | — | — | Contact telephone number |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email (`uq_supp_email`), valid email format |
| `Address` | `VARCHAR2(150)` | NO | None | — | — | Physical headquarters / depot address |
| `ContractStatus`| `VARCHAR2(20)` | NO | None | — | `'Active'` | `chk_supp_status`: IN (`'Active'`, `'Inactive'`, `'Terminated'`, `'Under Review'`) |

---

## 2. Entity: `Insurance`
Stores health insurance policies linked to patients for claim settlements.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `InsuranceID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..100+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient covered by this policy (`fk_ins_pat`) |
| `InsuranceCompany`| `VARCHAR2(100)` | NO | None | — | — | Name of insurer (e.g. Bupa, AXA, NHS) |
| `PolicyNumber` | `VARCHAR2(50)` | NO | Candidate | — | — | Unique contract number (`uq_ins_policy`) |
| `CoveragePercentage`| `NUMBER(5,2)` | NO | None | — | — | `chk_ins_cov`: BETWEEN `0.00` AND `100.00` |
| `StartDate` | `DATE` | NO | None | — | — | Policy effective date |
| `ExpirationDate`| `DATE` | NO | None | — | — | `chk_ins_dates`: Must be `>= StartDate` |
| `InsuranceStatus`| `VARCHAR2(20)` | NO | None | — | `'Active'` | `chk_ins_status`: IN (`'Active'`, `'Expired'`, `'Cancelled'`, `'Suspended'`) |

---

## 3. Entity: `Invoice`
Records billing summaries issued to patients for hospital consultations, procedures, and stays.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `InvoiceID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..200+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Debtor / patient receiving bill (`fk_inv_pat`) |
| `InvoiceDate` | `DATE` | NO | None | — | `SYSDATE` | Date invoice was generated |
| `TotalAmount` | `NUMBER(10,2)` | NO | None | — | — | `chk_inv_total`: `>= 0.00` |
| `TaxAmount` | `NUMBER(10,2)` | NO | None | — | `0.00` | `chk_inv_tax`: `>= 0.00` |
| `Discount` | `NUMBER(10,2)` | NO | None | — | `0.00` | `chk_inv_disc`: `>= 0.00 AND <= TotalAmount` |
| `DueDate` | `DATE` | NO | None | — | — | `chk_inv_dates`: Must be `>= InvoiceDate` |
| `PaymentStatus`| `VARCHAR2(20)` | NO | None | — | `'Unpaid'` | `chk_inv_status`: IN (`'Paid'`, `'Unpaid'`, `'Partially Paid'`, `'Overdue'`) |

---

## 4. Entity: `Payment`
Tracks financial transactions and payment receipts made against issued invoices.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `PaymentID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..250+`) |
| `InvoiceID` | `NUMBER(8)` | NO | **FK** | `Invoice(InvoiceID)` | — | Associated invoice (`fk_pay_inv`) |
| `PaymentDate` | `DATE` | NO | None | — | `SYSDATE` | Timestamp of payment transaction |
| `AmountPaid` | `NUMBER(10,2)` | NO | None | — | — | `chk_pay_amt`: `> 0.00` (Strictly positive) |
| `PaymentMethod`| `VARCHAR2(30)` | NO | None | — | — | `chk_pay_method`: IN (`'Cash'`, `'Credit Card'`, `'Debit Card'`, `'Bank Transfer'`, `'Insurance Claim'`) |
| `TransactionReference`| `VARCHAR2(100)` | NO | Candidate | — | — | Unique bank/gateway receipt ref (`uq_pay_ref`) |
| `PaymentStatus`| `VARCHAR2(20)` | NO | None | — | `'Completed'` | `chk_pay_status`: IN (`'Completed'`, `'Pending'`, `'Failed'`, `'Refunded'`) |

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
