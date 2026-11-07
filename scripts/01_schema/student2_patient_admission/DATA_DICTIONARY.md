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
| `PatientID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..100+`) |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | Patient's given first name |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | Patient's family surname |
| `FullName` | `VARCHAR2(101)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `FirstName || ' ' || LastName` |
| `DateOfBirth` | `DATE` | NO | None | — | — | Patient's birthdate (`chk_pat_dob`: `>= DATE '1900-01-01'`) |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_pat_gender`: IN (`'Male'`, `'Female'`) |
| `BloodType` | `VARCHAR2(5)` | NO | None | — | — | `chk_pat_blood`: IN (`'A+'`, `'A-'`, `'B+'`, `'B-'`, `'AB+'`, `'AB-'`, `'O+'`, `'O-'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Unique primary telephone number (`uq_pat_phone`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email (`uq_pat_email`), format check `chk_pat_email_fmt`: `LIKE '%_@__%.__%'` |
| `StreetAddress` | `VARCHAR2(100)` | NO | None | — | — | Atomic residential street name and building/house number |
| `City` | `VARCHAR2(50)` | NO | None | — | — | City of residence |
| `PostalCode` | `VARCHAR2(20)` | NO | None | — | — | Postal/ZIP code |
| `Address` | `VARCHAR2(200)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `StreetAddress || ', ' || City || ' ' || PostalCode` |
| `EmergencyContact` | `VARCHAR2(100)` | NO | None | — | — | Emergency contact person and/or phone (`chk_pat_emg`: `<> Phone`) |

---

## 2. Entity: `Room`
Stores physical accommodation units across hospital wards, care units, and floors, including capacity, daily billing tariffs, and live availability.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `RoomID` | `NUMBER(4)` | NO | **PK** | — | — | Primary identifier (Range: `1..50+`) |
| `RoomNumber` | `VARCHAR2(10)` | NO | Candidate | — | — | Unique room identifier (`uq_room_number`), e.g., `'101'`, `'ICU-01'` |
| `Floor` | `NUMBER(2)` | NO | None | — | — | Floor number (`chk_room_floor`: `BETWEEN -1 AND 20`) |
| `RoomType` | `VARCHAR2(30)` | NO | None | — | — | `chk_room_type`: IN (`'General Ward'`, `'Semi-Private'`, `'Private'`, `'ICU'`, `'Isolation'`, `'Emergency'`, `'Maternity'`, `'Pediatric'`, `'Operating Room'`) |
| `Capacity` | `NUMBER(3)` | NO | None | — | `1` | Total bed capacity (`chk_room_capacity`: `Capacity > 0 AND Capacity <= 20`) |
| `DailyCharge` | `NUMBER(10,2)` | NO | None | — | — | Daily room stay rate in currency units (`chk_room_charge`: `>= 0`) |
| `AvailabilityStatus` | `VARCHAR2(20)` | NO | None | — | `'Available'` | `chk_room_status`: IN (`'Available'`, `'Occupied'`, `'Maintenance'`, `'Reserved'`) |

---

## 3. Entity: `Admission`
Tracks inpatient hospital admissions, linking a patient to a designated room, with timestamps for admission and discharge, clinical reason, and status.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `AdmissionID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..150+`) |
| `PatientID` | `NUMBER(8)` | NO | **FK** | `Patient(PatientID)` | — | Patient being admitted (`fk_adm_patient`) |
| `RoomID` | `NUMBER(4)` | NO | **FK** | `Room(RoomID)` | — | Room assigned for the stay (`fk_adm_room`) |
| `AdmissionDate` | `DATE` | NO | None | — | `SYSDATE` | Date and time of admission |
| `DischargeDate` | `DATE` | YES | None | — | — | Date and time of discharge (NULL while currently admitted) |
| `AdmissionReason` | `VARCHAR2(255)` | NO | None | — | — | Clinical diagnosis or reason for hospital admission |
| `AdmissionStatus` | `VARCHAR2(20)` | NO | None | — | `'Admitted'` | `chk_adm_status`: IN (`'Admitted'`, `'Discharged'`, `'Transferred'`) |

**Table-Level Constraints for `Admission`:**
* `chk_adm_dates`: `CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)` ensures discharge timestamp cannot precede admission timestamp.

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* **Atomic Attributes:** All stored values are indivisible and atomic. The composite attribute `Address` has been decomposed into `StreetAddress`, `City`, and `PostalCode`, with `Address` exposed as a virtual derived column.
* **Derived Name:** `FullName` is implemented as an auto-derived virtual column concatenating `FirstName` and `LastName`, avoiding data duplication.
* **No Repeating Groups:** Multiple phone numbers or multiple admissions are not stored as comma-delimited strings or array fields; each admission is an independent tuple in `Admission`.
* **Unique Identification:** Every table features a single-attribute primary key (`PatientID`, `RoomID`, `AdmissionID`).

### 2NF (Second Normal Form)
* **Complete Functional Dependency:** A table is in 2NF if it is in 1NF and contains no partial functional dependencies.
* All three entities (`Patient`, `Room`, `Admission`) possess single-column primary keys.
* Because no composite primary key exists, partial dependencies on part of a candidate key are impossible. Every non-key attribute is fully functionally dependent on the entire primary key.

### 3NF (Third Normal Form)
* **No Transitive Dependencies:** A relation is in 3NF if it is in 2NF and no non-key attribute is transitively dependent on the primary key ($X \to Y$ and $Y \to Z$).
* In `Patient`: Demographics, contact information, and address components depend strictly on `PatientID`.
* In `Room`: Room features (`RoomNumber`, `Floor`, `RoomType`, `Capacity`, `DailyCharge`, `AvailabilityStatus`) describe the physical room and depend solely on `RoomID`.
* In `Admission`: The stay details (`AdmissionDate`, `DischargeDate`, `AdmissionReason`, `AdmissionStatus`) depend directly on `AdmissionID`. Foreign keys `PatientID` and `RoomID` establish standard 1:M relationships without creating transitive dependencies.
