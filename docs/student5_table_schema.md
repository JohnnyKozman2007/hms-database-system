# Student 5: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | <u>Composite / PK + FK*</u>

---

* **Supplier** (<u>SupplierID</u>, CompanyName, ContactPerson, Phone, Email, Address, ContractStatus)

* **Insurance** (<u>InsuranceID</u>, PatientID*, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)

* **Invoice** (<u>InvoiceID</u>, PatientID*, InvoiceDate, TotalAmount, TaxAmount, Discount, DueDate, PaymentStatus)

* **Payment** (<u>PaymentID</u>, InvoiceID*, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)

---

### Foreign Key References:
* `Insurance(PatientID*)` references `Patient(PatientID)`
* `Invoice(PatientID*)` references `Patient(PatientID)`
* `Payment(InvoiceID*)` references `Invoice(InvoiceID)`
* `Medication(SupplierID*)` *(Student 4)* references `Supplier(SupplierID)`
