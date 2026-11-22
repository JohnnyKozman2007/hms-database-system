# Student 2: Data Dictionary & Mini-Schema Specification
**Subsystem:** Patient and Admission Management  
**Entities Owned:** `Patient`, `Room`, `Admission`  
**Boundary Dependencies:** 
* `Patient` is referenced by: `Admission` (Student 2), `Appointment` (Student 3), `MedicalRecord` (Student 3), `MedicalProcedure` (Student 3), `Prescription` (Student 4), `LaboratoryTest` (Student 4), `Insurance` (Student 5), `Invoice` (Student 5).
* `Room` is referenced by: `Admission` (Student 2).
* `Admission` references: `Patient(PatientID)` (Student 2) and `Room(RoomID)` (Student 2).

**Normalization Level:** Third Normal Form (3NF)

---

## 1. Entity: `Patient`
Stores demographic, personal identification, contact details, and baseline medical information for registered hospital patients.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `PatientID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_patient`; `chk_pat_id`: `REGEXP_LIKE(PatientID, '^[A-Za-z0-9_-]+$')` |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | `chk_pat_fname`: `REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$')` |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | `chk_pat_lname`: `REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$')` |
| `FullName` | `VARCHAR2(101)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `FirstName \|\| ' ' \|\| LastName` |
| `DateOfBirth` | `DATE` | NO | None | — | — | `chk_pat_dob`: `>= DATE '1900-01-01'`; capped at `SYSDATE` via `trg_pat_dob_max` |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_pat_gender`: IN (`'Male'`, `'Female'`) |
| `BloodType` | `VARCHAR2(5)` | NO | None | — | — | `chk_pat_blood`: IN (`'A+'`, `'A-'`, `'B+'`, `'B-'`, `'AB+'`, `'AB-'`, `'O+'`, `'O-'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique primary telephone number (`uq_pat_phone`) |
| `PhoneType` | `VARCHAR2(10)` | NO | None | — | `'Mobile'` | `chk_pat_phone_type`: IN (`'Mobile'`, `'Landline'`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email (`uq_pat_email`), format check `chk_pat_email_fmt`: `LIKE '%_@__%.__%'` |
| `BuildingNumber` | `VARCHAR2(20)` | YES | None | — | — | Building/Apartment/House number (standardized with `Supplier`) |
| `Street` | `VARCHAR2(100)` | NO | None | — | — | `chk_pat_street_len`: `LENGTH(TRIM(Street)) >= 3` |
| `City` | `VARCHAR2(50)` | NO | None | — | — | `chk_pat_city_fmt`: `REGEXP_LIKE(City, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(City)) >= 2` |
| `PostalCode` | `VARCHAR2(20)` | NO | None | — | — | `chk_pat_postal`: `REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$')` |
| `Address` | `VARCHAR2(250)` | VIRTUAL | Derived | — | Auto-derived | Derived column: `NVL2(BuildingNumber, BuildingNumber \|\| ' ', '') \|\| Street \|\| ', ' \|\| City \|\| ' ' \|\| PostalCode` |
| `EmergencyContact` | `VARCHAR2(20)` | NO | None | — | — | `chk_pat_emg`: `<> Phone`; `chk_pat_emg_num`: 11-digit Egyptian mobile (`^[0-9]+$`, starts with `'01'`) |

**Table-Level Constraints for `Patient`:**
* `chk_pat_phone`: Pure digits (`^[0-9]+$`). Mobile must be 11 digits starting with `01`; Landline must be 9–10 digits starting with `0`.
* `chk_pat_emg` & `chk_pat_emg_num`: Guarantees emergency contact differs from `Phone` and is a valid 11-digit Egyptian mobile number.

---

## 2. Entity: `Room`
Stores physical accommodation units across hospital buildings, floors, and care units, including capacity, daily billing tariffs, and live availability.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `RoomID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_room`; `chk_room_id`: `REGEXP_LIKE(RoomID, '^[A-Za-z0-9_-]+$')` |
| `RoomNumber` | `VARCHAR2(10)` | NO | Candidate | — | — | `chk_room_number_fmt`: `REGEXP_LIKE(RoomNumber, '^[A-Za-z0-9-]+$')`; part of `uq_room_bldg_floor_num` |
| `Building` | `VARCHAR2(50)` | NO | Candidate | — | — | `chk_room_bldg`: IN (`'Building A'`, `'Building B'`, `'Building C'`, `'Building D'`); part of `uq_room_bldg_floor_num` |
| `Floor` | `VARCHAR2(20)` | NO | Candidate | — | — | `chk_room_floor`: IN (`'Ground Floor'`, `'1st Floor'`, `'2nd Floor'`, `'3rd Floor'`, `'4th Floor'`, `'5th Floor'`); part of `uq_room_bldg_floor_num` |
| `RoomType` | `VARCHAR2(30)` | NO | None | — | — | `chk_room_type`: IN (`'General Ward'`, `'Semi-Private'`, `'Private'`, `'ICU'`, `'Isolation'`, `'Emergency'`, `'Maternity'`, `'Pediatric'`, `'Operating Room'`) |
| `Capacity` | `NUMBER(3)` | NO | None | — | `1` | `chk_room_capacity`: `Capacity > 0 AND Capacity <= 20` |
| `DailyCharge` | `NUMBER(10,2)` | NO | None | — | — | `chk_room_charge`: `DailyCharge > 0 AND DailyCharge <= 10000.00` |
| `AvailabilityStatus` | `VARCHAR2(20)` | NO | None | — | `'Available'` | `chk_room_status`: IN (`'Available'`, `'Occupied'`, `'Maintenance'`, `'Reserved'`) |

**Table-Level Constraints for `Room`:**
* `uq_room_bldg_floor_num`: `UNIQUE (Building, Floor, RoomNumber)`.
* `chk_room_type_cap`: `'Private'`, `'ICU'`, and `'Isolation'` rooms must have `Capacity = 1`; `'Semi-Private'` rooms must have `Capacity = 2`.

---

## 3. Entity: `Admission`
Tracks inpatient hospital admissions, linking a patient to a designated room, with timestamps for admission and discharge, clinical reason, and status.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `AdmissionID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_admission`; `chk_adm_id`: `REGEXP_LIKE(AdmissionID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient being admitted (`fk_adm_patient`) |
| `RoomID` | `VARCHAR2(10)` | NO | **FK** | `Room(RoomID)` | — | Room assigned for the stay (`fk_adm_room`) |
| `AdmissionDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_adm_date_lower`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_adm_date_max` |
| `DischargeDate` | `DATE` | YES | None | — | — | NULL while `'Admitted'`; capped at `SYSDATE` via `trg_adm_date_max` |
| `AdmissionReason` | `VARCHAR2(255)` | NO | None | — | — | `chk_adm_reason_len`: `LENGTH(TRIM(AdmissionReason)) >= 5` |
| `AdmissionStatus` | `VARCHAR2(20)` | NO | None | — | `'Admitted'` | `chk_adm_status`: IN (`'Admitted'`, `'Discharged'`) |

**Table-Level Constraints & Indexes for `Admission`:**
* `chk_adm_dates`: `CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)`.
* `chk_adm_status_sync`: `CHECK ((AdmissionStatus = 'Admitted' AND DischargeDate IS NULL) OR (AdmissionStatus = 'Discharged' AND DischargeDate IS NOT NULL))`.
* `uq_adm_pat_date`: `UNIQUE (PatientID, AdmissionDate)`.
* `uq_adm_one_active_stay`: Function-based unique index on `(CASE WHEN AdmissionStatus = 'Admitted' THEN PatientID END)` allowing at most one active stay per patient.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* All stored values are indivisible and atomic. `Address` is decomposed into `BuildingNumber`, `Street`, `City`, and `PostalCode` with virtual `Address`; `FullName` is virtual from `FirstName` and `LastName`.
* No repeating groups exist; each admission is a distinct tuple in `Admission`.

### 2NF (Second Normal Form)
* All three entities (`Patient`, `Room`, `Admission`) use single-column `VARCHAR2(10)` primary keys (`PatientID`, `RoomID`, `AdmissionID`), eliminating partial dependencies.

### 3NF (Third Normal Form)
* No transitive dependencies exist; all non-key attributes depend solely on their entity primary key.
