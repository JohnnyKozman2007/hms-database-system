# Student 1: Relational Table Schema
**Module:** Data Modeling for DB (4FTC2063)  
**Notation:** <u>Primary Key</u> | Foreign Key* | /DerivedAttribute | <u>Composite / PK + FK*</u>

---

* **Department** (<u>DepartmentID</u>, DepartmentName, Building, FloorLevel, /Location, Phone, DepartmentDescription)

* **Doctor** (<u>DoctorID</u>, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID*)

* **Nurse** (<u>NurseID</u>, FirstName, LastName, Gender, Phone, Email, Shift, HireDate, YearsOfExperience, DepartmentID*)

---

### Key Notes & Constraints:
* `/Location` is a **derived virtual attribute** computed from (`Building`, `FloorLevel`).
* `Building` and `FloorLevel` are **NOT NULL** (enforcing atomic location components in 1NF).
* `Doctor.HireDate` and `Nurse.HireDate` default to `SYSDATE`.
* `DepartmentName` is **UNIQUE** and **NOT NULL**.
* `Doctor.Email` and `Nurse.Email` are unique candidate keys (**UNIQUE** and **NOT NULL**).
* `Doctor.Phone` and `Nurse.Phone` are unique candidate keys (**UNIQUE** and **NOT NULL**).
* `Doctor.Gender` and `Nurse.Gender` enforce a `CHECK` constraint (`IN ('Male', 'Female')`).
* `Doctor.YearsOfExperience` and `Nurse.YearsOfExperience` default to `0` and enforce a `CHECK` constraint (`>= 0`).
* `Nurse.Shift` enforces a `CHECK` constraint (`IN ('Morning', 'Afternoon', 'Night', 'Rotating')`).

### Foreign Key References:
* `Doctor(DepartmentID*)` references `Department(DepartmentID)`
* `Nurse(DepartmentID*)` references `Department(DepartmentID)`

### External Dependent Entities (Referencing Student 1):
* `Appointment(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalRecord(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `MedicalProcedure(DoctorID*)` *(Student 3)* references `Doctor(DoctorID)`
* `Prescription(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
* `LaboratoryTest(DoctorID*)` *(Student 4)* references `Doctor(DoctorID)`
