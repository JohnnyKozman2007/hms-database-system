# Student 3: Data Dictionary & Mini-Schema Specification
**Subsystem:** Appointments and Medical Records  
**Entities Owned:** `Appointment`, `MedicalRecord`, `MedicalProcedure`  
**Boundary Dependencies:** 
* `Appointment` references: `Patient(PatientID)` (Student 2) and `Doctor(DoctorID)` (Student 1).
* `MedicalRecord` references: `Patient(PatientID)` (Student 2) and `Doctor(DoctorID)` (Student 1).
* `MedicalProcedure` references: `Patient(PatientID)` (Student 2) and `Doctor(DoctorID)` (Student 1).

**Normalization Level:** Third Normal Form (3NF)

---

## 1. Entity: `Appointment`
Tracks clinical outpatient visits and specialist consultations scheduled between a registered patient and an attending doctor.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `AppointmentID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_appointment`; `chk_apt_id`: `REGEXP_LIKE(AppointmentID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient booked for the appointment (`fk_apt_patient`) |
| `DoctorID` | `VARCHAR2(10)` | NO | **FK** | `Doctor(DoctorID)` | — | Doctor conducting the consultation (`fk_apt_doctor`) |
| `AppointmentDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_apt_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE + 365` via `trg_apt_date_horizon` |
| `AppointmentTime` | `VARCHAR2(5)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `TO_CHAR(AppointmentDate, 'HH24:MI')` |
| `Status` | `VARCHAR2(20)` | NO | None | — | `'Scheduled'` | `chk_apt_status`: IN (`'Scheduled'`, `'Completed'`, `'Cancelled'`, `'No-Show'`, `'In-Progress'`, `'Rescheduled'`) |
| `Reason` | `VARCHAR2(255)` | NO | None | — | — | `chk_apt_reason_len`: `LENGTH(TRIM(Reason)) >= 5` |
| `Notes` | `VARCHAR2(500)` | YES | None | — | — | `chk_apt_notes_len`: `Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5` (mandatory for Cancelled/Rescheduled/No-Show) |

**Table-Level Constraints for `Appointment`:**
* `chk_apt_status_note`: `CHECK (Status NOT IN ('Cancelled', 'Rescheduled', 'No-Show') OR Notes IS NOT NULL)`.
* `uq_apt_pat_time`: `UNIQUE (PatientID, AppointmentDate)`.
* `uq_apt_doc_time`: `UNIQUE (DoctorID, AppointmentDate)`.

---

## 2. Entity: `MedicalRecord`
Maintains longitudinal clinical encounter records, recorded diagnoses, management plans, and follow-up schedules.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `RecordID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_medical_record`; `chk_mr_id`: `REGEXP_LIKE(RecordID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient whom this record concerns (`fk_mr_patient`) |
| `DoctorID` | `VARCHAR2(10)` | NO | **FK** | `Doctor(DoctorID)` | — | Physician authoring the medical entry (`fk_mr_doctor`) |
| `Diagnosis` | `VARCHAR2(255)` | NO | None | — | — | `chk_mr_diag_len`: `LENGTH(TRIM(Diagnosis)) >= 5` |
| `Treatment` | `VARCHAR2(500)` | NO | None | — | — | `chk_mr_treat_len`: `LENGTH(TRIM(Treatment)) >= 5` |
| `Notes` | `VARCHAR2(1000)` | YES | None | — | — | `chk_mr_notes_len`: `Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5` |
| `RecordDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_mr_rec_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE` via `trg_mr_date_max` |
| `FollowUpDate` | `DATE` | YES | None | — | — | Scheduled return visit date (NULL if no follow-up required) |

**Table-Level Constraints for `MedicalRecord`:**
* `chk_mr_dates`: `CHECK (FollowUpDate IS NULL OR (FollowUpDate >= RecordDate AND FollowUpDate <= RecordDate + 365))`.
* `uq_mr_encounter`: `UNIQUE (PatientID, DoctorID, RecordDate)`.

---

## 3. Entity: `MedicalProcedure`
Logs clinical, interventional, surgical, and diagnostic procedures performed on patients in designated operating rooms or suites.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `ProcedureID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_medical_procedure`; `chk_proc_id`: `REGEXP_LIKE(ProcedureID, '^[A-Za-z0-9_-]+$')` |
| `PatientID` | `VARCHAR2(10)` | NO | **FK** | `Patient(PatientID)` | — | Patient undergoing the procedure (`fk_proc_patient`) |
| `DoctorID` | `VARCHAR2(10)` | NO | **FK** | `Doctor(DoctorID)` | — | Primary surgeon/proceduralist (`fk_proc_doctor`) |
| `ProcedureName` | `VARCHAR2(100)` | NO | None | — | — | `chk_proc_name_len`: `LENGTH(TRIM(ProcedureName)) >= 5` |
| `ProcedureDate` | `DATE` | NO | Candidate | — | `SYSDATE` | `chk_proc_date`: `>= DATE '2020-01-01'`; capped at `SYSDATE + 365` via `trg_proc_date_horizon` |
| `Duration` | `NUMBER(4)` | NO | None | — | — | `chk_proc_duration`: `Duration > 0 AND Duration <= 1440` (minutes) |
| `EndTime` | `DATE` | VIRTUAL | Derived | — | Auto-derived | Auto-derived virtual column: `ProcedureDate + (Duration / 1440)` |
| `OperatingRoom` | `VARCHAR2(30)` | NO | Candidate | — | — | `chk_proc_room`: IN (`'OR-1'`, `'OR-2'`, `'OR-3'`, `'Cath Lab'`, `'Endoscopy Suite'`, `'Minor Surgery 1'`) |
| `ProcedureCost` | `NUMBER(10,2)` | NO | None | — | — | `chk_proc_cost`: `ProcedureCost > 0 AND ProcedureCost <= 1000000.00` |
| `Outcome` | `VARCHAR2(30)` | NO | None | — | `'Pending'` | `chk_proc_outcome`: IN (`'Pending'`, `'In-Progress'`, `'Successful'`, `'Completed with Complications'`, `'Unsuccessful'`, `'Aborted'`) |

**Table-Level Constraints for `MedicalProcedure`:**
* `uq_proc_doc_time`: `UNIQUE (DoctorID, ProcedureDate)`.
* `uq_proc_room_time`: `UNIQUE (OperatingRoom, ProcedureDate)`.
* `uq_proc_pat_time`: `UNIQUE (PatientID, ProcedureDate)`.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* All fields contain indivisible atomic values; `/AppointmentTime` and `/EndTime` are virtual derived columns eliminating temporal redundancy.

### 2NF (Second Normal Form)
* All three tables use single-attribute `VARCHAR2(10)` primary keys (`AppointmentID`, `RecordID`, `ProcedureID`), so partial dependencies cannot exist.

### 3NF (Third Normal Form)
* All non-key attributes depend solely on their respective entity primary key with no transitive dependencies.
