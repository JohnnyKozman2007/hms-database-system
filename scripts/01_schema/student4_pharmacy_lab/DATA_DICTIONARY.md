# Student 4: Data Dictionary & Mini-Schema Specification
**Subsystem:** Pharmacy and Laboratory Management  
**Entities Owned:** `Medication`, `Prescription`, `LaboratoryTest`  
**Boundary Dependencies:** 
* `Medication` references: `Supplier(SupplierID)` (Student 5).
* `Prescription` references: `Patient(PatientID)` (Student 2), `Doctor(DoctorID)` (Student 1), and `Medication(MedicationID)` (Student 4).
* `LaboratoryTest` references: `Patient(PatientID)` (Student 2) and `Doctor(DoctorID)` (Student 1).

**Normalization Level:** Third Normal Form (3NF)

---

## 1. Entity: `Medication`
Maintains the hospital pharmacy's catalog of pharmaceutical drugs, formulation details, therapeutic categories, unit pricing, real-time stock levels, and expiration monitoring.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `MedicationID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..50+`) |
| `MedicationName` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique medication brand/generic trade name (`uq_med_name`) |
| `Manufacturer` | `VARCHAR2(100)` | NO | None | — | — | Pharmaceutical manufacturing laboratory or company |
| `Category` | `VARCHAR2(50)` | NO | None | — | — | `chk_med_category`: IN (`'Antibiotic'`, `'Analgesic'`, `'Antipyretic'`, `'Antihypertensive'`, `'Antidiabetic'`, `'Anticoagulant'`, `'Antihistamine'`, `'Bronchodilator'`, `'Statin'`, `'Gastrointestinal'`, `'Corticosteroid'`, `'Antidepressant'`, `'Antiviral'`, `'Cardiovascular'`, `'Dermatological'`, `'Other'`) |
| `DosageForm` | `VARCHAR2(30)` | NO | None | — | — | `chk_med_dosage_form`: IN (`'Tablet'`, `'Capsule'`, `'Syrup'`, `'Injection'`, `'Ointment'`, `'Cream'`, `'Inhaler'`, `'Drops'`, `'Suspension'`, `'Patch'`, `'Suppository'`) |
| `UnitPrice` | `NUMBER(10,2)` | NO | None | — | — | Retail unit price per package/unit (`chk_med_unit_price`: `UnitPrice > 0 AND UnitPrice <= 50000.00`) |
| `QuantityInStock` | `NUMBER(6)` | NO | None | — | `0` | Current physical inventory on hand (`chk_med_stock`: `QuantityInStock >= 0 AND QuantityInStock <= 100000`) |
| `ExpirationDate` | `DATE` | NO | None | — | — | Batch expiration date (`chk_med_exp_date`: `>= DATE '2020-01-01'`) |
| `SupplierID` | `NUMBER(5)` | NO | **FK** | `Supplier(SupplierID)` | — | Pharmaceutical wholesale distributor (`fk_med_supplier`) |

**Table-Level Constraints for `Medication`:**
* `pk_medication`: Enforces primary key integrity on `MedicationID`.
* `uq_med_name`: Guarantees drug trade names remain distinct in the formulary.
* `chk_med_category`: Enforces standardized pharmacotherapeutic classifications.
* `chk_med_dosage_form`: Restricts formulation types to accepted pharmaceutical administration standards.
* `chk_med_unit_price`: Guarantees medication pricing is strictly positive and bounded.
* `chk_med_stock`: Ensures inventory counts cannot drop below zero (`>= 0`).
* `chk_med_exp_date`: Validates sensible expiration calendar boundaries.
* `fk_med_supplier`: Enforces referential integrity with the accredited `Supplier` table.

---

## 2. Entity: `Prescription`
Represents clinical prescription orders issued by attending physicians, dispensing medications to patients with strict dosage regimens, administration frequencies, and duration intervals.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `PrescriptionID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..300+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient receiving the prescription (`fk_rx_patient`) |
| `DoctorID` | `NUMBER(8)` | NO | **FK** | `Doctor(DoctorID)` | — | Physician authoring the prescription (`fk_rx_doctor`) |
| `MedicationID` | `NUMBER(8)` | NO | **FK** | `Medication(MedicationID)` | — | Dispensed pharmaceutical product (`fk_rx_medication`) |
| `Dosage` | `VARCHAR2(50)` | NO | None | — | — | Prescribed strength and quantity (e.g., `'500 mg'`, `'10 ml'`) |
| `Frequency` | `VARCHAR2(50)` | NO | None | — | — | `chk_rx_frequency`: IN (`'Once daily'`, `'Twice daily'`, `'Three times daily'`, `'Four times daily'`, `'Every 4 hours'`, `'Every 6 hours'`, `'Every 8 hours'`, `'Every 12 hours'`, `'As needed (PRN)'`, `'At bedtime'`, `'Weekly'`, `'Before meals'`, `'After meals'`) |
| `Duration` | `NUMBER(3)` | NO | None | — | — | Course duration in days (`chk_rx_duration`: `Duration > 0 AND Duration <= 365`) |
| `PrescriptionDate` | `DATE` | NO | Candidate | — | `SYSDATE` | Date and timestamp order was signed (`chk_rx_date`: `>= DATE '2020-01-01'`) |
| `PrescriptionTime` | `VARCHAR2(5)` | VIRTUAL | Derived | — | Auto-derived | Auto-derived virtual column: `TO_CHAR(PrescriptionDate, 'HH24:MI')` |
| `EndDate` | `DATE` | VIRTUAL | Derived | — | Auto-derived | Auto-derived virtual column: `PrescriptionDate + Duration` |
| `Notes` | `VARCHAR2(500)` | YES | None | — | — | Special dispensing, dietary, or warning notes |

**Table-Level Constraints for `Prescription`:**
* `pk_prescription`: Enforces primary key integrity on `PrescriptionID`.
* `fk_rx_patient`: Enforces referential integrity to `Patient(PatientID)`.
* `fk_rx_doctor`: Enforces referential integrity to `Doctor(DoctorID)`.
* `fk_rx_medication`: Enforces referential integrity to `Medication(MedicationID)`.
* `chk_rx_frequency`: Standardizes intake scheduling instructions.
* `chk_rx_duration`: Validates that prescription durations are strictly positive and capped within 1 calendar year (365 days).
* `chk_rx_date`: Validates prescription date limits.
* `uq_rx_order`: `UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)` prevents duplicate prescription orders for the same drug at the exact same moment. Because `PrescriptionDate` contains the full time component (`HH24:MI:SS`), same-day prescriptions (such as morning and evening orders) are handled naturally without conflict.

---

## 3. Entity: `LaboratoryTest`
Tracks pathology and diagnostic laboratory orders requested by clinical doctors, tracking test types, sample processing stages, completion timestamps, cost, and diagnostic results.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `TestID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..200+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient undergoing diagnostic test (`fk_lab_patient`) |
| `DoctorID` | `NUMBER(8)` | NO | **FK** | `Doctor(DoctorID)` | — | Attending physician ordering the test (`fk_lab_doctor`) |
| `TestType` | `VARCHAR2(100)` | NO | Candidate | — | — | Diagnostic panel or assay name (e.g., `'Complete Blood Count (CBC)'`, `'Lipid Panel'`) |
| `RequestedDate` | `DATE` | NO | Candidate | — | `SYSDATE` | Date/time test was ordered (`chk_lab_req_date`: `>= DATE '2020-01-01'`) |
| `CompletedDate` | `DATE` | YES | None | — | — | Date/time lab analysis was completed and verified |
| `TestStatus` | `VARCHAR2(20)` | NO | None | — | `'Pending'` | `chk_lab_status`: IN (`'Pending'`, `'In-Progress'`, `'Completed'`, `'Cancelled'`, `'Sample Collected'`) |
| `TestResult` | `VARCHAR2(500)` | YES | None | — | — | Findings, quantitative measurements, or diagnostic report |
| `TestCost` | `NUMBER(10,2)` | NO | None | — | — | Standard laboratory test fee (`chk_lab_cost`: `TestCost > 0 AND TestCost <= 50000.00`) |

**Table-Level Constraints for `LaboratoryTest`:**
* `pk_laboratory_test`: Enforces primary key integrity on `TestID`.
* `fk_lab_patient`: Enforces referential integrity to `Patient(PatientID)`.
* `fk_lab_doctor`: Enforces referential integrity to `Doctor(DoctorID)`.
* `chk_lab_cost`: Guarantees laboratory test fees are strictly positive (`> 0.00`).
* `chk_lab_dates`: `CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate)` ensures lab completion cannot precede the order date.
* `chk_lab_status_sync`: Synchronizes status with dates and results:
  * Tests with status `'Pending'`, `'In-Progress'`, or `'Sample Collected'` must have `CompletedDate IS NULL`.
  * Tests with status `'Completed'` must have both `CompletedDate IS NOT NULL` and `TestResult IS NOT NULL`.
  * Tests with status `'Cancelled'` are explicitly permitted without mandatory completion dates.
* `uq_lab_order`: `UNIQUE (PatientID, DoctorID, TestType, RequestedDate)` prevents duplicate test orders for the same test on the same patient at the exact same requested time.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* **Atomic Attributes:** All fields contain indivisible atomic values (distinct units for dosage, numeric duration in days, and independent test types).
* **Derived Virtual Columns:** 
  * `/PrescriptionTime` is auto-extracted via `TO_CHAR(PrescriptionDate, 'HH24:MI')`, keeping date and time cleanly synchronized without manual input duplication (matching `AppointmentTime` in `Appointment`).
  * `/EndDate` is auto-calculated via `PrescriptionDate + Duration`, eliminating temporal redundancy while keeping prescription end dates synchronized without duplicate storage.
* **No Repeating Groups:** Multiple medications or lab tests are stored as distinct relational tuples in `Prescription` and `LaboratoryTest`, never as comma-separated strings or nested arrays.
* **Unique Identification:** Every table is uniquely keyed by a designated single-attribute primary key (`MedicationID`, `PrescriptionID`, `TestID`).

### 2NF (Second Normal Form)
* **Full Functional Dependency:** A relation is in 2NF if it satisfies 1NF and contains no partial dependencies on any candidate key.
* All three tables (`Medication`, `Prescription`, `LaboratoryTest`) employ single-attribute primary keys (`NUMBER(8)` surrogate PKs).
* Because no composite primary key is used, partial key dependencies cannot exist. All non-key attributes are fully functionally dependent on the entire primary key.

### 3NF (Third Normal Form)
* **No Transitive Dependencies:** A relation is in 3NF if it satisfies 2NF and contains no transitive dependencies ($X \to Y$ and $Y \to Z$ where $Y$ is not a superkey).
* In `Medication`: `MedicationName`, `Manufacturer`, `Category`, `DosageForm`, `UnitPrice`, `QuantityInStock`, and `ExpirationDate` describe the specific pharmaceutical product and depend strictly on `MedicationID`. Foreign key `SupplierID` references the vendor without creating transitive attributes.
* In `Prescription`: `Dosage`, `Frequency`, `Duration`, `PrescriptionDate`, `/PrescriptionTime`, `/EndDate`, and `Notes` describe the specific prescription order and depend solely on `PrescriptionID`. Foreign keys `PatientID`, `DoctorID`, and `MedicationID` define direct associations.
* In `LaboratoryTest`: `TestType`, `RequestedDate`, `CompletedDate`, `TestStatus`, `TestResult`, and `TestCost` describe the individual test specimen and depend solely on `TestID`. Foreign keys `PatientID` and `DoctorID` establish direct foreign relationships without introducing transitive dependencies.
