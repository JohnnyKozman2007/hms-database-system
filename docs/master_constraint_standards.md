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
| **Campus Building** | `Building` | `VARCHAR2(50)` | — | NOT NULL (in CREATE) + Domain CHK (in ALTER) | In ALTER: `chk_dept_bldg CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'))` |
| **Campus Story** | `FloorLevel` | `VARCHAR2(20)` | — | NOT NULL (in CREATE) + Domain CHK (in ALTER) | In ALTER: `chk_dept_floor CHECK (FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'))` |
| **Derived Location** | `/Location` | `VARCHAR2(80)` | — | VIRTUAL (in CREATE) | `GENERATED ALWAYS AS (Building \|\| ', ' \|\| FloorLevel) VIRTUAL` |

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
