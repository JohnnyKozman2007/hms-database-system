# Student 1: Data Dictionary & Mini-Schema Specification
**Subsystem:** Department and Staff Management  
**Entities Owned:** `Department`, `Doctor`, `Nurse`  
**Boundary Dependencies:** Referenced by `Appointment` (Student 3), `MedicalRecord` (Student 3), `MedicalProcedure` (Student 3), `Prescription` (Student 4), `LaboratoryTest` (Student 4)  
**Normalization Level:** Third Normal Form (3NF)

---

## 1. Entity: `Department`
Stores clinical, administrative, and operational divisions within the hospital.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `DepartmentID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_department`; `chk_dept_id`: `REGEXP_LIKE(DepartmentID, '^[A-Za-z0-9_-]+$')` |
| `DepartmentName` | `VARCHAR2(50)` | NO | Candidate | — | — | Unique department title (`uq_dept_name`), e.g., `'Cardiology'`, `'Pediatrics'` |
| `Building` | `VARCHAR2(50)` | NO | None | — | — | `chk_dept_bldg`: IN (`'Building A'`, `'Building B'`, `'Building C'`, `'Building D'`) |
| `FloorLevel` | `VARCHAR2(20)` | NO | None | — | — | `chk_dept_floor`: IN (`'Ground Floor'`, `'1st Floor'`, `'2nd Floor'`, `'3rd Floor'`, `'4th Floor'`, `'5th Floor'`) |
| `Location` | `VARCHAR2(80)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `Building \|\| ', ' \|\| FloorLevel` |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique department hotline/extension (`uq_dept_phone`) |
| `PhoneType` | `VARCHAR2(10)` | NO | None | — | `'Landline'` | `chk_dept_phone_type`: IN (`'Landline'`, `'Mobile'`) |
| `DepartmentDescription` | `VARCHAR2(255)` | YES | None | — | — | Brief summary of medical scope and services offered |

**Table-Level Constraints for `Department`:**
* `chk_dept_phone`: Pure digits (`^[0-9]+$`). Egyptian landlines must be 9–10 digits starting with `0`; mobile numbers must be 11 digits starting with `01`.

---

## 2. Entity: `Doctor`
Stores licensed medical doctors, surgeons, and physicians employed by the hospital and assigned to a department.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `DoctorID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_doctor`; `chk_doc_id`: `REGEXP_LIKE(DoctorID, '^[A-Za-z0-9_-]+$')` |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | `chk_doc_fname`: `REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$')` |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | `chk_doc_lname`: `REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$')` |
| `FullName` | `VARCHAR2(101)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `FirstName \|\| ' ' \|\| LastName` |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_doc_gender`: IN (`'Male'`, `'Female'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique personal contact number (`uq_doc_phone`) |
| `PhoneType` | `VARCHAR2(10)` | NO | None | — | `'Mobile'` | `chk_doc_phone_type`: IN (`'Mobile'`, `'Landline'`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email (`uq_doc_email`), format check `chk_doc_email_fmt`: `LIKE '%_@__%.__%'` |
| `Specialty` | `VARCHAR2(50)` | NO | None | — | — | Area of medical specialization (e.g., `'Cardiology'`, `'Neurology'`) |
| `HireDate` | `DATE` | NO | None | — | `SYSDATE` | `chk_doc_hire_date`: `>= DATE '1980-01-01'`; capped at `SYSDATE` via `trg_doc_date_max` |
| `YearsOfExperience` | `NUMBER(2)` | NO | None | — | `0` | `chk_doc_exp`: `BETWEEN 0 AND 60` |
| `DepartmentID` | `VARCHAR2(10)` | NO | **FK** | `Department(DepartmentID)` | — | Department the doctor is assigned to (`fk_doc_dept`) |
| `SupervisorID` | `VARCHAR2(10)` | YES | **FK** | `Doctor(DoctorID)` | — | Recursive reference to supervising doctor (`fk_doc_supervisor`); `chk_doc_no_self_sup`: `SupervisorID IS NULL OR SupervisorID <> DoctorID` |

**Table-Level Constraints for `Doctor`:**
* `chk_doc_phone`: Pure digits (`^[0-9]+$`). Egyptian mobile numbers must be 11 digits starting with `01`; landlines must be 9–10 digits starting with `0`.

---

## 3. Entity: `Nurse`
Stores registered nurses assigned to hospital departments and shift schedules.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `NurseID` | `VARCHAR2(10)` | NO | **PK** | — | — | `pk_nurse`; `chk_nurse_id`: `REGEXP_LIKE(NurseID, '^[A-Za-z0-9_-]+$')` |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | `chk_nurse_fname`: `REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$')` |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | `chk_nurse_lname`: `REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$')` |
| `FullName` | `VARCHAR2(101)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `FirstName \|\| ' ' \|\| LastName` |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_nurse_gender`: IN (`'Male'`, `'Female'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique personal contact telephone number (`uq_nurse_phone`) |
| `PhoneType` | `VARCHAR2(10)` | NO | None | — | `'Mobile'` | `chk_nurse_phone_type`: IN (`'Mobile'`, `'Landline'`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email (`uq_nurse_email`), format check `chk_nurse_email_fmt`: `LIKE '%_@__%.__%'` |
| `Shift` | `VARCHAR2(20)` | NO | None | — | `'Morning'` | `chk_nurse_shift`: IN (`'Morning'`, `'Afternoon'`, `'Night'`, `'Rotating'`) |
| `HireDate` | `DATE` | NO | None | — | `SYSDATE` | `chk_nurse_hire_date`: `>= DATE '1980-01-01'`; capped at `SYSDATE` via `trg_nurse_date_max` |
| `YearsOfExperience` | `NUMBER(2)` | NO | None | — | `0` | `chk_nurse_exp`: `BETWEEN 0 AND 60` |
| `DepartmentID` | `VARCHAR2(10)` | NO | **FK** | `Department(DepartmentID)` | — | Department the nurse is assigned to (`fk_nurse_dept`) |
| `SupervisorID` | `VARCHAR2(10)` | YES | **FK** | `Nurse(NurseID)` | — | Recursive reference to Head/Charge Nurse (`fk_nurse_supervisor`); `chk_nurse_no_self_sup`: `SupervisorID IS NULL OR SupervisorID <> NurseID` |

**Table-Level Constraints for `Nurse`:**
* `chk_nurse_phone`: Pure digits (`^[0-9]+$`). Egyptian mobile numbers must be 11 digits starting with `01`; landlines must be 9–10 digits starting with `0`.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* All attributes contain strictly atomic, indivisible values.
* `Location` in `Department` is decomposed into atomic `Building` and `FloorLevel`, with `Location` implemented as an auto-derived virtual column.
* `FullName` in `Doctor` and `Nurse` is an auto-derived virtual column computed from atomic `FirstName` and `LastName`.
* No repeating groups or multivalued attributes exist; each table has a single-attribute primary key.

### 2NF (Second Normal Form)
* All three tables (`Department`, `Doctor`, `Nurse`) use single-attribute `VARCHAR2(10)` primary keys (`DepartmentID`, `DoctorID`, `NurseID`), so partial functional dependencies cannot exist.

### 3NF (Third Normal Form)
* No transitive functional dependencies exist; all non-key attributes depend directly and solely on their entity primary key.
* Organizational relationships are modeled cleanly via `DepartmentID` (1:M) and recursive `SupervisorID` (1:M).
