# Student 4: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Medication** (<u>MedicationID</u>, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID*)

* **Prescription** (<u>PrescriptionID</u>, PatientID*, DoctorID*, MedicationID*, Dosage, Frequency, Duration, PrescriptionDate, /PrescriptionTime, /EndDate, Notes)

* **LaboratoryTest** (<u>TestID</u>, PatientID*, DoctorID*, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost)

---

### Key Notes & Constraints:
* `Medication.MedicationName` is **UNIQUE** (`uq_med_name`) and **NOT NULL**, maintaining an unambiguous pharmaceutical catalog.
* `Medication.Manufacturer` is **NOT NULL**.
* `Medication.Category` is **NOT NULL** and enforces standardized pharmaceutical classes (`chk_med_category`: `IN ('Antibiotic', 'Analgesic', 'Antipyretic', 'Antihypertensive', 'Antidiabetic', 'Anticoagulant', 'Antihistamine', 'Bronchodilator', 'Statin', 'Gastrointestinal', 'Corticosteroid', 'Antidepressant', 'Antiviral', 'Cardiovascular', 'Dermatological', 'Other')`).
* `Medication.DosageForm` is **NOT NULL** and enforces approved administration forms (`chk_med_dosage_form`: `IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Inhaler', 'Drops', 'Suspension', 'Patch', 'Suppository')`).
* `Medication.UnitPrice` is **NOT NULL** and enforces positive price boundaries (`chk_med_unit_price`: `UnitPrice > 0 AND UnitPrice <= 50000.00`).
* `Medication.QuantityInStock` defaults to `0`, is **NOT NULL**, and strictly prevents negative stock levels (`chk_med_stock`: `QuantityInStock >= 0 AND QuantityInStock <= 100000`).
* `Medication.ExpirationDate` is **NOT NULL** with a valid calendar check (`chk_med_exp_date`: `ExpirationDate >= DATE '2020-01-01'`).
* `Prescription.Dosage` is **NOT NULL** (e.g., `'500 mg'`, `'10 ml'`, `'1 tablet'`).
* `Prescription.Frequency` is **NOT NULL** and enforces standard medical dosing intervals (`chk_rx_frequency`: `IN ('Once daily', 'Twice daily', 'Three times daily', 'Four times daily', 'Every 4 hours', 'Every 6 hours', 'Every 8 hours', 'Every 12 hours', 'As needed (PRN)', 'At bedtime', 'Weekly', 'Before meals', 'After meals')`).
* `Prescription.Duration` is in days, **NOT NULL**, and bounded between 1 and 365 days (`chk_rx_duration`: `Duration > 0 AND Duration <= 365`).
* `Prescription.PrescriptionDate` stores both **Date and Time** (`YYYY-MM-DD HH24:MI:SS`), defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`chk_rx_date`: `PrescriptionDate >= DATE '2020-01-01'`).
* `/PrescriptionTime` is an **auto-derived virtual attribute** extracted from `PrescriptionDate` via `TO_CHAR(PrescriptionDate, 'HH24:MI')`, ensuring exact time synchronization without redundant manual entry.
* `/EndDate` is an **auto-derived virtual attribute** calculated as `PrescriptionDate + Duration`, keeping treatment completion dates synchronized without redundant manual entry.
* `Prescription` enforces candidate uniqueness (`uq_rx_order`: `UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)`). Because `PrescriptionDate` holds the timestamp down to the minute/second, the hospital can prescribe the **same medication twice a day** (e.g., morning 08:00 and evening 20:00) while still preventing accidental duplicate orders at the exact same moment.
* `LaboratoryTest.TestType` is **NOT NULL** (e.g., `'Complete Blood Count (CBC)'`, `'Lipid Panel'`).
* `LaboratoryTest.RequestedDate` defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`chk_lab_req_date`: `RequestedDate >= DATE '2020-01-01'`).
* `LaboratoryTest.CompletedDate` is **NULLABLE** (NULL while test is pending or in progress).
* `LaboratoryTest.TestStatus` defaults to `'Pending'`, is **NOT NULL**, and enforces valid lab workflow states (`chk_lab_status`: `IN ('Pending', 'In-Progress', 'Completed', 'Cancelled', 'Sample Collected')`).
* `LaboratoryTest.TestCost` is **NOT NULL** and strictly positive (`chk_lab_cost`: `TestCost > 0 AND TestCost <= 50000.00`).
* `LaboratoryTest` enforces chronological check constraint `chk_lab_dates`: `CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate)`.
* `LaboratoryTest` enforces lifecycle synchronization `chk_lab_status_sync`: pending/in-progress tests must have `CompletedDate IS NULL`, while completed tests must possess both `CompletedDate IS NOT NULL` and `TestResult IS NOT NULL`.
* `LaboratoryTest` enforces candidate uniqueness (`uq_lab_order`: `UNIQUE (PatientID, DoctorID, TestType, RequestedDate)`), preventing duplicate test orders at the same timestamp.

### Foreign Key References:
* `Medication(SupplierID*)` references `Supplier(SupplierID)` *(Student 5)*
* `Prescription(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `Prescription(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*
* `Prescription(MedicationID*)` references `Medication(MedicationID)` *(Student 4)*
* `LaboratoryTest(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `LaboratoryTest(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*

### External Dependent Entities (Referencing Student 4):
* `Prescription(MedicationID*)` references `Medication(MedicationID)` (Intra-subsystem foreign reference from `Prescription` to `Medication`).
