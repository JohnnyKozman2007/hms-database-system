# Student 1: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Department** (<u>DepartmentID</u>, DepartmentName, Building, FloorLevel, /Location, Phone, PhoneType, DepartmentDescription)

* **Doctor** (<u>DoctorID</u>, FirstName, LastName, /FullName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

* **Nurse** (<u>NurseID</u>, FirstName, LastName, /FullName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

---

### Key Notes & Constraints:
* `/Location` is a **derived virtual attribute** computed from (`Building`, `FloorLevel`).
* `Building` and `FloorLevel` are **NOT NULL** (enforcing atomic location components in 1NF).
* `/FullName` is a **derived virtual attribute** in both `Doctor` and `Nurse` computed from (`FirstName`, `LastName`).
* `DepartmentName` is **UNIQUE** and **NOT NULL**.
* `Department.Phone` is **UNIQUE** (`uq_dept_phone`) and **NOT NULL** (dedicated department direct line/extension).
* `PhoneType` in `Department`, `Doctor`, and `Nurse` enforces `CHECK (PhoneType IN ('Landline', 'Mobile', 'Phone'))`.
* `Phone` in `Department`, `Doctor`, and `Nurse` enforces Egyptian National Telecom Authority rules: pure digits only (`^[0-9]+$`). Mobile numbers are exactly 11 digits starting with `01`; Landlines are 9 digits (Alexandria `03`) or 10 digits (Cairo `02` and provincial governorates) starting with `0`.
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
