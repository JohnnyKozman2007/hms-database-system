# Student 5: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Supplier** (<u>SupplierID</u>, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, /Address, ContractStatus)

* **Insurance** (<u>InsuranceID</u>, PatientID*, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)

* **Invoice** (<u>InvoiceID</u>, PatientID*, InvoiceDate, TotalAmount, TaxAmount, Discount, DueDate, PaymentStatus)

* **Payment** (<u>PaymentID</u>, InvoiceID*, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)

---

### Key Notes & Constraints:
* `/Address` is a **derived virtual attribute** computed from (`BuildingNumber`, `Street`, `City`, `PostalCode`).
* `PostalCode` is **NOT NULL**.
* `Supplier.PhoneType` defaults to `'Landline'` and enforces `CHECK (PhoneType IN ('Landline', 'Mobile', 'Phone'))`.
* `Supplier.Phone` enforces Egyptian National Telecom Authority rules: pure digits only (`^[0-9]+$`). Mobile numbers are exactly 11 digits starting with `01`; Landlines are 9 digits (Alexandria `03`) or 10 digits (Cairo `02` and provincial governorates) starting with `0`.
* `Invoice.DueDate` has a default value of `SYSDATE + 3`.

### Foreign Key References:
* `Insurance(PatientID*)` references `Patient(PatientID)`
* `Invoice(PatientID*)` references `Patient(PatientID)`
* `Payment(InvoiceID*)` references `Invoice(InvoiceID)`
* `Medication(SupplierID*)` *(Student 4)* references `Supplier(SupplierID)`
