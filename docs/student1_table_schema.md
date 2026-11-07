# Student 1: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Department** (<u>DepartmentID</u>, DepartmentName, Building, FloorLevel, /Location, Phone, DepartmentDescription)

* **Doctor** (<u>DoctorID</u>, FirstName, LastName, /FullName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

* **Nurse** (<u>NurseID</u>, FirstName, LastName, /FullName, Gender, Phone, Email, Shift, HireDate, YearsOfExperience, DepartmentID*, SupervisorID*)

* **Salary** [Extra Work] (<u>SalaryID</u>, StaffType, DoctorID*, NurseID*, BaseSalary, Allowance, Deductions, /NetSalary, PaymentFrequency, EffectiveDate, SalaryStatus)

---

### Key Notes & Constraints:
* `/Location` is a **derived virtual attribute** computed from (`Building`, `FloorLevel`).
* `Building` and `FloorLevel` are **NOT NULL** (enforcing atomic location components in 1NF).
* `/FullName` is a **derived virtual attribute** in both `Doctor` and `Nurse` computed from (`FirstName`, `LastName`).
* `/NetSalary` is a **derived virtual attribute** in `Salary` computed from (`BaseSalary + Allowance - Deductions`).
* `DepartmentName` is **UNIQUE** and **NOT NULL**.
* `Department.Phone` is **UNIQUE** (`uq_dept_phone`) and **NOT NULL** (dedicated department direct line/extension).
* `Doctor.Email` and `Nurse.Email` are unique candidate keys (**UNIQUE**, **NOT NULL**, with format check `Email LIKE '%_@__%.__%'`).
* `Doctor.Phone` and `Nurse.Phone` are unique candidate keys (**UNIQUE** and **NOT NULL**).
* `Doctor.Gender` and `Nurse.Gender` enforce a `CHECK` constraint (`IN ('Male', 'Female')`).
* `Doctor.YearsOfExperience` and `Nurse.YearsOfExperience` default to `0` and enforce a boundary `CHECK` constraint (`BETWEEN 0 AND 60`).
* `Doctor.HireDate` and `Nurse.HireDate` default to `SYSDATE` and are **NOT NULL**.
* `Nurse.Shift` defaults to `'Morning'` and enforces a `CHECK` constraint (`IN ('Morning', 'Afternoon', 'Night', 'Rotating')`).
* `Doctor.SupervisorID` and `Nurse.SupervisorID` are **NULLABLE** to permit top-level leaders (Chief Medical Officer, Head Nurse) who have no supervisor.
* `Salary` enforces an **exclusive arc check constraint** (`chk_sal_staff`): a salary record must reference either a `DoctorID` OR a `NurseID`, but never both and never neither.
* `BaseSalary + Allowance >= Deductions` ensures net pay cannot be negative.

### Foreign Key References:
* `Doctor(DepartmentID*)` references `Department(DepartmentID)`
* `Doctor(SupervisorID*)` references `Doctor(DoctorID)` *(Unary/Recursive 1:M relationship)*
* `Nurse(DepartmentID*)` references `Department(DepartmentID)`
* `Nurse(SupervisorID*)` references `Nurse(NurseID)` *(Unary/Recursive 1:M relationship)*
* `Salary(DoctorID*)` references `Doctor(DoctorID)` *(Exclusive Arc FK)*
* `Salary(NurseID*)` references `Nurse(NurseID)` *(Exclusive Arc FK)*

### External Dependent Entities (Referencing Student 1):
* `Appointment(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalRecord(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalProcedure(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `Prescription(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
* `LaboratoryTest(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
