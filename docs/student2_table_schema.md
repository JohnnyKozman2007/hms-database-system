# Student 2: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Patient** (<u>PatientID</u>, FirstName, LastName, /FullName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, /Address, EmergencyContact)

* **Room** (<u>RoomID</u>, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)

* **Admission** (<u>AdmissionID</u>, PatientID*, RoomID*, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)

---

### Key Notes & Constraints:
* `/FullName` is a **derived virtual attribute** computed from (`FirstName`, `LastName`).
* `/Address` is a **derived virtual attribute** computed from (`BuildingNumber`, `Street`, `City`, `PostalCode`), identical to the `Supplier` address architecture.
* `Street`, `City`, and `PostalCode` are **NOT NULL** (enforcing atomic address components in 1NF). `BuildingNumber` is nullable for premises or rural areas without formal numbers.
* `Patient.DateOfBirth` enforces a boundary check (`DateOfBirth >= DATE '1900-01-01'`) and is **NOT NULL**.
* `Patient.Gender` enforces a `CHECK` constraint (`IN ('Male', 'Female')`).
* `Patient.BloodType` enforces a `CHECK` constraint (`IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')`).
* `Patient.Phone` and `Patient.Email` are unique candidate keys (**UNIQUE**, **NOT NULL**, with format check `Email LIKE '%_@__%.__%'`).
* `Patient.PhoneType` defaults to `'Mobile'` and enforces `CHECK (PhoneType IN ('Mobile', 'Landline', 'Phone'))`.
* `Patient.Phone` enforces Egyptian National Telecom Authority rules: pure digits only (`^[0-9]+$`). Mobile numbers are exactly 11 digits starting with `01` (`010`, `011`, `012`, `015`); Landline numbers are 9 digits (Alexandria `03`) or 10 digits (Cairo `02` and provincial governorates) starting with `0`.
* `Patient.EmergencyContact` is **NOT NULL**, enforces `CHECK (EmergencyContact <> Phone)`, and enforces Egyptian phone validation with digits only (no spaces, commas, or dashes).
* `Room.RoomNumber` is a unique candidate key (**UNIQUE** and **NOT NULL**).
* `Room.Floor` enforces a `CHECK` constraint (`BETWEEN -1 AND 20`).
* `Room.RoomType` enforces a `CHECK` constraint (`IN ('General Ward', 'Semi-Private', 'Private', 'ICU', 'Isolation', 'Emergency', 'Maternity', 'Pediatric', 'Operating Room')`).
* `Room.Capacity` defaults to `1` and enforces `CHECK (Capacity > 0 AND Capacity <= 20)`.
* `Room` enforces clinical capacity correlation `chk_room_type_cap`: Private, ICU, and Isolation rooms must have `Capacity = 1`; Semi-Private rooms must have `Capacity = 2`.
* `Room.DailyCharge` is **NOT NULL** and enforces a realistic positive billing range `CHECK (DailyCharge > 0 AND DailyCharge <= 10000.00)`.
* `Room.AvailabilityStatus` defaults to `'Available'` and enforces `CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance', 'Reserved'))`.
* `Admission.AdmissionDate` defaults to `SYSDATE` and is **NOT NULL**.
* `Admission.DischargeDate` is **NULLABLE** to reflect current inpatients who have not yet been discharged.
* `Admission` enforces a table-level date validation `CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)`.
* `Admission` enforces status and discharge date synchronization `chk_adm_status_sync`: currently admitted patients must have `DischargeDate IS NULL`, while discharged or transferred patients must have `DischargeDate IS NOT NULL`.
* `Admission.AdmissionStatus` defaults to `'Admitted'` and enforces `CHECK (AdmissionStatus IN ('Admitted', 'Discharged', 'Transferred'))`.

### Foreign Key References:
* `Admission(PatientID*)` references `Patient(PatientID)`
* `Admission(RoomID*)` references `Room(RoomID)`

### External Dependent Entities (Referencing Student 2):
* `Appointment(PatientID*)` *(Student 3)* references `Patient(PatientID)`
* `MedicalRecord(PatientID*)` *(Student 3)* references `Patient(PatientID)`
* `MedicalProcedure(PatientID*)` *(Student 3)* references `Patient(PatientID)`
* `Prescription(PatientID*)` *(Student 4)* references `Patient(PatientID)`
* `LaboratoryTest(PatientID*)` *(Student 4)* references `Patient(PatientID)`
* `Insurance(PatientID*)` *(Student 5)* references `Patient(PatientID)`
* `Invoice(PatientID*)` *(Student 5)* references `Patient(PatientID)`
