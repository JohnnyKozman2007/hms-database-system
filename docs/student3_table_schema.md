# Student 3: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Appointment** (<u>AppointmentID</u>, PatientID*, DoctorID*, AppointmentDate, /AppointmentTime, Status, Reason, Notes)

* **MedicalRecord** (<u>RecordID</u>, PatientID*, DoctorID*, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)

* **MedicalProcedure** (<u>ProcedureID</u>, PatientID*, DoctorID*, ProcedureName, ProcedureDate, Duration, /EndTime, OperatingRoom, ProcedureCost, Outcome)

---

### Key Notes & Constraints:
* `/AppointmentTime` is a **derived virtual attribute** auto-extracted from `AppointmentDate` via `TO_CHAR(AppointmentDate, 'HH24:MI')`, keeping date and time synchronized without duplicate input.
* `Appointment.AppointmentDate` stores the scheduled consultation timestamp, defaults to `SYSDATE`, is **NOT NULL**, and enforces a historical boundary check (`AppointmentDate >= DATE '2020-01-01'`).
* `Appointment.Status` defaults to `'Scheduled'`, is **NOT NULL**, and enforces allowable lifecycle stages (`chk_apt_status`: `IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')`).
* `Appointment.Reason` is **NOT NULL** (mandating a declared clinical or consultation purpose).
* `Appointment.Notes` is conditionally mandatory (`chk_apt_cancel_note`: requires documented reason if `Status` is `'Cancelled'` or `'Rescheduled'`).
* `MedicalRecord.Diagnosis` is **NOT NULL**.
* `MedicalRecord.Treatment` defaults to `'Routine Monitoring / Conservative Management'` and is **NOT NULL** (ensuring complete clinical documentation without null gaps).
* `MedicalRecord.RecordDate` defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`RecordDate >= DATE '2020-01-01'`).
* `MedicalRecord.FollowUpDate` is **NULLABLE** (accommodating discharged patients who do not require a follow-up consultation).
* `MedicalRecord` enforces a chronological check constraint `chk_mr_dates`: `CHECK (FollowUpDate IS NULL OR (FollowUpDate >= RecordDate AND FollowUpDate <= RecordDate + 365))`, ensuring follow-up dates are on or after the encounter and capped within 1 year.
* `MedicalProcedure.ProcedureName` is **NOT NULL** (e.g., `'Appendectomy'`, `'Coronary Angiography'`, `'Endoscopy'`).
* `MedicalProcedure.ProcedureDate` defaults to `SYSDATE`, is **NOT NULL**, and enforces boundary check (`ProcedureDate >= DATE '2020-01-01'`).
* `MedicalProcedure.Duration` is in minutes, **NOT NULL**, and enforces realistic duration limits (`chk_proc_duration`: `Duration > 0 AND Duration <= 1440`).
* `/EndTime` is an **auto-derived virtual attribute** calculated as `ProcedureDate + (Duration / 1440)`, maintaining strict 3NF compliance without data redundancy.
* `MedicalProcedure.OperatingRoom` is **NOT NULL** and enforces standardized theater designations (`chk_proc_room`: `IN ('OR-1', 'OR-2', 'OR-3', 'Cath Lab', 'Endoscopy Suite', 'Minor Surgery 1')`).
* `MedicalProcedure.ProcedureCost` is **NOT NULL** and enforces a strictly positive billing range (`chk_proc_cost`: `ProcedureCost > 0 AND ProcedureCost <= 1000000.00`).
* `MedicalProcedure.Outcome` defaults to `'Successful'`, is **NOT NULL**, and enforces valid procedural outcomes (`chk_proc_outcome`: `IN ('Successful', 'Completed with Complications', 'Unsuccessful', 'Pending', 'In-Progress', 'Aborted')`).
* `MedicalProcedure` enforces candidate key uniqueness (`uq_proc_doc_time`: `UNIQUE (DoctorID, ProcedureDate)`) and room uniqueness (`uq_proc_room_time`: `UNIQUE (OperatingRoom, ProcedureDate)`), preventing duplicate start times.

### Foreign Key References:
* `Appointment(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `Appointment(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*
* `MedicalRecord(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `MedicalRecord(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*
* `MedicalProcedure(PatientID*)` references `Patient(PatientID)` *(Student 2)*
* `MedicalProcedure(DoctorID*)` references `Doctor(DoctorID)` *(Student 1)*

### External Dependent Entities (Referencing Student 3):
* None (Terminal clinical encounter, procedure, and appointment entities).
