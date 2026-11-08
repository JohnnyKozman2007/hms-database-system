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
| `AppointmentID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..300+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient booked for the appointment (`fk_apt_patient`) |
| `DoctorID` | `NUMBER(8)` | NO | **FK** | `Doctor(DoctorID)` | — | Doctor conducting the consultation (`fk_apt_doctor`) |
| `AppointmentDate` | `DATE` | NO | None | — | `SYSDATE` | Scheduled calendar date and timestamp (`chk_apt_date`: `>= DATE '2020-01-01'`) |
| `AppointmentTime` | `VARCHAR2(5)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `TO_CHAR(AppointmentDate, 'HH24:MI')` |
| `Status` | `VARCHAR2(20)` | NO | None | — | `'Scheduled'` | `chk_apt_status`: IN (`'Scheduled'`, `'Completed'`, `'Cancelled'`, `'No-Show'`, `'In-Progress'`, `'Rescheduled'`) |
| `Reason` | `VARCHAR2(255)` | NO | None | — | — | Chief complaint or purpose of consultation |
| `Notes` | `VARCHAR2(500)` | YES | None | — | — | Triage, clinical, or front-desk notes (mandatory if cancelled/rescheduled) |

**Table-Level Constraints for `Appointment`:**
* `chk_apt_status`: Enforces permissible appointment lifecycle stages.
* Date boundary `chk_apt_date`: Ensures appointment timestamps are realistic (`>= DATE '2020-01-01'`).
* `chk_apt_cancel_note`: `CHECK (Status NOT IN ('Cancelled', 'Rescheduled') OR Notes IS NOT NULL)` guarantees that whenever an appointment is cancelled or rescheduled, an explanatory note is recorded.

---

## 2. Entity: `MedicalRecord`
Maintains longitudinal clinical encounter records, recorded diagnoses, management plans, and follow-up schedules.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `RecordID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..250+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient whom this record concerns (`fk_mr_patient`) |
| `DoctorID` | `NUMBER(8)` | NO | **FK** | `Doctor(DoctorID)` | — | Physician authoring the medical entry (`fk_mr_doctor`) |
| `Diagnosis` | `VARCHAR2(255)` | NO | None | — | — | Clinically identified diagnosis / pathology |
| `Treatment` | `VARCHAR2(500)` | NO | None | — | `'Routine Monitoring / Conservative Management'` | Prescribed therapy or clinical management plan |
| `Notes` | `VARCHAR2(1000)` | YES | None | — | — | Detailed physician observations, symptoms, and medical history |
| `RecordDate` | `DATE` | NO | None | — | `SYSDATE` | Date encounter was documented (`chk_mr_rec_date`: `>= DATE '2020-01-01'`) |
| `FollowUpDate` | `DATE` | YES | None | — | — | Scheduled return visit date (NULL if routine discharge/no follow-up) |

**Table-Level Constraints for `MedicalRecord`:**
* `chk_mr_dates`: `CHECK (FollowUpDate IS NULL OR (FollowUpDate >= RecordDate AND FollowUpDate <= RecordDate + 365))` ensures follow-up appointments cannot precede the initial record creation date and are capped within a realistic 1-year window.

---

## 3. Entity: `MedicalProcedure`
Logs clinical, interventional, surgical, and diagnostic procedures performed on patients in designated operating rooms or suites.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `ProcedureID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Agreed Range: `1..100+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient undergoing the procedure (`fk_proc_patient`) |
| `DoctorID` | `NUMBER(8)` | NO | **FK** | `Doctor(DoctorID)` | — | Primary surgeon/proceduralist (`fk_proc_doctor`) |
| `ProcedureName` | `VARCHAR2(100)` | NO | None | — | — | Clinical name of procedure performed |
| `ProcedureDate` | `DATE` | NO | None | — | `SYSDATE` | Date procedure was executed (`chk_proc_date`: `>= DATE '2020-01-01'`) |
| `OperatingRoom` | `VARCHAR2(30)` | NO | None | — | — | Standardized theater designation (`chk_proc_room`: IN (`'OR-1'`, `'OR-2'`, `'OR-3'`, `'Cath Lab'`, `'Endoscopy Suite'`, `'Minor Surgery 1'`)) |
| `Duration` | `NUMBER(4)` | NO | None | — | — | Procedure length in minutes (`chk_proc_duration`: `Duration > 0 AND Duration <= 1440`) |
| `ProcedureCost` | `NUMBER(10,2)` | NO | None | — | — | Procedure gross fee (`chk_proc_cost`: `ProcedureCost > 0 AND ProcedureCost <= 1000000.00`) |
| `Outcome` | `VARCHAR2(30)` | NO | None | — | `'Successful'` | `chk_proc_outcome`: IN (`'Successful'`, `'Completed with Complications'`, `'Unsuccessful'`, `'Pending'`, `'In-Progress'`, `'Aborted'`) |

**Table-Level Constraints for `MedicalProcedure`:**
* `chk_proc_room`: Standardizes operating suites and surgical rooms across hospital departments.
* `chk_proc_duration`: Ensures procedure duration is strictly positive and capped within a realistic 24-hour limit (1,440 minutes).
* `chk_proc_cost`: Enforces strictly positive procedure charges (`> 0.00`).
* `chk_proc_outcome`: Restricts procedural outcomes to standardized hospital clinical statuses.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* **Atomic Attributes:** All fields contain indivisible single values (e.g., distinct numerical duration in minutes, and atomic procedure names).
* **Derived Virtual Column:** `/AppointmentTime` is implemented as an auto-derived virtual column using `TO_CHAR(AppointmentDate, 'HH24:MI')`, eliminating temporal redundancy between date and time storage.
* **No Repeating Groups:** Encounters, procedures, and diagnoses are stored as individual relational tuples rather than delimited arrays.
* **Unique Identification:** Each table has a designated single-column primary key (`AppointmentID`, `RecordID`, `ProcedureID`).

### 2NF (Second Normal Form)
* **Full Functional Dependency:** A relation is in 2NF if it satisfies 1NF and contains no partial dependencies on any candidate key.
* Because `Appointment`, `MedicalRecord`, and `MedicalProcedure` all use single-attribute primary keys (`NUMBER(8)` surrogate PKs), no candidate key is composite.
* Consequently, partial dependencies cannot exist; all non-key attributes are fully functionally dependent on the entire primary key.

### 3NF (Third Normal Form)
* **No Transitive Dependencies:** A relation is in 3NF if it satisfies 2NF and has no transitive dependencies ($X \to Y$ and $Y \to Z$ where $Y$ is not a superkey).
* In `Appointment`: `AppointmentDate`, `AppointmentTime`, `Status`, `Reason`, and `Notes` describe the specific appointment instance and depend solely on `AppointmentID`. Foreign keys `PatientID` and `DoctorID` establish direct foreign associations without introducing transitive relationships.
* In `MedicalRecord`: `Diagnosis`, `Treatment`, `Notes`, `RecordDate`, and `FollowUpDate` describe the specific clinical encounter and depend strictly on `RecordID`.
* In `MedicalProcedure`: `ProcedureName`, `ProcedureDate`, `OperatingRoom`, `Duration`, `ProcedureCost`, and `Outcome` depend solely on `ProcedureID`. No non-key attribute determines another non-key attribute.
