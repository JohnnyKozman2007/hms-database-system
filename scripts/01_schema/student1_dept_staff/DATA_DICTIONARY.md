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
| `DepartmentID` | `NUMBER(4)` | NO | **PK** | — | — | Primary identifier (Range: `1..8+`) |
| `DepartmentName` | `VARCHAR2(50)` | NO | Candidate | — | — | Unique department title (`uq_dept_name`), e.g., 'Cardiology', 'Pediatrics' |
| `Building` | `VARCHAR2(50)` | NO | None | — | — | Hospital building name/identifier (e.g., 'Building A', 'Building B') |
| `FloorLevel` | `VARCHAR2(50)` | NO | None | — | — | Floor or level (e.g., 'Floor 1', 'Floor 2', 'Ground Floor') |
| `Location` | `VARCHAR2(100)` | VIRTUAL | Derived | — | Auto-derived | Derived virtual column: `Building || ', ' || FloorLevel` |
| `Phone` | `VARCHAR2(20)` | NO | None | — | — | Department contact phone / extension number |
| `DepartmentDescription` | `VARCHAR2(255)` | YES | None | — | — | Brief summary of medical scope and services offered |

---

## 2. Entity: `Doctor`
Stores licensed medical doctors, surgeons, and physicians employed by the hospital and assigned to a department.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `DoctorID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..20+`) |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | Doctor's first name |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | Doctor's surname |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_doc_gender`: IN (`'Male'`, `'Female'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Doctor's contact telephone number (`uq_doc_phone`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique professional email address (`uq_doc_email`) |
| `Specialty` | `VARCHAR2(50)` | NO | None | — | — | Area of medical specialization (e.g., 'Cardiologist', 'Neurologist') |
| `HireDate` | `DATE` | NO | None | — | — | Date of employment commencement |
| `YearsOfExperience`| `NUMBER(2)` | NO | None | — | `0` | `chk_doc_exp`: Must be `>= 0` |
| `DepartmentID` | `NUMBER(4)` | NO | **FK** | `Department(DepartmentID)` | — | Department the doctor is assigned to (`fk_doc_dept`) |

---

## 3. Entity: `Nurse`
Stores registered nurses assigned to hospital departments and shift schedules.

| Column Name | Data Type | Nullable | Key Type | References | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `NurseID` | `NUMBER(8)` | NO | **PK** | — | — | Primary identifier (Range: `1..30+`) |
| `FirstName` | `VARCHAR2(50)` | NO | None | — | — | Nurse's first name |
| `LastName` | `VARCHAR2(50)` | NO | None | — | — | Nurse's surname |
| `Gender` | `VARCHAR2(10)` | NO | None | — | — | `chk_nurse_gender`: IN (`'Male'`, `'Female'`) |
| `Phone` | `VARCHAR2(20)` | NO | Candidate | — | — | Contact telephone number (`uq_nurse_phone`) |
| `Email` | `VARCHAR2(100)` | NO | Candidate | — | — | Unique email address (`uq_nurse_email`) |
| `Shift` | `VARCHAR2(20)` | NO | None | — | — | `chk_nurse_shift`: IN (`'Morning'`, `'Afternoon'`, `'Night'`, `'Rotating'`) |
| `YearsOfExperience`| `NUMBER(2)` | NO | None | — | `0` | `chk_nurse_exp`: Must be `>= 0` |
| `DepartmentID` | `NUMBER(4)` | NO | **FK** | `Department(DepartmentID)` | — | Department the nurse is assigned to (`fk_nurse_dept`) |

---

## 4. Normalization Analysis (3NF Compliance)

### 1NF (First Normal Form)
* All attributes contain strictly atomic, indivisible values.
* Specifically, the composite attribute `Location` in `Department` has been decomposed into atomic components (`Building` and `FloorLevel`), with `Location` implemented as an auto-derived virtual column.
* No repeating groups or multivalued attributes exist across any of the entities.
* Each table has a defined primary key ensuring record uniqueness.

### 2NF (Second Normal Form)
* All three tables (`Department`, `Doctor`, `Nurse`) possess single-attribute primary keys (`DepartmentID`, `DoctorID`, `NurseID`).
* Because no composite primary keys exist, partial functional dependencies are impossible; all non-key attributes are fully functionally dependent on the entire primary key.

### 3NF (Third Normal Form)
* No transitive functional dependencies exist ($X \to Y$ and $Y \to Z$ where $X$ is the primary key).
* Non-key attributes such as `Specialty`, `YearsOfExperience`, `Shift`, `Building`, `FloorLevel`, and `DepartmentDescription` depend directly and solely on their respective entity primary keys.
* Relationships between entities are established exclusively through foreign keys (`DepartmentID` in `Doctor` and `Nurse`).
