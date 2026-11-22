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
Maintains the hospital pharmacy's catalog of pharmaceutical drugs, formulation details, therapeutic categories, unit pricing, real-time stock levels, import dates, and expiration monitoring.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `MedicationID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_medication`; `chk_med_id`: `REGEXP_LIKE(MedicationID, '^[A-Za-z0-9_-]+$')` |
| `MedicationName` | `VARCHAR2(100)` | NO | Candidate | — | — | `chk_med_name_len`: `LENGTH(TRIM(MedicationName)) >= 5`; part of `uq_med_batch` |
| `Manufacturer` | `VARCHAR2(100)` | NO | Candidate | — | — | `chk_med_mfg_len`: `LENGTH(TRIM(Manufacturer)) >= 5`; part of `uq_med_batch` |
| `Category` | `VARCHAR2(50)` | NO | None | — | — | `chk_med_category`: IN (`'Antibiotic'`, `'Analgesic'`, `'Antipyretic'`, `'Antihypertensive'`, `'Antidiabetic'`, `'Anticoagulant'`, `'Antihistamine'`, `'Bronchodilator'`, `'Statin'`, `'Gastrointestinal'`, `'Corticosteroid'`, `'Antidepressant'`, `'Antiviral'`, `'Cardiovascular'`, `'Dermatological'`, `'Other'`) |
| `DosageForm` | `VARCHAR2(30)` | NO | Candidate | — | — | `chk_med_dosage_form`: IN (`'Tablet'`, `'Capsule'`, `'Syrup'`, `'Injection'`, `'Ointment'`, `'Cream'`, `'Inhaler'`, `'Drops'`, `'Suspension'`, `'Patch'`, `'Suppository'`); part of `uq_med_batch` |
| `UnitPrice` | `NUMBER(10,2)` | NO | None | — | — | `chk_med_unit_price`: `UnitPrice > 0 AND UnitPrice <= 50000.00` |
| `QuantityInStock` | `NUMBER(6)` | NO | None | — | `0` | `chk_med_stock`: `QuantityInStock >= 0 AND QuantityInStock <= 100000` |
| `ImportDate` | `DATE` | NO | None | — | `SYSDATE` | `chk_med_import_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_med_import_date_max` |
| `ExpirationDate` | `DATE` | NO | Candidate | — | — | `chk_med_dates`: `ExpirationDate > ImportDate`; part of `uq_med_batch` |
| `SupplierID` | `VARCHAR2(10)` | NO | **FK** | `Supplier(SupplierID)` | — | Pharmaceutical wholesale distributor (`fk_med_supplier`) |

**Table-Level Constraints for `Medication`:**
* `chk_med_dates`: `CHECK (ExpirationDate > ImportDate)`.
* `uq_med_batch`: `UNIQUE (MedicationName, Manufacturer, DosageForm, ExpirationDate)`.

---

## 2. Entity: `Prescription`
Represents clinical prescription orders issued by attending physicians, dispensing medications to patients with strict dosage regimens, administration frequencies, and duration intervals.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `PrescriptionID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_prescription`; `chk_rx_id`: `REGEXP_LIKE(PrescriptionID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient receiving the prescription (`fk_rx_patient`) |
| `DoctorID` | `VARCHAR2(10)` | NO | **FK** | `Doctor(DoctorID)` | — | Physician authoring the prescription (`fk_rx_doctor`) |
| `MedicationID` | `VARCHAR2(10)` | NO | **FK** | `Medication(MedicationID)` | — | Dispensed pharmaceutical product (`fk_rx_medication`) |
| `Dosage` | `VARCHAR2(50)` | NO | None | — | — | Prescribed strength and quantity (e.g., `'500 mg'`, `'10 ml'`) |
| `Frequency` | `VARCHAR2(50)` | NO | None | — | — | `chk_rx_frequency`: IN (`'Once daily'`, `'Twice daily'`, `'Three times daily'`, `'Four times daily'`, `'Every 4 hours'`, `'Every 6 hours'`, `'Every 8 hours'`, `'Every 12 hours'`, `'As needed (PRN)'`, `'At bedtime'`, `'Weekly'`, `'Before meals'`, `'After meals'`) |
| `Duration` | `NUMBER(3)` | NO | None | — | — | `chk_rx_duration`: `Duration > 0 AND Duration <= 365` (days) |
| `QuantityPrescribed` | `NUMBER(4)` | NO | None | — | `1` | `chk_rx_qty`: `QuantityPrescribed > 0 AND QuantityPrescribed <= 1000` |
| `DispenseStatus` | `VARCHAR2(20)` | NO | None | — | `'Pending'` | `chk_rx_dispense`: IN (`'Pending'`, `'Dispensed'`, `'Cancelled'`) |
| `PrescriptionDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_rx_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_rx_date_max` |
| `PrescriptionTime` | `VARCHAR2(5)` | VIRTUAL | Derived | — | Auto-derived | Auto-derived virtual column: `TO_CHAR(PrescriptionDate, 'HH24:MI')` |
| `EndDate` | `DATE` | VIRTUAL | Derived | — | Auto-derived | Auto-derived virtual column: `PrescriptionDate + Duration` |
| `Notes` | `VARCHAR2(500)` | YES | None | — | — | `chk_rx_notes_len`: `Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5` |

**Table-Level Constraints for `Prescription`:**
* `uq_rx_order`: `UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)`.

---

## 3. Entity: `LaboratoryTest`
Tracks pathology and diagnostic laboratory orders requested by clinical doctors, tracking test types, sample processing stages, completion timestamps, cost, and diagnostic results.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `TestID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_laboratory_test`; `chk_lab_id`: `REGEXP_LIKE(TestID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient undergoing diagnostic test (`fk_lab_patient`) |
| `DoctorID` | `VARCHAR2(10)` | NO | **FK** | `Doctor(DoctorID)` | — | Attending physician ordering the test (`fk_lab_doctor`) |
| `TestType` | `VARCHAR2(100)` | NO | Candidate | — | — | `chk_lab_type_len`: `LENGTH(TRIM(TestType)) >= 5` |
| `RequestedDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_lab_req_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_lab_date_max` |
| `CompletedDate` | `DATE` | YES | None | — | — | NULL unless `'Completed'`; capped at `SYSDATE` via `trg_lab_date_max` |
| `TestStatus` | `VARCHAR2(20)` | NO | None | — | `'Pending'` | `chk_lab_status`: IN (`'Pending'`, `'In-Progress'`, `'Completed'`, `'Cancelled'`, `'Sample Collected'`) |
| `TestResult` | `VARCHAR2(500)` | YES | None | — | — | `chk_lab_result_len`: `TestResult IS NULL OR LENGTH(TRIM(TestResult)) >= 5` |
| `TestCost` | `NUMBER(10,2)` | NO | None | — | — | `chk_lab_cost`: `TestCost > 0 AND TestCost <= 50000.00` |

**Table-Level Constraints for `LaboratoryTest`:**
* `chk_lab_dates`: `CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate)`.
* `chk_lab_status_sync`:
  * `'Pending'`, `'In-Progress'`, or `'Sample Collected'` → `CompletedDate IS NULL AND TestResult IS NULL`.
  * `'Completed'` → `CompletedDate IS NOT NULL AND TestResult IS NOT NULL`.
  * `'Cancelled'` → `CompletedDate IS NULL`.
* `uq_lab_order`: `UNIQUE (PatientID, DoctorID, TestType, RequestedDate)`.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* All fields contain indivisible atomic values; `/PrescriptionTime` and `/EndDate` are virtual derived columns eliminating temporal redundancy.

### 2NF (Second Normal Form)
* All three tables (`Medication`, `Prescription`, `LaboratoryTest`) use single-attribute `VARCHAR2(10)` primary keys (`MedicationID`, `PrescriptionID`, `TestID`), eliminating partial key dependencies.

### 3NF (Third Normal Form)
* All non-key attributes depend strictly on their respective primary keys. Prescription total cost is calculated dynamically via `QuantityPrescribed * Medication.UnitPrice` rather than stored redundantly.
