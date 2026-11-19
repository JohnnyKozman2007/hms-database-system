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

### Directive 2: Syntax Architecture (`CREATE` + `ALTER`)
* The `CREATE TABLE` block defines **only**:
  * Column name
  * Data type
  * `DEFAULT` value (if applicable)
  * `NOT NULL` nullability
  * `GENERATED ALWAYS AS (...) VIRTUAL` expression (if applicable)
* **All named constraints** (`PK`, `FK`, `UQ`, `CHK`) must be appended immediately below the `CREATE TABLE` statement using:
  ```sql
  ALTER TABLE <TableName> ADD CONSTRAINT <ConstraintName> <ConstraintType> (...);
  ```

### Directive 3: Universal Identifier (PK / FK) Standard
* Every entity primary key and referencing foreign key is typed as **`VARCHAR2(10)`**.
* **Rationale:** IDs are surrogate codes/badges that undergo no mathematical arithmetic. `VARCHAR2(10)` permits leading zeros (e.g., `'001'`), standard alphanumeric prefixes (e.g., `'DOC01'`, `'DEPT01'`), and flexible scaling.
* Every primary key enforces an alphanumeric format check:
  ```sql
  ALTER TABLE <Table> ADD CONSTRAINT chk_<entity>_id CHECK (REGEXP_LIKE(<Entity>ID, '^[A-Za-z0-9_-]+$'));
  ```

---

## 2. Standardized Column Pattern Matrix

When any table includes one of the standard semantic columns below, it **must** reuse the exact data type, nullability, default, and `ALTER TABLE` constraint specified here.

| Semantic Concept | Standard Column Name(s) | Data Type | Default | Constraint Type | Standard Implementation Pattern |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Primary Key** | `<Entity>ID` | `VARCHAR2(10)` | — | PK + Format CHK | `pk_<entity> PRIMARY KEY (<Entity>ID)`<br>`chk_<entity>_id CHECK (REGEXP_LIKE(<Entity>ID, '^[A-Za-z0-9_-]+$'))` |
| **Foreign Key** | `<TargetEntity>ID` | `VARCHAR2(10)` | — | FK | `fk_<source>_<target> FOREIGN KEY (<TargetID>) REFERENCES <Target>(<TargetID>)` |
| **Recursive FK** | `SupervisorID` | `VARCHAR2(10)` | `NULL` | FK + Self-Guard CHK | `fk_<entity>_supervisor FOREIGN KEY (SupervisorID) REFERENCES <Entity>(<EntityID>)`<br>`chk_<entity>_no_self_sup CHECK (SupervisorID IS NULL OR SupervisorID <> <Entity>ID)` |
| **Person First Name** | `FirstName` | `VARCHAR2(50)` | — | NOT NULL + Format CHK | `chk_<entity>_fname CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'))` |
| **Person Last Name** | `LastName` | `VARCHAR2(50)` | — | NOT NULL + Format CHK | `chk_<entity>_lname CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'))` |
| **Derived Full Name** | `/FullName` | `VARCHAR2(101)` | — | VIRTUAL | `GENERATED ALWAYS AS (FirstName \|\| ' ' \|\| LastName) VIRTUAL` |
| **Gender** | `Gender` | `VARCHAR2(10)` | — | NOT NULL + Domain CHK | `chk_<entity>_gender CHECK (Gender IN ('Male', 'Female'))` |
| **Email Address** | `Email` | `VARCHAR2(100)` | — | NOT NULL + UQ + CHK | `uq_<entity>_email UNIQUE (Email)`<br>`chk_<entity>_email_fmt CHECK (Email LIKE '%_@__%.__%')` |
| **Phone Type** | `PhoneType` | `VARCHAR2(10)` | `'Mobile'` (Persons)<br>`'Landline'` (Depts/Orgs) | NOT NULL + Domain CHK | `chk_<entity>_phone_type CHECK (PhoneType IN ('Mobile', 'Landline'))`<br>*(Note: Redundant `'Phone'` option is strictly abolished)* |
| **Phone Number** | `Phone` | `VARCHAR2(20)` | — | NOT NULL + UQ + Telecom CHK | `uq_<entity>_phone UNIQUE (Phone)`<br>`chk_<entity>_phone CHECK (`<br>`  REGEXP_LIKE(Phone, '^[0-9]+$') AND (`<br>`    (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR`<br>`    (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')))` |
| **Experience** | `YearsOfExperience` | `NUMBER(2)` | `0` | NOT NULL + Range CHK | `chk_<entity>_exp CHECK (YearsOfExperience BETWEEN 0 AND 60)` |
| **Hire Date** | `HireDate` | `DATE` | `SYSDATE` | NOT NULL + Bound CHK | `chk_<entity>_hire_date CHECK (HireDate >= DATE '1980-01-01')`<br>*(Oracle prohibits `SYSDATE` in CHECK constraints)* |
| **Campus Building** | `Building` | `VARCHAR2(50)` | — | NOT NULL + Domain CHK | `chk_dept_bldg CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'))` |
| **Campus Story** | `FloorLevel` | `VARCHAR2(20)` | — | NOT NULL + Domain CHK | `chk_dept_floor CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'))` |
| **Derived Location** | `/Location` | `VARCHAR2(80)` | — | VIRTUAL | `GENERATED ALWAYS AS (Building \|\| ', ' \|\| FloorLevel) VIRTUAL` |

---

## 3. Completed Entity Specifications (Locked In)

### Table 1: `Department` (Student 1 - Subsystem 1)

#### DDL Structure:
```sql
CREATE TABLE Department (
    DepartmentID            VARCHAR2(10),
    DepartmentName          VARCHAR2(50)        NOT NULL,
    Building                VARCHAR2(50)        NOT NULL,
    FloorLevel              VARCHAR2(20)        NOT NULL,
    Location                VARCHAR2(80)        GENERATED ALWAYS AS (Building || ', ' || FloorLevel) VIRTUAL,
    Phone                   VARCHAR2(20)        NOT NULL,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL,
    DepartmentDescription   VARCHAR2(255)
);
```

#### Enforced Constraints (`ALTER TABLE`):
1. **Primary Key:**
   ```sql
   ALTER TABLE Department ADD CONSTRAINT pk_department PRIMARY KEY (DepartmentID);
   ```
2. **Unique Constraints:**
   ```sql
   ALTER TABLE Department ADD CONSTRAINT uq_dept_name UNIQUE (DepartmentName);
   ALTER TABLE Department ADD CONSTRAINT uq_dept_phone UNIQUE (Phone);
   ```
3. **Check Constraints:**
   ```sql
   -- Alphanumeric primary key format
   ALTER TABLE Department ADD CONSTRAINT chk_dept_id 
       CHECK (REGEXP_LIKE(DepartmentID, '^[A-Za-z0-9_-]+$'));

   -- Standardized campus building code names
   ALTER TABLE Department ADD CONSTRAINT chk_dept_bldg 
       CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'));

   -- Standardized campus floor ordinal numbers
   ALTER TABLE Department ADD CONSTRAINT chk_dept_floor 
       CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'));

   -- Standardized phone type
   ALTER TABLE Department ADD CONSTRAINT chk_dept_phone_type 
       CHECK (PhoneType IN ('Landline', 'Mobile'));

   -- Egyptian telecom validation (Landline = 9-10 digits starting with 0, Mobile = 11 digits starting with 01)
   ALTER TABLE Department ADD CONSTRAINT chk_dept_phone CHECK (
       REGEXP_LIKE(Phone, '^[0-9]+$') AND (
           (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
           (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
       )
   );
   ```

---

### Table 2: `Doctor` (Student 1 - Subsystem 1)

#### DDL Structure:
```sql
CREATE TABLE Doctor (
    DoctorID                VARCHAR2(10),
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    Gender                  VARCHAR2(10)        NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL,
    Specialty               VARCHAR2(50)        NOT NULL,
    HireDate                DATE                DEFAULT SYSDATE NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL,
    DepartmentID            VARCHAR2(10)        NOT NULL,
    SupervisorID            VARCHAR2(10)
);
```

#### Enforced Constraints (`ALTER TABLE`):
1. **Primary Key:**
   ```sql
   ALTER TABLE Doctor ADD CONSTRAINT pk_doctor PRIMARY KEY (DoctorID);
   ```
2. **Foreign Keys:**
   ```sql
   -- References Department
   ALTER TABLE Doctor ADD CONSTRAINT fk_doc_dept 
       FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID);

   -- Unary/Recursive mentor reference (Doctor supervises Doctor)
   ALTER TABLE Doctor ADD CONSTRAINT fk_doc_supervisor 
       FOREIGN KEY (SupervisorID) REFERENCES Doctor(DoctorID);
   ```
3. **Unique Constraints:**
   ```sql
   ALTER TABLE Doctor ADD CONSTRAINT uq_doc_email UNIQUE (Email);
   ALTER TABLE Doctor ADD CONSTRAINT uq_doc_phone UNIQUE (Phone);
   ```
4. **Check Constraints:**
   ```sql
   -- Alphanumeric primary key format
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_id 
       CHECK (REGEXP_LIKE(DoctorID, '^[A-Za-z0-9_-]+$'));

   -- Alphabetic first and last names (allowing spaces, hyphens, apostrophes)
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_fname 
       CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'));

   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_lname 
       CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'));

   -- Standardized binary gender domain
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_gender 
       CHECK (Gender IN ('Male', 'Female'));

   -- Realistic medical career experience range
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_exp 
       CHECK (YearsOfExperience BETWEEN 0 AND 60);

   -- Historical employment start boundary (Oracle deterministic check)
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_hire_date 
       CHECK (HireDate >= DATE '1980-01-01');

   -- Recursive hierarchy guard: a doctor cannot supervise themselves
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_no_self_sup 
       CHECK (SupervisorID IS NULL OR SupervisorID <> DoctorID);

   -- Standard email address format
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_email_fmt 
       CHECK (Email LIKE '%_@__%.__%');

   -- Standardized phone type
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_phone_type 
       CHECK (PhoneType IN ('Mobile', 'Landline'));

   -- Egyptian telecom validation (Landline = 9-10 digits, Mobile = 11 digits)
   ALTER TABLE Doctor ADD CONSTRAINT chk_doc_phone CHECK (
       REGEXP_LIKE(Phone, '^[0-9]+$') AND (
           (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
           (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
       )
   );
   ```
