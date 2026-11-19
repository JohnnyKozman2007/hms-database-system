# HMS Master Constraint Standards & Dictionary
**Module:** Data Modeling for DB (4FTC2063)  
**Academic Year:** 2026/27  
**Purpose:** Single Source of Truth for schema data types, constraint patterns, and architectural uniformity across all 16 tables.

---

## 1. Architectural Directives & Rules

### Directive 1: Pure Declarative Constraints (No Triggers / No Stored Procedures)
* **Rule:** For **Student 1, Student 2, Student 3, and Student 4**, all business rules and integrity constraints **must be enforced strictly through declarative SQL constraints**:
  * `PRIMARY KEY`
  * `FOREIGN KEY` (Referential integrity with `RESTRICT` / No Action, or `SET NULL` for recursive keys)
  * `UNIQUE` (Candidate keys & composite uniqueness)
  * `CHECK` (Domain lists, range limits, regex formats, cross-column logic)
  * `NOT NULL`
  * `DEFAULT`
  * `VIRTUAL COLUMNS` (`GENERATED ALWAYS AS (...) VIRTUAL` for 1NF/3NF computed attributes)
* **Prohibition:** **No triggers or stored procedures** shall be used for basic constraint enforcement in Students 1–4.

### Directive 2: Constraint Placement Policy (`CREATE TABLE` vs `ALTER TABLE`)
> [!IMPORTANT]
> **DO NOT convert all table constraints into `ALTER TABLE` statements.**
* **Inside `CREATE TABLE`:**
  * Baseline table architecture: Column definitions, data types, `NOT NULL`, `DEFAULT`, and virtual column expressions.
  * Baseline existing constraints: The core `PRIMARY KEY`, baseline `FOREIGN KEY`s, baseline `UNIQUE` constraints, and existing checks (such as `chk_doc_gender`, `chk_doc_exp`, `chk_doc_phone`, `chk_doc_email_fmt`).
  * **Fixes & Modifications to Existing Columns/Constraints:** If an existing column or constraint is corrected (e.g. converting an ID from `NUMBER` to `VARCHAR2(10)`, or changing `PhoneType` from 3 options to 2 options), **apply the fix directly inside `CREATE TABLE`**. Do NOT move it to `ALTER TABLE`.
* **Inside `ALTER TABLE ... ADD CONSTRAINT` (Underneath `CREATE TABLE`):**
  * Use `ALTER TABLE ... ADD CONSTRAINT` **strictly and only for brand new constraints** introduced during refinement sessions (e.g., adding `chk_dept_bldg`, `chk_dept_floor`, `chk_doc_fname`, `chk_doc_lname`, `chk_doc_hire_date`, `chk_doc_no_self_sup`).
  * This prevents SQL scripts from being bloated with redundant `ALTER` commands for things that belong in the core table definition.

### Directive 3: Comment Policy in SQL Scripts
* All schema SQL scripts (`.sql` files) must be clean, concise, and executable code **without verbose comment blocks or section banners**. All documentation and rationale belong here in the Markdown documentation (`.md`).

### Directive 4: Universal Identifier (PK / FK) Standard
* Every entity primary key and referencing foreign key is typed as **`VARCHAR2(10)`**.
* **Rationale:** IDs are surrogate codes/badges that undergo no mathematical arithmetic. `VARCHAR2(10)` permits leading zeros (e.g., `'001'`), standard alphanumeric prefixes (e.g., `'DOC01'`, `'DEPT01'`), and flexible scaling.
* Every primary key enforces an alphanumeric format check added via `ALTER TABLE`:
  ```sql
  ALTER TABLE <Table> ADD CONSTRAINT chk_<entity>_id CHECK (REGEXP_LIKE(<Entity>ID, '^[A-Za-z0-9_-]+$'));
  ```

---

## 2. Standardized Column Pattern Matrix

When any table includes one of the standard semantic columns below, it **must** reuse the exact data type, nullability, default, and constraint specified here.

| Semantic Concept | Standard Column Name(s) | Data Type | Default | Constraint Type | Standard Implementation Pattern |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Primary Key** | `<Entity>ID` | `VARCHAR2(10)` | — | PK (in CREATE) + Format CHK (in ALTER) | In CREATE: `CONSTRAINT pk_<entity> PRIMARY KEY`<br>In ALTER: `chk_<entity>_id CHECK (REGEXP_LIKE(<Entity>ID, '^[A-Za-z0-9_-]+$'))` |
| **Foreign Key** | `<TargetEntity>ID` | `VARCHAR2(10)` | — | FK (in CREATE) | `CONSTRAINT fk_<source>_<target> FOREIGN KEY (<TargetID>) REFERENCES <Target>(<TargetID>)` |
| **Recursive FK** | `SupervisorID` | `VARCHAR2(10)` | `NULL` | FK (in CREATE) + Self-Guard CHK (in ALTER) | In CREATE: `CONSTRAINT fk_<entity>_supervisor FOREIGN KEY (SupervisorID) REFERENCES <Entity>(<EntityID>)`<br>In ALTER: `chk_<entity>_no_self_sup CHECK (SupervisorID IS NULL OR SupervisorID <> <Entity>ID)` |
| **Person First Name** | `FirstName` | `VARCHAR2(50)` | — | NOT NULL (in CREATE) + Format CHK (in ALTER) | In ALTER: `chk_<entity>_fname CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'))` |
| **Person Last Name** | `LastName` | `VARCHAR2(50)` | — | NOT NULL (in CREATE) + Format CHK (in ALTER) | In ALTER: `chk_<entity>_lname CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'))` |
| **Derived Full Name** | `/FullName` | `VARCHAR2(101)` | — | VIRTUAL (in CREATE) | `GENERATED ALWAYS AS (FirstName \|\| ' ' \|\| LastName) VIRTUAL` |
| **Gender** | `Gender` | `VARCHAR2(10)` | — | NOT NULL + Domain CHK (in CREATE) | `CONSTRAINT chk_<entity>_gender CHECK (Gender IN ('Male', 'Female'))` |
| **Email Address** | `Email` | `VARCHAR2(100)` | — | NOT NULL + UQ + CHK (in CREATE) | `CONSTRAINT uq_<entity>_email UNIQUE`<br>`CONSTRAINT chk_<entity>_email_fmt CHECK (Email LIKE '%_@__%.__%')` |
| **Phone Type** | `PhoneType` | `VARCHAR2(10)` | `'Mobile'` (Persons)<br>`'Landline'` (Depts/Orgs) | NOT NULL + Domain CHK (in CREATE) | `CONSTRAINT chk_<entity>_phone_type CHECK (PhoneType IN ('Mobile', 'Landline'))`<br>*(Note: Redundant `'Phone'` option is strictly abolished)* |
| **Phone Number** | `Phone` | `VARCHAR2(20)` | — | NOT NULL + UQ + Telecom CHK (in CREATE) | `CONSTRAINT uq_<entity>_phone UNIQUE`<br>`CONSTRAINT chk_<entity>_phone CHECK (`<br>`  REGEXP_LIKE(Phone, '^[0-9]+$') AND (`<br>`    (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR`<br>`    (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')))` |
| **Experience** | `YearsOfExperience` | `NUMBER(2)` | `0` | NOT NULL + Range CHK (in CREATE) | `CONSTRAINT chk_<entity>_exp CHECK (YearsOfExperience BETWEEN 0 AND 60)` |
| **Hire Date** | `HireDate` | `DATE` | `SYSDATE` | NOT NULL (in CREATE) + Bound CHK (in ALTER) | In ALTER: `chk_<entity>_hire_date CHECK (HireDate >= DATE '1980-01-01')`<br>*(Oracle prohibits `SYSDATE` in CHECK constraints)* |
| **Nurse Shift** | `Shift` | `VARCHAR2(20)` | `'Morning'` | NOT NULL + Domain CHK (in CREATE) | `CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Morning', 'Afternoon', 'Night', 'Rotating'))` |
| **Campus Building** | `Building` | `VARCHAR2(50)` | — | NOT NULL (in CREATE) + Domain CHK (in ALTER) | In ALTER: `chk_dept_bldg CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'))` |
| **Campus Story** | `FloorLevel` | `VARCHAR2(20)` | — | NOT NULL (in CREATE) + Domain CHK (in ALTER) | In ALTER: `chk_dept_floor CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'))` |
| **Derived Location** | `/Location` | `VARCHAR2(80)` | — | VIRTUAL (in CREATE) | `GENERATED ALWAYS AS (Building \|\| ', ' \|\| FloorLevel) VIRTUAL` |
| **Blood Type** | `BloodType` | `VARCHAR2(5)` | — | NOT NULL + Domain CHK (in CREATE) | `CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))` |
| **Date of Birth** | `DateOfBirth` | `DATE` | — | NOT NULL + Bound CHKs | In CREATE: `chk_pat_dob CHECK (DateOfBirth >= DATE '1900-01-01')`<br>In ALTER: `chk_pat_dob_upper CHECK (DateOfBirth <= DATE '2026-12-31')` |
| **Postal Code** | `PostalCode` | `VARCHAR2(20)` | — | NOT NULL (in CREATE) + Format CHK (in ALTER) | In ALTER: `chk_<entity>_postal CHECK (REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$'))` |
| **Derived Address** | `/Address` | `VARCHAR2(250)` | — | VIRTUAL (in CREATE) | `GENERATED ALWAYS AS (BuildingNumber \|\| ' ' \|\| Street \|\| ', ' \|\| City \|\| ' ' \|\| PostalCode) VIRTUAL` |
| **Emergency Contact** | `EmergencyContact` | `VARCHAR2(20)` | — | NOT NULL + Diff CHK + Mobile CHK (in CREATE) | `chk_pat_emg CHECK (EmergencyContact <> Phone)`<br>`chk_pat_emg_num CHECK (REGEXP_LIKE(EmergencyContact, '^[0-9]+$') AND LENGTH(EmergencyContact) = 11 AND EmergencyContact LIKE '01%')` |

---

## 3. Completed Entity Specifications (Locked In)

### Table 1: `Department` (Student 1 - Subsystem 1)

```sql
CREATE TABLE Department (
    DepartmentID            VARCHAR2(10)        CONSTRAINT pk_department PRIMARY KEY,
    DepartmentName          VARCHAR2(50)        NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    Building                VARCHAR2(50)        NOT NULL,
    FloorLevel              VARCHAR2(20)        NOT NULL,
    Location                VARCHAR2(80)        GENERATED ALWAYS AS (Building || ', ' || FloorLevel) VIRTUAL,
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_dept_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL CONSTRAINT chk_dept_phone_type CHECK (PhoneType IN ('Landline', 'Mobile')),
    DepartmentDescription   VARCHAR2(255),
    CONSTRAINT chk_dept_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);

ALTER TABLE Department ADD CONSTRAINT chk_dept_id 
    CHECK (REGEXP_LIKE(DepartmentID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Department ADD CONSTRAINT chk_dept_bldg 
    CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'));

ALTER TABLE Department ADD CONSTRAINT chk_dept_floor 
    CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'));
```

---

### Table 2: `Doctor` (Student 1 - Subsystem 1)

```sql
CREATE TABLE Doctor (
    DoctorID                VARCHAR2(10)        CONSTRAINT pk_doctor PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_doc_gender CHECK (Gender IN ('Male', 'Female')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_doc_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL CONSTRAINT chk_doc_phone_type CHECK (PhoneType IN ('Mobile', 'Landline')),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_doc_email UNIQUE
                                                CONSTRAINT chk_doc_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    Specialty               VARCHAR2(50)        NOT NULL,
    HireDate                DATE                DEFAULT SYSDATE NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_doc_exp CHECK (YearsOfExperience BETWEEN 0 AND 60),
    DepartmentID            VARCHAR2(10)        NOT NULL,
    SupervisorID            VARCHAR2(10),
    CONSTRAINT fk_doc_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT fk_doc_supervisor FOREIGN KEY (SupervisorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_doc_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);

ALTER TABLE Doctor ADD CONSTRAINT chk_doc_id 
    CHECK (REGEXP_LIKE(DoctorID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Doctor ADD CONSTRAINT chk_doc_fname 
    CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'));

ALTER TABLE Doctor ADD CONSTRAINT chk_doc_lname 
    CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'));

ALTER TABLE Doctor ADD CONSTRAINT chk_doc_hire_date 
    CHECK (HireDate >= DATE '1980-01-01');

ALTER TABLE Doctor ADD CONSTRAINT chk_doc_no_self_sup 
    CHECK (SupervisorID IS NULL OR SupervisorID <> DoctorID);
```

---

### Table 3: `Nurse` (Student 1 - Subsystem 1)

```sql
CREATE TABLE Nurse (
    NurseID                 VARCHAR2(10)        CONSTRAINT pk_nurse PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_nurse_gender CHECK (Gender IN ('Male', 'Female')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_nurse_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL CONSTRAINT chk_nurse_phone_type CHECK (PhoneType IN ('Mobile', 'Landline')),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_nurse_email UNIQUE
                                                CONSTRAINT chk_nurse_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    Shift                   VARCHAR2(20)        DEFAULT 'Morning' NOT NULL CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Morning', 'Afternoon', 'Night', 'Rotating')),
    HireDate                DATE                DEFAULT SYSDATE NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_nurse_exp CHECK (YearsOfExperience BETWEEN 0 AND 60),
    DepartmentID            VARCHAR2(10)        NOT NULL,
    SupervisorID            VARCHAR2(10),
    CONSTRAINT fk_nurse_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT fk_nurse_supervisor FOREIGN KEY (SupervisorID) REFERENCES Nurse(NurseID),
    CONSTRAINT chk_nurse_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);

ALTER TABLE Nurse ADD CONSTRAINT chk_nurse_id 
    CHECK (REGEXP_LIKE(NurseID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Nurse ADD CONSTRAINT chk_nurse_fname 
    CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'));

ALTER TABLE Nurse ADD CONSTRAINT chk_nurse_lname 
    CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'));

ALTER TABLE Nurse ADD CONSTRAINT chk_nurse_hire_date 
    CHECK (HireDate >= DATE '1980-01-01');

ALTER TABLE Nurse ADD CONSTRAINT chk_nurse_no_self_sup 
    CHECK (SupervisorID IS NULL OR SupervisorID <> NurseID);
```

---

### Table 4: `Patient` (Student 2 - Subsystem 2)

```sql
CREATE TABLE Patient (
    PatientID               VARCHAR2(10)        CONSTRAINT pk_patient PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    DateOfBirth             DATE                NOT NULL CONSTRAINT chk_pat_dob CHECK (DateOfBirth >= DATE '1900-01-01'),
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_pat_gender CHECK (Gender IN ('Male', 'Female')),
    BloodType               VARCHAR2(5)         NOT NULL CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_pat_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL CONSTRAINT chk_pat_phone_type CHECK (PhoneType IN ('Mobile', 'Landline')),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_pat_email UNIQUE
                                                CONSTRAINT chk_pat_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    BuildingNumber          VARCHAR2(20),
    Street                  VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (BuildingNumber || ' ' || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
    EmergencyContact        VARCHAR2(20)        NOT NULL,
    CONSTRAINT chk_pat_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    ),
    CONSTRAINT chk_pat_emg CHECK (EmergencyContact <> Phone),
    CONSTRAINT chk_pat_emg_num CHECK (
        REGEXP_LIKE(EmergencyContact, '^[0-9]+$') AND
        LENGTH(EmergencyContact) = 11 AND 
        EmergencyContact LIKE '01%'
    )
);

ALTER TABLE Patient ADD CONSTRAINT chk_pat_id 
    CHECK (REGEXP_LIKE(PatientID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Patient ADD CONSTRAINT chk_pat_fname 
    CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'));

ALTER TABLE Patient ADD CONSTRAINT chk_pat_lname 
    CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'));

ALTER TABLE Patient ADD CONSTRAINT chk_pat_dob_upper 
    CHECK (DateOfBirth <= DATE '2026-12-31');

ALTER TABLE Patient ADD CONSTRAINT chk_pat_postal 
    CHECK (REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$'));
```

---

### Table 5: `Room` (Student 2 - Subsystem 2)

```sql
CREATE TABLE Room (
    RoomID                  VARCHAR2(10)        CONSTRAINT pk_room PRIMARY KEY,
    RoomNumber              VARCHAR2(10)        NOT NULL,
    Building                VARCHAR2(50)        NOT NULL,
    Floor                   VARCHAR2(20)        NOT NULL,
    RoomType                VARCHAR2(30)        NOT NULL CONSTRAINT chk_room_type CHECK (RoomType IN ('General Ward', 'Semi-Private', 'Private', 'ICU', 'Isolation', 'Emergency', 'Maternity', 'Pediatric', 'Operating Room')),
    Capacity                NUMBER(3)           DEFAULT 1 NOT NULL CONSTRAINT chk_room_capacity CHECK (Capacity > 0 AND Capacity <= 20),
    DailyCharge             NUMBER(10, 2)       NOT NULL CONSTRAINT chk_room_charge CHECK (DailyCharge > 0 AND DailyCharge <= 10000.00),
    AvailabilityStatus      VARCHAR2(20)        DEFAULT 'Available' NOT NULL CONSTRAINT chk_room_status CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance', 'Reserved')),
    CONSTRAINT uq_room_bldg_floor_num UNIQUE (Building, Floor, RoomNumber),
    CONSTRAINT chk_room_type_cap CHECK (
        (RoomType IN ('Private', 'ICU', 'Isolation') AND Capacity = 1) OR
        (RoomType = 'Semi-Private' AND Capacity = 2) OR
        (RoomType IN ('General Ward', 'Emergency', 'Maternity', 'Pediatric', 'Operating Room'))
    )
);

ALTER TABLE Room ADD CONSTRAINT chk_room_id 
    CHECK (REGEXP_LIKE(RoomID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Room ADD CONSTRAINT chk_room_number_fmt 
    CHECK (REGEXP_LIKE(RoomNumber, '^[A-Za-z0-9-]+$'));

ALTER TABLE Room ADD CONSTRAINT chk_room_bldg 
    CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'));

ALTER TABLE Room ADD CONSTRAINT chk_room_floor 
    CHECK (Floor IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'));
```

---

### Table 6: `Admission` (Student 2 - Subsystem 2)

```sql
CREATE TABLE Admission (
    AdmissionID             VARCHAR2(10)        CONSTRAINT pk_admission PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    RoomID                  VARCHAR2(10)        NOT NULL,
    AdmissionDate           DATE                DEFAULT SYSDATE NOT NULL,
    DischargeDate           DATE,
    AdmissionReason         VARCHAR2(255)       NOT NULL,
    AdmissionStatus         VARCHAR2(20)        DEFAULT 'Admitted' NOT NULL CONSTRAINT chk_adm_status CHECK (AdmissionStatus IN ('Admitted', 'Discharged')),
    CONSTRAINT fk_adm_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_adm_room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT chk_adm_dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate),
    CONSTRAINT chk_adm_status_sync CHECK (
        (AdmissionStatus = 'Admitted' AND DischargeDate IS NULL) OR
        (AdmissionStatus = 'Discharged' AND DischargeDate IS NOT NULL)
    )
);

ALTER TABLE Admission ADD CONSTRAINT chk_adm_id 
    CHECK (REGEXP_LIKE(AdmissionID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Admission ADD CONSTRAINT chk_adm_date_lower 
    CHECK (AdmissionDate >= DATE '2020-01-01');

ALTER TABLE Admission ADD CONSTRAINT chk_adm_reason_len 
    CHECK (LENGTH(TRIM(AdmissionReason)) >= 5);

ALTER TABLE Admission ADD CONSTRAINT uq_adm_pat_date 
    UNIQUE (PatientID, AdmissionDate);
```

---

### Table 7: `Appointment` (Student 3 - Subsystem 3)

```sql
CREATE TABLE Appointment (
    AppointmentID           VARCHAR2(10)        CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    AppointmentDate         DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_apt_date CHECK (AppointmentDate >= DATE '2020-01-01'),
    AppointmentTime         VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(AppointmentDate, 'HH24:MI')) VIRTUAL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')),
    Reason                  VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(500),
    CONSTRAINT fk_apt_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_apt_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_apt_status_note CHECK (Status NOT IN ('Cancelled', 'Rescheduled', 'No-Show') OR Notes IS NOT NULL),
    CONSTRAINT uq_apt_pat_time UNIQUE (PatientID, AppointmentDate)
);

ALTER TABLE Appointment ADD CONSTRAINT chk_apt_id 
    CHECK (REGEXP_LIKE(AppointmentID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Appointment ADD CONSTRAINT chk_apt_reason_len 
    CHECK (LENGTH(TRIM(Reason)) >= 5);

ALTER TABLE Appointment ADD CONSTRAINT uq_apt_doc_time 
    UNIQUE (DoctorID, AppointmentDate);
```

---

### Table 8: `MedicalRecord` (Student 3 - Subsystem 3)

```sql
CREATE TABLE MedicalRecord (
    RecordID                VARCHAR2(10)        CONSTRAINT pk_medical_record PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    Diagnosis               VARCHAR2(255)       NOT NULL,
    Treatment               VARCHAR2(500)       NOT NULL,
    Notes                   VARCHAR2(1000),
    RecordDate              DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_mr_rec_date CHECK (RecordDate >= DATE '2020-01-01'),
    FollowUpDate            DATE,
    CONSTRAINT fk_mr_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_mr_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_mr_dates CHECK (FollowUpDate IS NULL OR (FollowUpDate >= RecordDate AND FollowUpDate <= RecordDate + 365)),
    CONSTRAINT uq_mr_encounter UNIQUE (PatientID, DoctorID, RecordDate)
);

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_id 
    CHECK (REGEXP_LIKE(RecordID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_diag_len 
    CHECK (LENGTH(TRIM(Diagnosis)) >= 5);

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_treat_len 
    CHECK (LENGTH(TRIM(Treatment)) >= 5);
```

---

### Table 9: `MedicalProcedure` (Student 3 - Subsystem 3)

```sql
CREATE TABLE MedicalProcedure (
    ProcedureID             VARCHAR2(10)        CONSTRAINT pk_medical_procedure PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    ProcedureName           VARCHAR2(100)       NOT NULL,
    ProcedureDate           DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_proc_date CHECK (ProcedureDate >= DATE '2020-01-01'),
    Duration                NUMBER(4)           NOT NULL CONSTRAINT chk_proc_duration CHECK (Duration > 0 AND Duration <= 1440),
    EndTime                 DATE                GENERATED ALWAYS AS (ProcedureDate + (Duration / 1440)) VIRTUAL,
    OperatingRoom           VARCHAR2(30)        NOT NULL CONSTRAINT chk_proc_room CHECK (OperatingRoom IN ('OR-1', 'OR-2', 'OR-3', 'Cath Lab', 'Endoscopy Suite', 'Minor Surgery 1')),
    ProcedureCost           NUMBER(10, 2)       NOT NULL CONSTRAINT chk_proc_cost CHECK (ProcedureCost > 0 AND ProcedureCost <= 1000000.00),
    Outcome                 VARCHAR2(30)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_proc_outcome CHECK (Outcome IN ('Pending', 'In-Progress', 'Successful', 'Completed with Complications', 'Unsuccessful', 'Aborted')),
    CONSTRAINT fk_proc_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_proc_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT uq_proc_doc_time UNIQUE (DoctorID, ProcedureDate),
    CONSTRAINT uq_proc_room_time UNIQUE (OperatingRoom, ProcedureDate),
    CONSTRAINT uq_proc_pat_time UNIQUE (PatientID, ProcedureDate)
);

ALTER TABLE MedicalProcedure ADD CONSTRAINT chk_proc_id 
    CHECK (REGEXP_LIKE(ProcedureID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE MedicalProcedure ADD CONSTRAINT chk_proc_name_len 
    CHECK (LENGTH(TRIM(ProcedureName)) >= 5);
```

---

### Table 10: `Medication` (Student 4 - Subsystem 4)

```sql
CREATE TABLE Medication (
    MedicationID            VARCHAR2(10)        CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_category CHECK (Category IN ('Antibiotic', 'Analgesic', 'Antipyretic', 'Antihypertensive', 'Antidiabetic', 'Anticoagulant', 'Antihistamine', 'Bronchodilator', 'Statin', 'Gastrointestinal', 'Corticosteroid', 'Antidepressant', 'Antiviral', 'Cardiovascular', 'Dermatological', 'Other')),
    DosageForm              VARCHAR2(30)        NOT NULL CONSTRAINT chk_med_dosage_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Inhaler', 'Drops', 'Suspension', 'Patch', 'Suppository')),
    UnitPrice               NUMBER(10, 2)       NOT NULL CONSTRAINT chk_med_unit_price CHECK (UnitPrice > 0 AND UnitPrice <= 50000.00),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0 AND QuantityInStock <= 100000),
    ImportDate              DATE                DEFAULT SYSDATE NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    SupplierID              VARCHAR2(10)        NOT NULL,
    CONSTRAINT fk_med_supplier FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT chk_med_dates CHECK (ExpirationDate > ImportDate),
    CONSTRAINT uq_med_batch UNIQUE (MedicationName, Manufacturer, DosageForm, ExpirationDate)
);

ALTER TABLE Medication ADD CONSTRAINT chk_med_id 
    CHECK (REGEXP_LIKE(MedicationID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Medication ADD CONSTRAINT chk_med_name_len 
    CHECK (LENGTH(TRIM(MedicationName)) >= 5);

ALTER TABLE Medication ADD CONSTRAINT chk_med_mfg_len 
    CHECK (LENGTH(TRIM(Manufacturer)) >= 5);
```








