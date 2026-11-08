# Student 3: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Appointment** (<u>AppointmentID</u>, PatientID*, DoctorID*, AppointmentDate, /AppointmentTime, Status, Reason, Notes)

* **MedicalRecord** (<u>RecordID</u>, PatientID*, DoctorID*, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)

* **MedicalProcedure** (<u>ProcedureID</u>, PatientID*, DoctorID*, ProcedureName, ProcedureDate, OperatingRoom, Duration, ProcedureCost, Outcome)

---

### Key Notes & Constraints:
* `/AppointmentTime` is a **derived virtual attribute** auto-extracted from `AppointmentDate` via `TO_CHAR(AppointmentDate, 'HH24:MI')`, keeping date and time synchronized without duplicate input.
* `Appointment.AppointmentDate` stores the scheduled consultation timestamp, defaults to `SYSDATE`, is **NOT NULL**, and enforces a historical boundary check (`AppointmentDate >= DATE '2020-01-01'`).
* `Appointment.Status` defaults to `'Scheduled'`, is **NOT NULL**, and enforces allowable lifecycle stages (`chk_apt_status`: `IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')`).
* `Appointment.Reason` is **NOT NULL** (mandating a declared clinical or consultation purpose).
* `Appointment.Notes` is **NULLABLE** (reserved for triage or physician remarks).
* `MedicalRecord.Diagnosis` and `MedicalRecord.Treatment` are **NOT NULL** (enforcing complete clinical documentation for medical encounters).
* `MedicalRecord.RecordDate` defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`RecordDate >= DATE '2020-01-01'`).
* `MedicalRecord.FollowUpDate` is **NULLABLE** (accommodating discharged patients who do not require a follow-up consultation).
* `MedicalRecord` enforces a chronological check constraint `chk_mr_dates`: `CHECK (FollowUpDate IS NULL OR FollowUpDate >= RecordDate)`.
* `MedicalProcedure.ProcedureName` is **NOT NULL** (e.g., `'Appendectomy'`, `'Coronary Angiography'`, `'Endoscopy'`).
* `MedicalProcedure.ProcedureDate` defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`ProcedureDate >= DATE '2020-01-01'`).
* `MedicalProcedure.OperatingRoom` is **NOT NULL** (e.g., `'OR-1'`, `'OR-2'`, `'Cath Lab'`, `'Endoscopy Suite'`).
* `MedicalProcedure.Duration` is in minutes, **NOT NULL**, and enforces realistic duration limits (`chk_proc_duration`: `Duration > 0 AND Duration <= 1440`).
* `MedicalProcedure.ProcedureCost` is **NOT NULL** and enforces a valid positive billing range (`chk_proc_cost`: `ProcedureCost >= 0 AND ProcedureCost <= 1000000.00`).
* `MedicalProcedure.Outcome` defaults to `'Successful'`, is **NOT NULL**, and enforces valid procedural outcomes (`chk_proc_outcome`: `IN ('Successful', 'Completed with Complications', 'Unsuccessful', 'Pending', 'In-Progress', 'Aborted')`).

### Foreign Key References:
* `Appointment(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `Appointment(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*
* `MedicalRecord(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `MedicalRecord(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*
* `MedicalProcedure(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `MedicalProcedure(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*

### External Dependent Entities (Referencing Student 3):
* None (Terminal clinical encounter, procedure, and appointment entities).
