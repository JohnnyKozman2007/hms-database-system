# Student 5: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Supplier** (<u>SupplierID</u>, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, /Address, ContractStatus)

* **Insurance** (<u>InsuranceID</u>, PatientID*, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)

* **Invoice** (<u>InvoiceID</u>, PatientID*, InvoiceDate, TotalAmount, /TaxAmount, Discount, /NetAmount, DueDate, PaymentStatus)

* **Payment** (<u>PaymentID</u>, InvoiceID*, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)

---

### Key Notes & Constraints:
* `/Address` is a **derived virtual attribute** computed from (`BuildingNumber`, `Street`, `City`, `PostalCode`).
* `Supplier.PhoneType` defaults to `'Landline'` and enforces `CHECK (PhoneType IN ('Landline', 'Mobile'))`.
* `Supplier.Phone` is **UNIQUE** and **NOT NULL**, enforcing Egyptian National Telecom Authority rules: pure digits only (`^[0-9]+$`). Mobile numbers are exactly 11 digits starting with `01`; Landlines are 9 digits (Alexandria `03`) or 10 digits (Cairo `02` and provincial governorates) starting with `0`.
* `Supplier.Email` is **UNIQUE**, **NOT NULL**, and enforces format check `Email LIKE '%_@__%.__%'`.
* `Supplier.CompanyName` is **UNIQUE**, **NOT NULL**, and enforces `LENGTH(TRIM(CompanyName)) >= 2`.
* `Supplier.ContactPerson` is **NOT NULL** and enforces alphabetic formatting (`^[A-Za-z'' -]+$`, `LENGTH >= 3`).
* `Supplier.PostalCode` is **NOT NULL** and enforces `REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$')`.
* `Supplier.Street` enforces `LENGTH(TRIM(Street)) >= 3` and `Supplier.City` enforces alphabetic formatting (`^[A-Za-z'' -]+$`, `LENGTH >= 2`).
* `Insurance.PolicyNumber` is **UNIQUE**, **NOT NULL**, and enforces `REGEXP_LIKE(PolicyNumber, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(PolicyNumber)) >= 4`.
* `Insurance.CoveragePercentage` enforces `BETWEEN 0 AND 100`.
* `Insurance.StartDate` enforces `>= DATE '2020-01-01'`, is capped at `SYSDATE` via `scripts/00_global_date_triggers.sql`, and `ExpirationDate > StartDate`.
* `Insurance` enforces composite uniqueness `uq_ins_pat_comp_start`: `UNIQUE (PatientID, InsuranceCompany, StartDate)` and function-based unique index `uq_ins_one_active_comp` allowing at most one `'Active'` policy per patient per insurance company.
* `Invoice.DueDate` has a default value of `SYSDATE + 3` and enforces `CHECK (DueDate >= InvoiceDate AND DueDate <= InvoiceDate + 3)`.
* `Invoice./TaxAmount` is a **derived virtual attribute** using tiered brackets (`5%` for `TotalAmount < 1000`, `10%` for `1000..10000`, `14%` for `> 10000`).
* `Invoice./NetAmount` is a **derived virtual attribute** computed as `TotalAmount + /TaxAmount - Discount` (maintaining strict 3NF).
* `Invoice.InvoiceDate` enforces `>= DATE '2020-01-01'` and is capped at `SYSDATE` via `scripts/00_global_date_triggers.sql`.
* `Payment.TransactionReference` is **UNIQUE**, **NOT NULL**, and enforces `REGEXP_LIKE(TransactionReference, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(TransactionReference)) >= 4`.
* `Payment.PaymentDate` enforces `>= DATE '2020-01-01'`, is capped at `SYSDATE` via `scripts/00_global_date_triggers.sql`, and must be `>= Invoice.InvoiceDate` via `trg_pay_balance_and_status` (`ORA-20004`).

### Foreign Key References:
* `Insurance(PatientID*)` references `Patient(PatientID)`
* `Invoice(PatientID*)` references `Patient(PatientID)`
* `Payment(InvoiceID*)` references `Invoice(InvoiceID)`
* `Medication(SupplierID*)` *(Student 4)* references `Supplier(SupplierID)`

### Triggers & Functions Summary (Student 5):
* **`trg_ins_start_date_max`** (`00_global_date_triggers.sql`): Blocks `Insurance.StartDate` from being set in the future (`> SYSDATE`, `ORA-20001`).
* **`trg_inv_date_max`** (`00_global_date_triggers.sql`): Blocks `Invoice.InvoiceDate` from being set in the future (`> SYSDATE`, `ORA-20001`).
* **`trg_pay_date_max`** (`00_global_date_triggers.sql`): Blocks `Payment.PaymentDate` from being set in the future (`> SYSDATE`, `ORA-20001`).
* **`trg_ins_status_date_guard`** (`student5_triggers.sql`): Blocks inserting/updating `Insurance` as `'Active'` when `ExpirationDate < SYSDATE` (`ORA-20005`) or as `'Expired'` when `ExpirationDate >= SYSDATE` (`ORA-20006`).
* **`trg_inv_status_guard`** (`student5_triggers.sql`): Blocks fake `INSERT`/`UPDATE` of `Invoice.PaymentStatus` (`ORA-20007..20009`), prevents reducing `NetAmount` below completed payments (`ORA-20002`), and auto-recalculates `PaymentStatus` if `TotalAmount`, `Discount`, or `DueDate` is edited.
* **`trg_pay_check_insurance`** (`student5_triggers.sql`): Auto-flips any past-due `'Active'` policies to `'Expired'` and rejects `'Insurance Claim'` payments if the patient lacks an `'Active'`, unexpired policy (`ORA-20003`).
* **`trg_pay_balance_and_status`** (`student5_triggers.sql`): Compound trigger that auto-expires past-due `'Active'` insurance policies, blocks payments dated before `Invoice.InvoiceDate` (`ORA-20004`), prevents overpaying above `Invoice.NetAmount` (`ORA-20002`), and auto-updates `Invoice.PaymentStatus` (`'Paid'`, `'Partially Paid'`, `'Overdue'`, `'Unpaid'`).
* **`fn_get_patient_net_balance`** (`student5_function.sql`): Returns a patient's total remaining unpaid balance across all invoices and `'Completed'` payments.
* **`fn_get_invoice_patient_copay`** (`student5_function.sql`): Returns the patient's out-of-pocket amount on an invoice after applying their highest active insurance coverage percentage.
* **`fn_get_patient_financial_status`** (`student5_function.sql`): Applies a `+10%` compound weekly late penalty for each full week past `DueDate` and returns `'CLEAR'`, `'ACTIVE TAB'`, `'WARNING'`, or `'BANNED - OVERDUE'`.
