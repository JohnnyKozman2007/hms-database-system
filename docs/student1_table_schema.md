# Student 1: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Department** (<u>DepartmentID</u>, DepartmentName, Building, FloorLevel, /Location, Phone, PhoneType, DepartmentDescription)

* **Doctor** (<u>DoctorID</u>, FirstName, LastName, /FullName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

* **Nurse** (<u>NurseID</u>, FirstName, LastName, /FullName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

---

### Key Notes & Constraints:
* `DepartmentID` is **VARCHAR2(10)** alphanumeric primary key allowing leading zeros and standard institutional codes (e.g., `'D01'`, `'DEPT01'`).
* `Building` enforces building code names via `CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'))`.
* `FloorLevel` enforces standardized ordinal stories via `CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'))`.
* `/Location` is a **derived virtual attribute** computed from (`Building`, `FloorLevel`).
* `Building` and `FloorLevel` are **NOT NULL** (enforcing atomic location components in 1NF).
* Baseline table constraints are declared inside `CREATE TABLE`, while refinement constraints (`chk_*_id`, `chk_dept_bldg`, `chk_dept_floor`, name/date/self-supervisor guards) are added via `ALTER TABLE ... ADD CONSTRAINT`.
* `/FullName` is a **derived virtual attribute** in both `Doctor` and `Nurse` computed from (`FirstName`, `LastName`).
* `DepartmentName` is **UNIQUE** and **NOT NULL**.
* `Department.Phone` is **UNIQUE** (`uq_dept_phone`) and **NOT NULL** (dedicated department direct line/extension).
* `PhoneType` in `Department`, `Doctor`, and `Nurse` enforces `CHECK (PhoneType IN ('Landline', 'Mobile'))`.
* `Phone` in `Department`, `Doctor`, and `Nurse` enforces Egyptian National Telecom Authority rules: pure digits only (`^[0-9]+$`). Mobile numbers are exactly 11 digits starting with `01`; Landlines are 9 digits (Alexandria `03`) or 10 digits (Cairo `02` and provincial governorates) starting with `0`.
* `DoctorID` and `NurseID` are **VARCHAR2(10)** alphanumeric primary keys matching institutional badge codes (e.g., `'DOC01'`, `'001'`).
* `Doctor.FirstName` and `Doctor.LastName` enforce alphabetic formatting (`^[A-Za-z'' -]+$`).
* `Specialty` is open `VARCHAR2(50) NOT NULL` to avoid overly restrictive domain clipping.
* `Doctor.Email` and `Nurse.Email` are unique candidate keys (**UNIQUE**, **NOT NULL**, with format check `Email LIKE '%_@__%.__%'`).
* `Doctor.Phone` and `Nurse.Phone` are unique candidate keys (**UNIQUE** and **NOT NULL**).
* `Doctor.Gender` and `Nurse.Gender` enforce a `CHECK` constraint (`IN ('Male', 'Female')`).
* `Doctor.YearsOfExperience` and `Nurse.YearsOfExperience` default to `0` and enforce a boundary `CHECK` constraint (`BETWEEN 0 AND 60`).
* `Doctor.HireDate` and `Nurse.HireDate` default to `SYSDATE` and are **NOT NULL**.
* `Nurse.Shift` defaults to `'Morning'` and enforces a `CHECK` constraint (`IN ('Morning', 'Afternoon', 'Night', 'Rotating')`).
* `Doctor.SupervisorID` and `Nurse.SupervisorID` are **NULLABLE** to permit top-level leaders (Chief Medical Officer, Head Nurse) who have no supervisor.

### Foreign Key References:
* `Doctor(DepartmentID*)` references `Department(DepartmentID)`
* `Doctor(SupervisorID*)` references `Doctor(DoctorID)` *(Unary/Recursive 1:M relationship: Senior Doctor supervises Doctors)*
* `Nurse(DepartmentID*)` references `Department(DepartmentID)`
* `Nurse(SupervisorID*)` references `Nurse(NurseID)` *(Unary/Recursive 1:M relationship: Head/Charge Nurse supervises Nurses)*

### External Dependent Entities (Referencing Student 1):
* `Appointment(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalRecord(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalProcedure(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `Prescription(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
* `LaboratoryTest(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
