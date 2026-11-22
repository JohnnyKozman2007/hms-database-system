-- HMS Master Run-All Script (Oracle SQL / Oracle APEX)
-- Complete self-contained build in student-grouped FK order (Student 1 -> 2 -> 3 -> 5 -> 4):
-- 16 Tables -> 29 Global & Student 1-5 PL/SQL Objects -> 2,123 Seed Rows.

-- ============================================================================
-- SECTION 1: TABLE DDL & CONSTRAINTS (STUDENT ORDER: 1 -> 2 -> 3 -> 5 -> 4)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STUDENT 1: Department & Staff Management
-- ----------------------------------------------------------------------------

-- Source: scripts/01_schema/student1_dept_staff/01_department.sql
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

-- Source: scripts/01_schema/student1_dept_staff/02_doctor.sql
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

-- Source: scripts/01_schema/student1_dept_staff/03_nurse.sql
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

-- ----------------------------------------------------------------------------
-- STUDENT 2: Patient & Admission Management
-- ----------------------------------------------------------------------------

-- Source: scripts/01_schema/student2_patient_admission/01_patient.sql
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
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (NVL2(BuildingNumber, BuildingNumber || ' ', '') || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
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

ALTER TABLE Patient ADD CONSTRAINT chk_pat_postal 
    CHECK (REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$'));

ALTER TABLE Patient ADD CONSTRAINT chk_pat_street_len
    CHECK (LENGTH(TRIM(Street)) >= 3);

ALTER TABLE Patient ADD CONSTRAINT chk_pat_city_fmt
    CHECK (REGEXP_LIKE(City, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(City)) >= 2);

-- Source: scripts/01_schema/student2_patient_admission/02_room.sql
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

-- Source: scripts/01_schema/student2_patient_admission/03_admission.sql
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

CREATE UNIQUE INDEX uq_adm_one_active_stay
    ON Admission (CASE WHEN AdmissionStatus = 'Admitted' THEN PatientID END);

-- ----------------------------------------------------------------------------
-- STUDENT 3: Appointments & Medical Records
-- ----------------------------------------------------------------------------

-- Source: scripts/01_schema/student3_appointments_records/01_appointment.sql
CREATE TABLE Appointment (
    AppointmentID           VARCHAR2(10)        CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    AppointmentDate         DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_apt_date CHECK (AppointmentDate >= DATE '2020-01-01'),
    AppointmentTime         VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(AppointmentDate, 'HH24:MI')) VIRTUAL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')),
    Reason                  VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(500)       CONSTRAINT chk_apt_notes_len CHECK (Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5),
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

-- Source: scripts/01_schema/student3_appointments_records/02_medical_record.sql
CREATE TABLE MedicalRecord (
    RecordID                VARCHAR2(10)        CONSTRAINT pk_medical_record PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    Diagnosis               VARCHAR2(255)       NOT NULL,
    Treatment               VARCHAR2(500)       NOT NULL,
    Notes                   VARCHAR2(1000)      CONSTRAINT chk_mr_notes_len CHECK (Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5),
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

-- Source: scripts/01_schema/student3_appointments_records/03_medical_procedure.sql
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

-- ----------------------------------------------------------------------------
-- STUDENT 5: Finance & Insurance Management (before Student 4 for Supplier FK)
-- ----------------------------------------------------------------------------

-- Source: scripts/01_schema/student5_finance_insurance/01_supplier.sql
CREATE TABLE Supplier (
    SupplierID              VARCHAR2(10)        CONSTRAINT pk_supplier PRIMARY KEY,
    CompanyName             VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_name UNIQUE,
    ContactPerson           VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_supp_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL CONSTRAINT chk_supp_phone_type CHECK (PhoneType IN ('Landline', 'Mobile')),
    Email                   VARCHAR2(100)       NOT NULL
                                                CONSTRAINT uq_supp_email UNIQUE
                                                CONSTRAINT chk_supp_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    BuildingNumber          VARCHAR2(20),
    Street                  VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (NVL2(BuildingNumber, BuildingNumber || ' ', '') || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
    ContractStatus          VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_supp_status CHECK (ContractStatus IN ('Active', 'Inactive', 'Terminated', 'Under Review')),
    CONSTRAINT chk_supp_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_id
    CHECK (REGEXP_LIKE(SupplierID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_company_len
    CHECK (LENGTH(TRIM(CompanyName)) >= 2);

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_contact_fmt
    CHECK (REGEXP_LIKE(ContactPerson, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(ContactPerson)) >= 3);

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_postal
    CHECK (REGEXP_LIKE(PostalCode, '^[A-Za-z0-9 -]+$'));

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_street_len
    CHECK (LENGTH(TRIM(Street)) >= 3);

ALTER TABLE Supplier ADD CONSTRAINT chk_supp_city_fmt
    CHECK (REGEXP_LIKE(City, '^[A-Za-z'' -]+$') AND LENGTH(TRIM(City)) >= 2);

-- Source: scripts/01_schema/student5_finance_insurance/02_insurance.sql
CREATE TABLE Insurance (
    InsuranceID             VARCHAR2(10)        CONSTRAINT pk_insurance PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    InsuranceCompany        VARCHAR2(100)       NOT NULL
                                                CONSTRAINT chk_ins_company CHECK (InsuranceCompany IN ('AXA Egypt', 'Bupa Egypt', 'Allianz Egypt', 'MetLife Egypt', 'Misr Insurance', 'GIG Egypt', 'Delta Insurance', 'Universal Health Insurance')),
    PolicyNumber            VARCHAR2(50)        NOT NULL CONSTRAINT uq_ins_policy UNIQUE,
    CoveragePercentage      NUMBER(5,2)         NOT NULL CONSTRAINT chk_ins_cov CHECK (CoveragePercentage BETWEEN 0 AND 100),
    StartDate               DATE                NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    InsuranceStatus         VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_ins_status CHECK (InsuranceStatus IN ('Active', 'Expired', 'Cancelled', 'Suspended')),
    CONSTRAINT fk_ins_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_ins_dates CHECK (ExpirationDate > StartDate)
);

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_id
    CHECK (REGEXP_LIKE(InsuranceID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_policy_fmt
    CHECK (REGEXP_LIKE(PolicyNumber, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(PolicyNumber)) >= 4);

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_start_date
    CHECK (StartDate >= DATE '2020-01-01');

ALTER TABLE Insurance ADD CONSTRAINT uq_ins_pat_comp_start
    UNIQUE (PatientID, InsuranceCompany, StartDate);

CREATE UNIQUE INDEX uq_ins_one_active_comp
    ON Insurance (
        CASE WHEN InsuranceStatus = 'Active' THEN PatientID END,
        CASE WHEN InsuranceStatus = 'Active' THEN InsuranceCompany END
    );

-- Source: scripts/01_schema/student5_finance_insurance/03_invoice.sql
CREATE TABLE Invoice (
    InvoiceID               VARCHAR2(10)        CONSTRAINT pk_invoice PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    InvoiceDate             DATE                DEFAULT SYSDATE NOT NULL,
    TotalAmount             NUMBER(10,2)        NOT NULL CONSTRAINT chk_inv_total CHECK (TotalAmount > 0),
    TaxAmount               NUMBER(10,2)        GENERATED ALWAYS AS (
                                                    ROUND(TotalAmount * CASE
                                                        WHEN TotalAmount < 1000 THEN 0.05
                                                        WHEN TotalAmount <= 10000 THEN 0.10
                                                        ELSE 0.14
                                                    END, 2)
                                                ) VIRTUAL,
    Discount                NUMBER(10,2)        DEFAULT 0.00 NOT NULL,
    NetAmount               NUMBER(12,2)        GENERATED ALWAYS AS (
                                                    TotalAmount + ROUND(TotalAmount * CASE
                                                        WHEN TotalAmount < 1000 THEN 0.05
                                                        WHEN TotalAmount <= 10000 THEN 0.10
                                                        ELSE 0.14
                                                    END, 2) - Discount
                                                ) VIRTUAL,
    DueDate                 DATE                DEFAULT SYSDATE + 3 NOT NULL,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Unpaid' NOT NULL CONSTRAINT chk_inv_status CHECK (PaymentStatus IN ('Unpaid', 'Overdue', 'Partially Paid', 'Paid')),
    CONSTRAINT fk_inv_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_inv_disc CHECK (Discount >= 0 AND Discount <= TotalAmount),
    CONSTRAINT chk_inv_dates CHECK (DueDate >= InvoiceDate AND DueDate <= InvoiceDate + 3)
);

ALTER TABLE Invoice ADD CONSTRAINT chk_inv_id
    CHECK (REGEXP_LIKE(InvoiceID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Invoice ADD CONSTRAINT chk_inv_date_lower
    CHECK (InvoiceDate >= DATE '2020-01-01');

-- Source: scripts/01_schema/student5_finance_insurance/04_payment.sql
CREATE TABLE Payment (
    PaymentID               VARCHAR2(10)        CONSTRAINT pk_payment PRIMARY KEY,
    InvoiceID               VARCHAR2(10)        NOT NULL,
    PaymentDate             DATE                DEFAULT SYSDATE NOT NULL,
    AmountPaid              NUMBER(10,2)        NOT NULL CONSTRAINT chk_pay_amt CHECK (AmountPaid > 0),
    PaymentMethod           VARCHAR2(30)        NOT NULL CONSTRAINT chk_pay_method CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Insurance Claim')),
    TransactionReference    VARCHAR2(100)       NOT NULL CONSTRAINT uq_pay_ref UNIQUE,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Completed' NOT NULL CONSTRAINT chk_pay_status CHECK (PaymentStatus IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_pay_invoice FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
);

ALTER TABLE Payment ADD CONSTRAINT chk_pay_id
    CHECK (REGEXP_LIKE(PaymentID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Payment ADD CONSTRAINT chk_pay_date_lower
    CHECK (PaymentDate >= DATE '2020-01-01');

ALTER TABLE Payment ADD CONSTRAINT chk_pay_ref_fmt
    CHECK (REGEXP_LIKE(TransactionReference, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(TransactionReference)) >= 4);

-- ----------------------------------------------------------------------------
-- STUDENT 4: Pharmacy & Laboratory Management
-- ----------------------------------------------------------------------------

-- Source: scripts/01_schema/student4_pharmacy_lab/01_medication.sql
CREATE TABLE Medication (
    MedicationID            VARCHAR2(10)        CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_category CHECK (Category IN ('Antibiotic', 'Analgesic', 'Antipyretic', 'Antihypertensive', 'Antidiabetic', 'Anticoagulant', 'Antihistamine', 'Bronchodilator', 'Statin', 'Gastrointestinal', 'Corticosteroid', 'Antidepressant', 'Antiviral', 'Cardiovascular', 'Dermatological', 'Other')),
    DosageForm              VARCHAR2(30)        NOT NULL CONSTRAINT chk_med_dosage_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Inhaler', 'Drops', 'Suspension', 'Patch', 'Suppository')),
    UnitPrice               NUMBER(10, 2)       NOT NULL CONSTRAINT chk_med_unit_price CHECK (UnitPrice > 0 AND UnitPrice <= 50000.00),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0 AND QuantityInStock <= 100000),
    ImportDate              DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_med_import_date CHECK (ImportDate >= DATE '2020-01-01'),
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

-- Source: scripts/01_schema/student4_pharmacy_lab/02_prescription.sql
CREATE TABLE Prescription (
    PrescriptionID          VARCHAR2(10)        CONSTRAINT pk_prescription PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    MedicationID            VARCHAR2(10)        NOT NULL,
    Dosage                  VARCHAR2(50)        NOT NULL,
    Frequency               VARCHAR2(50)        NOT NULL CONSTRAINT chk_rx_frequency CHECK (Frequency IN ('Once daily', 'Twice daily', 'Three times daily', 'Four times daily', 'Every 4 hours', 'Every 6 hours', 'Every 8 hours', 'Every 12 hours', 'As needed (PRN)', 'At bedtime', 'Weekly', 'Before meals', 'After meals')),
    Duration                NUMBER(3)           NOT NULL CONSTRAINT chk_rx_duration CHECK (Duration > 0 AND Duration <= 365),
    QuantityPrescribed      NUMBER(4)           DEFAULT 1 NOT NULL CONSTRAINT chk_rx_qty CHECK (QuantityPrescribed > 0 AND QuantityPrescribed <= 1000),
    DispenseStatus          VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_rx_dispense CHECK (DispenseStatus IN ('Pending', 'Dispensed', 'Cancelled')),
    PrescriptionDate        DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_rx_date CHECK (PrescriptionDate >= DATE '2020-01-01'),
    PrescriptionTime        VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(PrescriptionDate, 'HH24:MI')) VIRTUAL,
    EndDate                 DATE                GENERATED ALWAYS AS (PrescriptionDate + Duration) VIRTUAL,
    Notes                   VARCHAR2(500),
    CONSTRAINT fk_rx_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_rx_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_rx_medication FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID),
    CONSTRAINT uq_rx_order UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)
);

ALTER TABLE Prescription ADD CONSTRAINT chk_rx_id 
    CHECK (REGEXP_LIKE(PrescriptionID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Prescription ADD CONSTRAINT chk_rx_notes_len 
    CHECK (Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5);

-- Source: scripts/01_schema/student4_pharmacy_lab/03_laboratory_test.sql
CREATE TABLE LaboratoryTest (
    TestID                  VARCHAR2(10)        CONSTRAINT pk_laboratory_test PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    TestType                VARCHAR2(100)       NOT NULL,
    RequestedDate           DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_lab_req_date CHECK (RequestedDate >= DATE '2020-01-01'),
    CompletedDate           DATE,
    TestStatus              VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_lab_status CHECK (TestStatus IN ('Pending', 'In-Progress', 'Completed', 'Cancelled', 'Sample Collected')),
    TestResult              VARCHAR2(500),
    TestCost                NUMBER(10, 2)       NOT NULL CONSTRAINT chk_lab_cost CHECK (TestCost > 0 AND TestCost <= 50000.00),
    CONSTRAINT fk_lab_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_lab_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_lab_dates CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate),
    CONSTRAINT chk_lab_status_sync CHECK (
        (TestStatus IN ('Pending', 'In-Progress', 'Sample Collected') AND CompletedDate IS NULL AND TestResult IS NULL) OR
        (TestStatus = 'Completed' AND CompletedDate IS NOT NULL AND TestResult IS NOT NULL) OR
        (TestStatus = 'Cancelled' AND CompletedDate IS NULL)
    ),
    CONSTRAINT uq_lab_order UNIQUE (PatientID, DoctorID, TestType, RequestedDate)
);

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_id 
    CHECK (REGEXP_LIKE(TestID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_type_len 
    CHECK (LENGTH(TRIM(TestType)) >= 5);

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_result_len 
    CHECK (TestResult IS NULL OR LENGTH(TRIM(TestResult)) >= 5);

-- ============================================================================
-- SECTION 2: GLOBAL DATE TRIGGERS & STUDENTS 1-5 ADVANCED FEATURES
-- ============================================================================

-- Source: scripts/00_global_date_triggers.sql
CREATE OR REPLACE PROCEDURE sp_validate_date_upper_bound (
    p_date           IN DATE,
    p_max_days_ahead IN NUMBER,
    p_column_label   IN VARCHAR2
) IS
BEGIN
    IF p_date IS NOT NULL AND p_date > SYSDATE + p_max_days_ahead THEN
        IF p_max_days_ahead = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, p_column_label || ' cannot be in the future (exceeds SYSDATE).');
        ELSE
            RAISE_APPLICATION_ERROR(-20001, p_column_label || ' cannot be more than ' || p_max_days_ahead || ' days in the future.');
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_doc_date_max
BEFORE INSERT OR UPDATE OF HireDate ON Doctor
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.HireDate, 0, 'Doctor.HireDate');
END;
/

CREATE OR REPLACE TRIGGER trg_nurse_date_max
BEFORE INSERT OR UPDATE OF HireDate ON Nurse
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.HireDate, 0, 'Nurse.HireDate');
END;
/

CREATE OR REPLACE TRIGGER trg_pat_dob_max
BEFORE INSERT OR UPDATE OF DateOfBirth ON Patient
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.DateOfBirth, 0, 'Patient.DateOfBirth');
END;
/

CREATE OR REPLACE TRIGGER trg_adm_date_max
BEFORE INSERT OR UPDATE OF AdmissionDate, DischargeDate ON Admission
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.AdmissionDate, 0, 'Admission.AdmissionDate');
    sp_validate_date_upper_bound(:NEW.DischargeDate, 0, 'Admission.DischargeDate');
END;
/

CREATE OR REPLACE TRIGGER trg_mr_date_max
BEFORE INSERT OR UPDATE OF RecordDate ON MedicalRecord
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.RecordDate, 0, 'MedicalRecord.RecordDate');
END;
/

CREATE OR REPLACE TRIGGER trg_med_import_date_max
BEFORE INSERT OR UPDATE OF ImportDate ON Medication
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.ImportDate, 0, 'Medication.ImportDate');
END;
/

CREATE OR REPLACE TRIGGER trg_rx_date_max
BEFORE INSERT OR UPDATE OF PrescriptionDate ON Prescription
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.PrescriptionDate, 0, 'Prescription.PrescriptionDate');
END;
/

CREATE OR REPLACE TRIGGER trg_lab_date_max
BEFORE INSERT OR UPDATE OF RequestedDate, CompletedDate ON LaboratoryTest
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.RequestedDate, 0, 'LaboratoryTest.RequestedDate');
    sp_validate_date_upper_bound(:NEW.CompletedDate, 0, 'LaboratoryTest.CompletedDate');
END;
/

CREATE OR REPLACE TRIGGER trg_inv_date_max
BEFORE INSERT OR UPDATE OF InvoiceDate ON Invoice
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.InvoiceDate, 0, 'Invoice.InvoiceDate');
END;
/

CREATE OR REPLACE TRIGGER trg_ins_start_date_max
BEFORE INSERT OR UPDATE OF StartDate ON Insurance
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.StartDate, 0, 'Insurance.StartDate');
END;
/

CREATE OR REPLACE TRIGGER trg_pay_date_max
BEFORE INSERT OR UPDATE OF PaymentDate ON Payment
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.PaymentDate, 0, 'Payment.PaymentDate');
END;
/

CREATE OR REPLACE TRIGGER trg_apt_date_horizon
BEFORE INSERT OR UPDATE OF AppointmentDate ON Appointment
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.AppointmentDate, 365, 'Appointment.AppointmentDate');
END;
/

CREATE OR REPLACE TRIGGER trg_proc_date_horizon
BEFORE INSERT OR UPDATE OF ProcedureDate ON MedicalProcedure
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.ProcedureDate, 365, 'MedicalProcedure.ProcedureDate');
END;
/

-- Source: scripts/04_advanced_features/student1_view.sql
CREATE OR REPLACE VIEW vw_doctor_dept_workload AS
SELECT
    d.DoctorID,
    d.FullName                                          AS DoctorName,
    d.Specialty,
    d.YearsOfExperience,
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location                                       AS DepartmentLocation,
    sup.FullName                                        AS SupervisorName,
    (SELECT COUNT(*) FROM Appointment a
      WHERE a.DoctorID = d.DoctorID)                    AS TotalAppointments,
    (SELECT COUNT(*) FROM Appointment a
      WHERE a.DoctorID = d.DoctorID
        AND a.Status IN ('Scheduled', 'In-Progress'))   AS ActiveAppointments,
    (SELECT COUNT(*) FROM MedicalRecord mr
      WHERE mr.DoctorID = d.DoctorID)                   AS TotalMedicalRecords,
    (SELECT COUNT(*) FROM MedicalProcedure mp
      WHERE mp.DoctorID = d.DoctorID)                   AS TotalProcedures,
    (SELECT COUNT(*) FROM Prescription rx
      WHERE rx.DoctorID = d.DoctorID)                   AS TotalPrescriptions,
    (SELECT COUNT(*) FROM LaboratoryTest lt
      WHERE lt.DoctorID = d.DoctorID)                   AS TotalLabTests
FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN Doctor sup ON d.SupervisorID = sup.DoctorID;

CREATE OR REPLACE VIEW vw_department_staff_summary AS
SELECT
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location,
    dept.Phone                                          AS DepartmentPhone,
    COUNT(DISTINCT d.DoctorID)                          AS DoctorCount,
    COUNT(DISTINCT n.NurseID)                           AS NurseCount,
    COUNT(DISTINCT d.DoctorID) + COUNT(DISTINCT n.NurseID) AS TotalClinicalStaff,
    ROUND(NVL(AVG(d.YearsOfExperience), 0), 1)          AS AvgDoctorExperience,
    ROUND(NVL(AVG(n.YearsOfExperience), 0), 1)          AS AvgNurseExperience
FROM Department dept
LEFT JOIN Doctor d ON dept.DepartmentID = d.DepartmentID
LEFT JOIN Nurse n  ON dept.DepartmentID = n.DepartmentID
GROUP BY
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location,
    dept.Phone;

-- Source: scripts/04_advanced_features/student2_trigger.sql
CREATE OR REPLACE TRIGGER trg_adm_sync_room_status
FOR INSERT OR UPDATE OR DELETE ON Admission
COMPOUND TRIGGER
    TYPE t_room_map IS TABLE OF BOOLEAN INDEX BY VARCHAR2(10);
    g_affected_rooms t_room_map;

    BEFORE EACH ROW IS
        v_room_status VARCHAR2(20);
    BEGIN
        IF (INSERTING OR UPDATING) AND :NEW.AdmissionStatus = 'Admitted' THEN
            BEGIN
                SELECT AvailabilityStatus
                INTO v_room_status
                FROM Room
                WHERE RoomID = :NEW.RoomID;

                IF v_room_status = 'Maintenance' THEN
                    RAISE_APPLICATION_ERROR(-20011, 'Cannot admit patient to Room ' || :NEW.RoomID || ': Room is currently under Maintenance.');
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
            END;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_affected_rooms(:NEW.RoomID) := TRUE;
        END IF;
        IF UPDATING OR DELETING THEN
            g_affected_rooms(:OLD.RoomID) := TRUE;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_room_id      VARCHAR2(10);
        v_capacity     NUMBER(3);
        v_curr_status  VARCHAR2(20);
        v_active_count NUMBER;
    BEGIN
        v_room_id := g_affected_rooms.FIRST;
        WHILE v_room_id IS NOT NULL LOOP
            SELECT Capacity, AvailabilityStatus
            INTO v_capacity, v_curr_status
            FROM Room
            WHERE RoomID = v_room_id;

            SELECT COUNT(*)
            INTO v_active_count
            FROM Admission
            WHERE RoomID = v_room_id
              AND AdmissionStatus = 'Admitted';

            IF v_active_count > v_capacity THEN
                RAISE_APPLICATION_ERROR(-20010, 'Room capacity exceeded for Room ' || v_room_id || ' (Capacity: ' || v_capacity || ').');
            END IF;

            IF v_curr_status <> 'Maintenance' THEN
                IF v_active_count = v_capacity THEN
                    UPDATE Room
                    SET AvailabilityStatus = 'Occupied'
                    WHERE RoomID = v_room_id;
                ELSIF v_curr_status = 'Occupied' AND v_active_count < v_capacity THEN
                    UPDATE Room
                    SET AvailabilityStatus = 'Available'
                    WHERE RoomID = v_room_id;
                END IF;
            END IF;

            v_room_id := g_affected_rooms.NEXT(v_room_id);
        END LOOP;
        g_affected_rooms.DELETE;
    END AFTER STATEMENT;
END trg_adm_sync_room_status;
/

-- Source: scripts/04_advanced_features/student3_stored_proc.sql
-- ============================================================================
-- ADVANCED DATABASE FEATURE: Student 3
-- Stored Procedures & Automatic Backstop Triggers: Complete Conflict-Free Engine
-- Module: Data Modeling for DB (4FTC2063)
-- Subsystem: Appointments and Medical Records
-- ============================================================================
-- Architecture (Two-Layer Defense-in-Depth):
-- 1. Front-Door Application Layer (Stored Procedures):
--    - sp_book_appointment: Validates existence, dates, reasons, and books clean appointments.
--    - sp_schedule_procedure: Validates rooms, costs, durations, interval end-times, and availability.
-- 2. Engine-Level Backstop Layer (Compound Triggers):
--    - trg_procedure_overlap_guard: Blocks rogue raw INSERT/UPDATE interval collisions.
--    - trg_appointment_conflict_guard: Blocks rogue raw INSERT/UPDATE appointment collisions.
-- (Compound triggers eliminate ORA-04091 mutating table errors in Oracle SQL).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PROCEDURE: sp_book_appointment
-- Description: Books an appointment, ensuring input integrity and that neither
--              the Doctor nor the Patient already has an active scheduled appointment
--              at the exact requested time.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_book_appointment (
    p_appointment_id   IN VARCHAR2,
    p_patient_id       IN VARCHAR2,
    p_doctor_id        IN VARCHAR2,
    p_appointment_date IN DATE,
    p_reason           IN VARCHAR2,
    p_notes            IN VARCHAR2 DEFAULT NULL
) IS
    v_patient_exists      NUMBER := 0;
    v_doctor_exists       NUMBER := 0;
    v_doc_conflict_count  NUMBER := 0;
    v_pat_conflict_count  NUMBER := 0;
    v_time_str            VARCHAR2(5);
BEGIN
    -- 1. Validate Reason
    IF p_reason IS NULL OR TRIM(p_reason) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error: Appointment reason cannot be null or blank.');
    END IF;

    -- 2. Validate Appointment Date
    IF p_appointment_date IS NULL OR p_appointment_date < DATE '2020-01-01' THEN
        RAISE_APPLICATION_ERROR(-20013, 'Error: Appointment date must be valid and on or after 2020-01-01.');
    END IF;

    -- 3. Validate Patient existence
    SELECT COUNT(*) INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error: Patient ID ' || p_patient_id || ' does not exist in the database.');
    END IF;

    -- 4. Validate Doctor existence
    SELECT COUNT(*) INTO v_doctor_exists
    FROM Doctor
    WHERE DoctorID = p_doctor_id;

    IF v_doctor_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: Doctor ID ' || p_doctor_id || ' does not exist in the database.');
    END IF;

    -- 5. Extract time string for logging/checking
    v_time_str := TO_CHAR(p_appointment_date, 'HH24:MI');

    -- 6. Check for active appointment conflict for the doctor
    SELECT COUNT(*)
    INTO v_doc_conflict_count
    FROM Appointment
    WHERE DoctorID = p_doctor_id
      AND TRUNC(AppointmentDate) = TRUNC(p_appointment_date)
      AND AppointmentTime = v_time_str
      AND Status IN ('Scheduled', 'In-Progress');

    IF v_doc_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Booking Conflict: Doctor ' || p_doctor_id || 
            ' already has an active appointment at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
    END IF;

    -- 7. Check for active appointment conflict for the patient
    SELECT COUNT(*)
    INTO v_pat_conflict_count
    FROM Appointment
    WHERE PatientID = p_patient_id
      AND TRUNC(AppointmentDate) = TRUNC(p_appointment_date)
      AND AppointmentTime = v_time_str
      AND Status IN ('Scheduled', 'In-Progress');

    IF v_pat_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Booking Conflict: Patient ' || p_patient_id || 
            ' already has an active appointment at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
    END IF;

    -- 8. Insert clean appointment tuple
    INSERT INTO Appointment (
        AppointmentID,
        PatientID,
        DoctorID,
        AppointmentDate,
        Status,
        Reason,
        Notes
    ) VALUES (
        p_appointment_id,
        p_patient_id,
        p_doctor_id,
        p_appointment_date,
        'Scheduled',
        p_reason,
        p_notes
    );

    DBMS_OUTPUT.PUT_LINE('Success: Appointment #' || p_appointment_id || 
                         ' successfully booked for Patient ' || p_patient_id || 
                         ' with Doctor ' || p_doctor_id || ' at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
END sp_book_appointment;
/

-- ----------------------------------------------------------------------------
-- 2. PROCEDURE: sp_schedule_procedure
-- Description: Schedules a medical/surgical procedure, verifying that input values,
--              operating rooms, and time windows are clean and that neither
--              the Doctor, the Operating Room, nor the Patient has an overlapping time window.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_schedule_procedure (
    p_procedure_id     IN VARCHAR2,
    p_patient_id       IN VARCHAR2,
    p_doctor_id        IN VARCHAR2,
    p_procedure_name   IN VARCHAR2,
    p_procedure_date   IN DATE,
    p_operating_room   IN VARCHAR2,
    p_duration         IN NUMBER,
    p_procedure_cost   IN NUMBER
) IS
    v_patient_exists   NUMBER := 0;
    v_doctor_exists    NUMBER := 0;
    v_doc_conflicts    NUMBER := 0;
    v_room_conflicts   NUMBER := 0;
    v_pat_conflicts    NUMBER := 0;
    v_new_end_time     DATE;
BEGIN
    -- 1. Validate Procedure Name
    IF p_procedure_name IS NULL OR TRIM(p_procedure_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20023, 'Error: Procedure name cannot be null or blank.');
    END IF;

    -- 2. Validate Procedure Date
    IF p_procedure_date IS NULL OR p_procedure_date < DATE '2020-01-01' THEN
        RAISE_APPLICATION_ERROR(-20024, 'Error: Procedure date must be on or after 2020-01-01.');
    END IF;

    -- 3. Validate Duration
    IF p_duration <= 0 OR p_duration > 1440 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Error: Duration must be between 1 and 1440 minutes.');
    END IF;

    -- 4. Validate Cost
    IF p_procedure_cost <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Error: Procedure cost must be strictly positive.');
    END IF;

    -- 5. Validate Operating Room against standardized hospital surgical suites
    IF p_operating_room NOT IN ('OR-1', 'OR-2', 'OR-3', 'Cath Lab', 'Endoscopy Suite', 'Minor Surgery 1') THEN
        RAISE_APPLICATION_ERROR(-20022, 'Error: Invalid Operating Room "' || p_operating_room || 
            '". Permitted theaters: OR-1, OR-2, OR-3, Cath Lab, Endoscopy Suite, Minor Surgery 1.');
    END IF;

    -- 6. Validate Patient existence
    SELECT COUNT(*) INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error: Patient ID ' || p_patient_id || ' does not exist in the database.');
    END IF;

    -- 7. Validate Doctor existence
    SELECT COUNT(*) INTO v_doctor_exists
    FROM Doctor
    WHERE DoctorID = p_doctor_id;

    IF v_doctor_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: Doctor ID ' || p_doctor_id || ' does not exist in the database.');
    END IF;

    -- 8. Calculate proposed end time
    v_new_end_time := p_procedure_date + (p_duration / 1440);

    -- 9. Check for Doctor Schedule Interval Overlap
    SELECT COUNT(*)
    INTO v_doc_conflicts
    FROM MedicalProcedure
    WHERE DoctorID = p_doctor_id
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_doc_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Doctor Conflict: Doctor ' || p_doctor_id || 
            ' already has a procedure scheduled between ' || 
            TO_CHAR(p_procedure_date, 'HH24:MI') || ' and ' || TO_CHAR(v_new_end_time, 'HH24:MI') || '.');
    END IF;

    -- 10. Check for Operating Room Interval Overlap
    SELECT COUNT(*)
    INTO v_room_conflicts
    FROM MedicalProcedure
    WHERE OperatingRoom = p_operating_room
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_room_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Operating Room Conflict: Room ' || p_operating_room || 
            ' is already occupied by another procedure during this time window.');
    END IF;

    -- 11. Check for Patient Schedule Interval Overlap
    SELECT COUNT(*)
    INTO v_pat_conflicts
    FROM MedicalProcedure
    WHERE PatientID = p_patient_id
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_pat_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Patient Conflict: Patient ' || p_patient_id || 
            ' is already undergoing another procedure during this time window.');
    END IF;

    -- 12. Insert clean procedure tuple with initial 'Pending' state
    INSERT INTO MedicalProcedure (
        ProcedureID,
        PatientID,
        DoctorID,
        ProcedureName,
        ProcedureDate,
        Duration,
        OperatingRoom,
        ProcedureCost,
        Outcome
    ) VALUES (
        p_procedure_id,
        p_patient_id,
        p_doctor_id,
        p_procedure_name,
        p_procedure_date,
        p_duration,
        p_operating_room,
        p_procedure_cost,
        'Pending'
    );

    DBMS_OUTPUT.PUT_LINE('Success: Procedure #' || p_procedure_id || ' (' || p_procedure_name || 
                         ') scheduled in ' || p_operating_room || ' from ' || 
                         TO_CHAR(p_procedure_date, 'HH24:MI') || ' to ' || 
                         TO_CHAR(v_new_end_time, 'HH24:MI') || '.');
END sp_schedule_procedure;
/

-- ============================================================================
-- 3. COMPOUND TRIGGER: trg_procedure_overlap_guard
-- Description: Un-bypassable database engine backstop for MedicalProcedure.
--              Guarantees that even if someone bypasses the stored procedure and
--              runs a raw SQL INSERT or UPDATE directly on MedicalProcedure,
--              time-interval overlaps for Doctor, Operating Room, and Patient
--              are automatically blocked with an application error.
-- Architecture: Compound Trigger pattern (eliminates ORA-04091 mutating table error).
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_procedure_overlap_guard
FOR INSERT OR UPDATE ON MedicalProcedure
COMPOUND TRIGGER

    TYPE r_proc_record IS RECORD (
        procedure_id   VARCHAR2(10),
        patient_id     VARCHAR2(10),
        doctor_id      VARCHAR2(10),
        room           VARCHAR2(30),
        start_date     DATE,
        end_date       DATE,
        outcome        VARCHAR2(30)
    );
    TYPE t_proc_table IS TABLE OF r_proc_record;
    g_procs t_proc_table := t_proc_table();

    BEFORE STATEMENT IS
    BEGIN
        g_procs.DELETE;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        g_procs.EXTEND;
        g_procs(g_procs.LAST).procedure_id := :NEW.ProcedureID;
        g_procs(g_procs.LAST).patient_id   := :NEW.PatientID;
        g_procs(g_procs.LAST).doctor_id    := :NEW.DoctorID;
        g_procs(g_procs.LAST).room         := :NEW.OperatingRoom;
        g_procs(g_procs.LAST).start_date   := :NEW.ProcedureDate;
        g_procs(g_procs.LAST).end_date     := :NEW.ProcedureDate + (:NEW.Duration / 1440);
        g_procs(g_procs.LAST).outcome      := :NEW.Outcome;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_doc_conflicts  NUMBER := 0;
        v_room_conflicts NUMBER := 0;
        v_pat_conflicts  NUMBER := 0;
    BEGIN
        FOR i IN 1 .. g_procs.COUNT LOOP
            IF g_procs(i).outcome NOT IN ('Aborted', 'Cancelled') THEN
                -- 1. Doctor Interval Collision Check
                SELECT COUNT(*)
                INTO v_doc_conflicts
                FROM MedicalProcedure
                WHERE DoctorID = g_procs(i).doctor_id
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, ' ')
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_doc_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20002, 'Rogue DML Blocked: Doctor already has an active procedure scheduled in this time interval.');
                END IF;

                -- 2. Operating Room Collision Check
                SELECT COUNT(*)
                INTO v_room_conflicts
                FROM MedicalProcedure
                WHERE OperatingRoom = g_procs(i).room
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, ' ')
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_room_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20003, 'Rogue DML Blocked: Operating Room is already occupied in this time interval.');
                END IF;

                -- 3. Patient Collision Check
                SELECT COUNT(*)
                INTO v_pat_conflicts
                FROM MedicalProcedure
                WHERE PatientID = g_procs(i).patient_id
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, ' ')
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_pat_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20004, 'Rogue DML Blocked: Patient is already scheduled for another procedure in this time interval.');
                END IF;
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_procedure_overlap_guard;
/

-- ============================================================================
-- 4. COMPOUND TRIGGER: trg_appointment_conflict_guard
-- Description: Un-bypassable database engine backstop for Appointment.
--              Guarantees that even if someone runs a raw SQL INSERT or UPDATE
--              directly on Appointment, a Doctor cannot have two active
--              appointments ('Scheduled' or 'In-Progress') at the exact same minute.
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_appointment_conflict_guard
FOR INSERT OR UPDATE ON Appointment
COMPOUND TRIGGER

    TYPE r_apt_record IS RECORD (
        appointment_id VARCHAR2(10),
        doctor_id      VARCHAR2(10),
        patient_id     VARCHAR2(10),
        apt_date       DATE,
        status         VARCHAR2(20)
    );
    TYPE t_apt_table IS TABLE OF r_apt_record;
    g_apts t_apt_table := t_apt_table();

    BEFORE STATEMENT IS
    BEGIN
        g_apts.DELETE;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        g_apts.EXTEND;
        g_apts(g_apts.LAST).appointment_id := :NEW.AppointmentID;
        g_apts(g_apts.LAST).doctor_id      := :NEW.DoctorID;
        g_apts(g_apts.LAST).patient_id     := :NEW.PatientID;
        g_apts(g_apts.LAST).apt_date       := :NEW.AppointmentDate;
        g_apts(g_apts.LAST).status         := :NEW.Status;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_doc_conflicts NUMBER := 0;
        v_pat_conflicts NUMBER := 0;
    BEGIN
        FOR i IN 1 .. g_apts.COUNT LOOP
            IF g_apts(i).status IN ('Scheduled', 'In-Progress') THEN
                -- Doctor Conflict
                SELECT COUNT(*)
                INTO v_doc_conflicts
                FROM Appointment
                WHERE DoctorID = g_apts(i).doctor_id
                  AND AppointmentID <> NVL(g_apts(i).appointment_id, ' ')
                  AND Status IN ('Scheduled', 'In-Progress')
                  AND TRUNC(AppointmentDate) = TRUNC(g_apts(i).apt_date)
                  AND TO_CHAR(AppointmentDate, 'HH24:MI') = TO_CHAR(g_apts(i).apt_date, 'HH24:MI');

                IF v_doc_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20001, 'Rogue DML Blocked: Doctor already has an active appointment at this date and time.');
                END IF;

                -- Patient Conflict
                SELECT COUNT(*)
                INTO v_pat_conflicts
                FROM Appointment
                WHERE PatientID = g_apts(i).patient_id
                  AND AppointmentID <> NVL(g_apts(i).appointment_id, ' ')
                  AND Status IN ('Scheduled', 'In-Progress')
                  AND TRUNC(AppointmentDate) = TRUNC(g_apts(i).apt_date)
                  AND TO_CHAR(AppointmentDate, 'HH24:MI') = TO_CHAR(g_apts(i).apt_date, 'HH24:MI');

                IF v_pat_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20005, 'Rogue DML Blocked: Patient already has an active appointment at this date and time.');
                END IF;
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_appointment_conflict_guard;
/

-- Source: scripts/04_advanced_features/student4_trigger.sql
CREATE OR REPLACE TRIGGER trg_rx_manage_medication_stock
BEFORE INSERT OR UPDATE OF DispenseStatus, QuantityPrescribed, MedicationID ON Prescription
FOR EACH ROW
DECLARE
    v_stock    NUMBER(6);
    v_exp_date DATE;
BEGIN
    IF INSERTING THEN
        IF :NEW.DispenseStatus = 'Dispensed' THEN
            SELECT QuantityInStock, ExpirationDate
            INTO v_stock, v_exp_date
            FROM Medication
            WHERE MedicationID = :NEW.MedicationID
            FOR UPDATE;

            IF v_exp_date < SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
            END IF;

            IF v_stock < :NEW.QuantityPrescribed THEN
                RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
            END IF;

            UPDATE Medication
            SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
            WHERE MedicationID = :NEW.MedicationID;
        END IF;

    ELSIF UPDATING THEN
        IF :OLD.DispenseStatus = 'Dispensed' AND :NEW.DispenseStatus <> 'Dispensed' THEN
            UPDATE Medication
            SET QuantityInStock = QuantityInStock + :OLD.QuantityPrescribed
            WHERE MedicationID = :OLD.MedicationID;

        ELSIF :OLD.DispenseStatus <> 'Dispensed' AND :NEW.DispenseStatus = 'Dispensed' THEN
            SELECT QuantityInStock, ExpirationDate
            INTO v_stock, v_exp_date
            FROM Medication
            WHERE MedicationID = :NEW.MedicationID
            FOR UPDATE;

            IF v_exp_date < SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
            END IF;

            IF v_stock < :NEW.QuantityPrescribed THEN
                RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
            END IF;

            UPDATE Medication
            SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
            WHERE MedicationID = :NEW.MedicationID;

        ELSIF :OLD.DispenseStatus = 'Dispensed' AND :NEW.DispenseStatus = 'Dispensed' THEN
            IF :OLD.MedicationID <> :NEW.MedicationID OR :OLD.QuantityPrescribed <> :NEW.QuantityPrescribed THEN
                UPDATE Medication
                SET QuantityInStock = QuantityInStock + :OLD.QuantityPrescribed
                WHERE MedicationID = :OLD.MedicationID;

                SELECT QuantityInStock, ExpirationDate
                INTO v_stock, v_exp_date
                FROM Medication
                WHERE MedicationID = :NEW.MedicationID
                FOR UPDATE;

                IF v_exp_date < SYSDATE THEN
                    RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
                END IF;

                IF v_stock < :NEW.QuantityPrescribed THEN
                    RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
                END IF;

                UPDATE Medication
                SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
                WHERE MedicationID = :NEW.MedicationID;
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
END trg_rx_manage_medication_stock;
/

-- Source: scripts/04_advanced_features/student5_function.sql
CREATE OR REPLACE FUNCTION fn_get_patient_net_balance (
    p_patient_id IN VARCHAR2
) RETURN NUMBER IS
    v_patient_exists NUMBER := 0;
    v_total_billed   NUMBER(12, 2) := 0;
    v_total_paid     NUMBER(12, 2) := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20040, 'Patient ID ' || p_patient_id || ' does not exist.');
    END IF;

    SELECT NVL(SUM(NetAmount), 0)
    INTO v_total_billed
    FROM Invoice
    WHERE PatientID = p_patient_id;

    SELECT NVL(SUM(p.AmountPaid), 0)
    INTO v_total_paid
    FROM Payment p
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    WHERE i.PatientID = p_patient_id
      AND p.PaymentStatus = 'Completed';

    RETURN ROUND(v_total_billed - v_total_paid, 2);
END fn_get_patient_net_balance;
/

CREATE OR REPLACE FUNCTION fn_get_invoice_patient_copay (
    p_invoice_id IN VARCHAR2
) RETURN NUMBER IS
    v_patient_id   VARCHAR2(10);
    v_net_amount   NUMBER(12, 2);
    v_coverage_pct NUMBER(5, 2) := 0;
BEGIN
    SELECT PatientID, NetAmount
    INTO v_patient_id, v_net_amount
    FROM Invoice
    WHERE InvoiceID = p_invoice_id;

    SELECT NVL(MAX(CoveragePercentage), 0)
    INTO v_coverage_pct
    FROM Insurance
    WHERE PatientID = v_patient_id
      AND InsuranceStatus = 'Active'
      AND ExpirationDate >= SYSDATE;

    RETURN ROUND(v_net_amount * (1 - (v_coverage_pct / 100)), 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20041, 'Invoice ID ' || p_invoice_id || ' does not exist.');
END fn_get_invoice_patient_copay;
/

CREATE OR REPLACE FUNCTION fn_get_patient_financial_status (
    p_patient_id IN VARCHAR2
) RETURN VARCHAR2 IS
    v_base_balance  NUMBER(12, 2) := 0;
    v_late_Penalty  NUMBER(12, 2) := 0;
    v_total_owed    NUMBER(12, 2) := 0;
    v_overdue_count NUMBER := 0;
    v_max_weeks     NUMBER := 0;
BEGIN
    v_base_balance := fn_get_patient_net_balance(p_patient_id);

    SELECT
        COUNT(*),
        NVL(MAX(FLOOR((SYSDATE - i.DueDate) / 7)), 0),
        NVL(SUM(
            (i.NetAmount - NVL((
                SELECT SUM(p.AmountPaid)
                FROM Payment p
                WHERE p.InvoiceID = i.InvoiceID
                  AND p.PaymentStatus = 'Completed'
            ), 0)) * (0.10 * GREATEST(FLOOR((SYSDATE - i.DueDate) / 7), 0))
        ), 0)
    INTO v_overdue_count, v_max_weeks, v_late_penalty
    FROM Invoice i
    WHERE i.PatientID = p_patient_id
      AND i.PaymentStatus <> 'Paid'
      AND i.DueDate < SYSDATE;

    v_total_owed := ROUND(v_base_balance + v_late_penalty, 2);

    IF v_total_owed <= 0 THEN
        RETURN 'CLEAR (Balance: 0.00)';
    ELSIF v_overdue_count > 0 AND v_max_weeks >= 1 THEN
        RETURN 'BANNED - OVERDUE ' || v_max_weeks || ' WEEK(S) (Base: ' || v_base_balance ||
               ', +10%/wk Penalty: ' || ROUND(v_late_penalty, 2) || ', Total Owed: ' || v_total_owed || ')';
    ELSIF v_overdue_count > 0 THEN
        RETURN 'WARNING - PAST DUE <1 WEEK (Total Owed: ' || v_total_owed || ')';
    ELSE
        RETURN 'ACTIVE TAB - NOT YET DUE (Total Owed: ' || v_total_owed || ')';
    END IF;
END fn_get_patient_financial_status;
/

-- Source: scripts/04_advanced_features/student5_triggers.sql
CREATE OR REPLACE TRIGGER trg_ins_status_date_guard
BEFORE INSERT OR UPDATE OF ExpirationDate, InsuranceStatus ON Insurance
FOR EACH ROW
BEGIN
    IF :NEW.ExpirationDate < SYSDATE AND :NEW.InsuranceStatus = 'Active' THEN
        RAISE_APPLICATION_ERROR(-20005, 'Cannot set InsuranceStatus to Active when ExpirationDate is in the past; must be Expired.');
    ELSIF :NEW.ExpirationDate >= SYSDATE AND :NEW.InsuranceStatus = 'Expired' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Cannot set InsuranceStatus to Expired when ExpirationDate has not passed yet.');
    END IF;
END trg_ins_status_date_guard;
/

CREATE OR REPLACE TRIGGER trg_inv_status_guard
BEFORE INSERT OR UPDATE ON Invoice
FOR EACH ROW
DECLARE
    v_total_paid      NUMBER(12, 2) := 0;
    v_expected_status VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        IF :NEW.PaymentStatus IN ('Paid', 'Partially Paid') THEN
            RAISE_APPLICATION_ERROR(-20007, 'New invoices cannot be inserted directly as Paid or Partially Paid; insert as Unpaid/Overdue and add rows to Payment.');
        ELSIF :NEW.DueDate < SYSDATE AND :NEW.PaymentStatus = 'Unpaid' THEN
            RAISE_APPLICATION_ERROR(-20008, 'Cannot insert Invoice as Unpaid when DueDate is already in the past; must be Overdue.');
        ELSIF :NEW.DueDate >= SYSDATE AND :NEW.PaymentStatus = 'Overdue' THEN
            RAISE_APPLICATION_ERROR(-20009, 'Cannot insert Invoice as Overdue when DueDate has not passed yet; must be Unpaid.');
        END IF;
    ELSIF UPDATING THEN
        SELECT NVL(SUM(AmountPaid), 0)
        INTO v_total_paid
        FROM Payment
        WHERE InvoiceID = :NEW.InvoiceID
          AND PaymentStatus = 'Completed';

        IF v_total_paid > :NEW.NetAmount THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invoice NetAmount cannot be reduced below already-completed payments (' || v_total_paid || ').');
        END IF;

        IF v_total_paid >= :NEW.NetAmount THEN
            v_expected_status := 'Paid';
        ELSIF v_total_paid > 0 THEN
            v_expected_status := 'Partially Paid';
        ELSIF :NEW.DueDate < SYSDATE THEN
            v_expected_status := 'Overdue';
        ELSE
            v_expected_status := 'Unpaid';
        END IF;

        IF UPDATING('PaymentStatus')
           AND NOT UPDATING('TotalAmount')
           AND NOT UPDATING('Discount')
           AND NOT UPDATING('DueDate') THEN
            IF :NEW.PaymentStatus <> v_expected_status THEN
                RAISE_APPLICATION_ERROR(-20007, 'Cannot manually set Invoice.PaymentStatus to ' || :NEW.PaymentStatus || '; expected status from Payment is ' || v_expected_status || '.');
            END IF;
        ELSE
            :NEW.PaymentStatus := v_expected_status;
        END IF;
    END IF;
END trg_inv_status_guard;
/

CREATE OR REPLACE TRIGGER trg_pay_check_insurance
BEFORE INSERT OR UPDATE OF PaymentMethod, InvoiceID ON Payment
FOR EACH ROW
WHEN (NEW.PaymentMethod = 'Insurance Claim')
DECLARE
    v_active_ins NUMBER := 0;
BEGIN
    UPDATE Insurance
    SET InsuranceStatus = 'Expired'
    WHERE InsuranceStatus = 'Active'
      AND ExpirationDate < SYSDATE;

    SELECT COUNT(*)
    INTO v_active_ins
    FROM Invoice inv
    JOIN Insurance ins ON inv.PatientID = ins.PatientID
    WHERE inv.InvoiceID = :NEW.InvoiceID
      AND ins.InsuranceStatus = 'Active'
      AND ins.ExpirationDate >= SYSDATE;

    IF v_active_ins = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Insurance Claim payment rejected: Patient has no active, unexpired insurance policy.');
    END IF;
END trg_pay_check_insurance;
/

CREATE OR REPLACE TRIGGER trg_pay_balance_and_status
FOR INSERT OR UPDATE OR DELETE ON Payment
COMPOUND TRIGGER
    TYPE t_inv_map IS TABLE OF BOOLEAN INDEX BY VARCHAR2(10);
    g_affected_invoices t_inv_map;

    BEFORE EACH ROW IS
        v_inv_date DATE;
    BEGIN
        IF INSERTING OR UPDATING THEN
            BEGIN
                SELECT InvoiceDate
                INTO v_inv_date
                FROM Invoice
                WHERE InvoiceID = :NEW.InvoiceID;

                IF :NEW.PaymentDate < v_inv_date THEN
                    RAISE_APPLICATION_ERROR(-20004, 'PaymentDate cannot be earlier than Invoice.InvoiceDate for Invoice ' || :NEW.InvoiceID || '.');
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
            END;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_affected_invoices(:NEW.InvoiceID) := TRUE;
        END IF;
        IF UPDATING OR DELETING THEN
            g_affected_invoices(:OLD.InvoiceID) := TRUE;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_inv_id     VARCHAR2(10);
        v_net_amount NUMBER(12, 2);
        v_due_date   DATE;
        v_total_paid NUMBER(12, 2);
        v_new_status VARCHAR2(20);
    BEGIN
        UPDATE Insurance
        SET InsuranceStatus = 'Expired'
        WHERE InsuranceStatus = 'Active'
          AND ExpirationDate < SYSDATE;

        UPDATE Invoice
        SET PaymentStatus = 'Overdue'
        WHERE PaymentStatus = 'Unpaid'
          AND DueDate < SYSDATE;

        v_inv_id := g_affected_invoices.FIRST;
        WHILE v_inv_id IS NOT NULL LOOP
            SELECT NetAmount, DueDate
            INTO v_net_amount, v_due_date
            FROM Invoice
            WHERE InvoiceID = v_inv_id;

            SELECT NVL(SUM(AmountPaid), 0)
            INTO v_total_paid
            FROM Payment
            WHERE InvoiceID = v_inv_id
              AND PaymentStatus = 'Completed';

            IF v_total_paid > v_net_amount THEN
                RAISE_APPLICATION_ERROR(-20002, 'Payment exceeds remaining invoice balance for Invoice ' || v_inv_id || '.');
            END IF;

            IF v_total_paid >= v_net_amount THEN
                v_new_status := 'Paid';
            ELSIF v_total_paid > 0 THEN
                v_new_status := 'Partially Paid';
            ELSIF v_due_date < SYSDATE THEN
                v_new_status := 'Overdue';
            ELSE
                v_new_status := 'Unpaid';
            END IF;

            UPDATE Invoice
            SET PaymentStatus = v_new_status
            WHERE InvoiceID = v_inv_id;

            v_inv_id := g_affected_invoices.NEXT(v_inv_id);
        END LOOP;
        g_affected_invoices.DELETE;
    END AFTER STATEMENT;
END trg_pay_balance_and_status;
/

-- ============================================================================
-- SECTION 3: SEED DATA INSERTS (2,123 ROWS IN STUDENT ORDER: 1 -> 2 -> 3 -> 5 -> 4)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STUDENT 1: Department & Staff Management Seeds
-- ----------------------------------------------------------------------------

-- Source: scripts/02_seeds/student1_dept_staff/insert_department.sql
-- SEED DATA: Department (Student 1) - 8 rows
-- Row 1 omits PhoneType to exercise DEFAULT ('Landline').

INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, DepartmentDescription) VALUES ('DEPT01', 'Cardiology', 'Building A', '1st Floor', '0227951001', 'Diagnosis and treatment of heart and cardiovascular disorders.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT02', 'Emergency Medicine', 'Building A', 'Ground Floor', '0227951002', 'Landline', '24/7 acute trauma, resuscitation, and emergency stabilization.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT03', 'Pediatrics', 'Building A', '2nd Floor', '0227951003', 'Landline', 'Comprehensive medical care for infants, children, and adolescents.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT04', 'Orthopedics', 'Building B', '1st Floor', '0227951004', 'Landline', 'Musculoskeletal surgery, fracture care, and joint rehabilitation.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT05', 'Neurology', 'Building B', '3rd Floor', '0227951005', 'Landline', 'Treatment of neurological diseases, stroke, and seizure disorders.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT06', 'Oncology', 'Building C', '2nd Floor', '01001122006', 'Mobile', 'Medical oncology, chemotherapy infusion, and cancer care coordination.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT07', 'Radiology', 'Building C', 'Ground Floor', '0227951007', 'Landline', 'Diagnostic imaging including MRI, CT, ultrasound, and X-ray.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT08', 'General Surgery', 'Building D', '4th Floor', '01112233008', 'Mobile', 'Elective and emergency surgical procedures across inpatient wards.');

COMMIT;

-- Source: scripts/02_seeds/student1_dept_staff/insert_doctor.sql
-- SEED DATA: Doctor (Student 1) - 20 rows
-- Row 1 omits PhoneType ('Mobile'), HireDate (SYSDATE), YearsOfExperience (0), and SupervisorID (NULL).

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, DepartmentID) VALUES ('DOC001', 'Karim', 'Mansour', 'Male', '01012340001', 'karim.mansour@hms.org', 'Interventional Cardiology', 'DEPT01');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC002', 'Ahmed', 'El-Sayed', 'Male', '01012340002', 'Mobile', 'ahmed.elsayed@hms.org', 'Cardiology', DATE '2005-03-15', 21, 'DEPT01', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC003', 'Mona', 'Hassan', 'Female', '01012340003', 'Mobile', 'mona.hassan@hms.org', 'Emergency Medicine', DATE '2008-06-01', 18, 'DEPT02', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC004', 'Heba', 'Abdelrahman', 'Female', '01012340004', 'Mobile', 'heba.abdelrahman@hms.org', 'Pediatrics', DATE '2010-09-10', 16, 'DEPT03', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC005', 'Tarek', 'Ibrahim', 'Male', '01012340005', 'Mobile', 'tarek.ibrahim@hms.org', 'Orthopedic Surgery', DATE '2004-01-20', 22, 'DEPT04', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC006', 'Nadia', 'Kamel', 'Female', '0227952006', 'Landline', 'nadia.kamel@hms.org', 'Neurology', DATE '2007-11-05', 19, 'DEPT05', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC007', 'Sherif', 'Nabil', 'Male', '01012340007', 'Mobile', 'sherif.nabil@hms.org', 'Medical Oncology', DATE '2006-04-12', 20, 'DEPT06', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC008', 'Dalia', 'Farouk', 'Female', '0227952008', 'Landline', 'dalia.farouk@hms.org', 'Diagnostic Radiology', DATE '2011-02-18', 15, 'DEPT07', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC009', 'Khaled', 'Mostafa', 'Male', '01012340009', 'Mobile', 'khaled.mostafa@hms.org', 'General Surgery', DATE '2002-08-25', 24, 'DEPT08', NULL);
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC010', 'Youssef', 'Adel', 'Male', '01112340010', 'Mobile', 'youssef.adel@hms.org', 'Clinical Cardiology', DATE '2017-05-14', 9, 'DEPT01', 'DOC002');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC011', 'Salma', 'Fathy', 'Female', '01112340011', 'Mobile', 'salma.fathy@hms.org', 'Electrophysiology', DATE '2019-10-01', 7, 'DEPT01', 'DOC002');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC012', 'Omar', 'Gamal', 'Male', '01112340012', 'Mobile', 'omar.gamal@hms.org', 'Pediatric Cardiology', DATE '2021-03-22', 5, 'DEPT01', 'DOC002');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC013', 'Rania', 'Samir', 'Female', '01212340013', 'Mobile', 'rania.samir@hms.org', 'Trauma Care', DATE '2016-07-19', 10, 'DEPT02', 'DOC003');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC014', 'Hassan', 'Zaki', 'Male', '01212340014', 'Mobile', 'hassan.zaki@hms.org', 'Acute Care', DATE '2022-01-10', 4, 'DEPT02', 'DOC003');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC015', 'Mariam', 'Tawfik', 'Female', '01212340015', 'Mobile', 'mariam.tawfik@hms.org', 'Neonatology', DATE '2018-04-08', 8, 'DEPT03', 'DOC004');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC016', 'Wael', 'Saeed', 'Male', '01512340016', 'Mobile', 'wael.saeed@hms.org', 'Sports Medicine', DATE '2015-09-30', 11, 'DEPT04', 'DOC005');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC017', 'Laila', 'Ashraf', 'Female', '01512340017', 'Mobile', 'laila.ashraf@hms.org', 'Neurophysiology', DATE '2020-06-15', 6, 'DEPT05', 'DOC006');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC018', 'Amr', 'Soliman', 'Male', '01512340018', 'Mobile', 'amr.soliman@hms.org', 'Radiation Oncology', DATE '2014-12-03', 12, 'DEPT06', 'DOC007');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC019', 'Nour', 'El-Din', 'Male', '01092340019', 'Mobile', 'nour.eldin@hms.org', 'Interventional Radiology', DATE '2019-02-11', 7, 'DEPT07', 'DOC008');
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('DOC020', 'Farah', 'Yassin', 'Female', '01092340020', 'Mobile', 'farah.yassin@hms.org', 'Laparoscopic Surgery', DATE '2016-11-20', 10, 'DEPT08', 'DOC009');

COMMIT;

-- Source: scripts/02_seeds/student1_dept_staff/insert_nurse.sql
-- SEED DATA: Nurse (Student 1) - 30 rows
-- Row 1 omits PhoneType ('Mobile'), Shift ('Morning'), HireDate (SYSDATE), YearsOfExperience (0), and SupervisorID (NULL).

INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, DepartmentID) VALUES ('NRS001', 'Aya', 'Mahmoud', 'Female', '01023450001', 'aya.mahmoud1@hms.org', 'DEPT01');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS002', 'Sara', 'Hamed', 'Female', '01123450002', 'Mobile', 'sara.hamed2@hms.org', 'Afternoon', DATE '2014-02-02', 11, 'DEPT01', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS003', 'Hana', 'Rashad', 'Female', '01223450003', 'Mobile', 'hana.rashad3@hms.org', 'Night', DATE '2013-03-03', 12, 'DEPT02', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS004', 'Reem', 'Fawzy', 'Female', '01523450004', 'Mobile', 'reem.fawzy4@hms.org', 'Rotating', DATE '2012-04-04', 13, 'DEPT03', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS005', 'Dina', 'Ezzat', 'Female', '01023450005', 'Mobile', 'dina.ezzat5@hms.org', 'Morning', DATE '2011-05-05', 14, 'DEPT04', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS006', 'Noha', 'Shawky', 'Female', '01123450006', 'Mobile', 'noha.shawky6@hms.org', 'Afternoon', DATE '2010-06-06', 15, 'DEPT05', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS007', 'Yasmine', 'Lotfy', 'Female', '01223450007', 'Mobile', 'yasmine.lotfy7@hms.org', 'Night', DATE '2009-07-07', 16, 'DEPT06', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS008', 'Mai', 'Sabry', 'Female', '01523450008', 'Mobile', 'mai.sabry8@hms.org', 'Rotating', DATE '2008-08-08', 17, 'DEPT07', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS009', 'Rana', 'Helmy', 'Female', '01023450009', 'Mobile', 'rana.helmy9@hms.org', 'Morning', DATE '2015-09-09', 10, 'DEPT08', NULL);
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS010', 'Eman', 'Khattab', 'Female', '0227953010', 'Landline', 'eman.khattab10@hms.org', 'Afternoon', DATE '2024-10-10', 1, 'DEPT01', 'NRS002');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS011', 'Hagar', 'Metwally', 'Female', '01223450011', 'Mobile', 'hagar.metwally11@hms.org', 'Night', DATE '2023-11-11', 2, 'DEPT01', 'NRS002');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS012', 'Shaimaa', 'Badr', 'Female', '01523450012', 'Mobile', 'shaimaa.badr12@hms.org', 'Rotating', DATE '2022-12-12', 3, 'DEPT01', 'NRS002');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS013', 'Amira', 'Gad', 'Female', '01023450013', 'Mobile', 'amira.gad13@hms.org', 'Morning', DATE '2021-01-13', 4, 'DEPT02', 'NRS003');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS014', 'Nesma', 'Wagdy', 'Female', '01123450014', 'Mobile', 'nesma.wagdy14@hms.org', 'Afternoon', DATE '2020-02-14', 5, 'DEPT02', 'NRS003');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS015', 'Basma', 'Galal', 'Female', '01223450015', 'Mobile', 'basma.galal15@hms.org', 'Night', DATE '2019-03-15', 6, 'DEPT02', 'NRS003');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS016', 'Doaa', 'Shaker', 'Female', '01523450016', 'Mobile', 'doaa.shaker16@hms.org', 'Rotating', DATE '2018-04-16', 7, 'DEPT02', 'NRS003');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS017', 'Marwa', 'Reda', 'Female', '01023450017', 'Mobile', 'marwa.reda17@hms.org', 'Morning', DATE '2017-05-17', 8, 'DEPT03', 'NRS004');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS018', 'Nermine', 'Samy', 'Female', '01123450018', 'Mobile', 'nermine.samy18@hms.org', 'Afternoon', DATE '2016-06-18', 9, 'DEPT03', 'NRS004');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS019', 'Samar', 'Roushdy', 'Female', '0227953019', 'Landline', 'samar.roushdy19@hms.org', 'Night', DATE '2024-07-19', 1, 'DEPT03', 'NRS004');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS020', 'Esraa', 'Mourad', 'Female', '01523450020', 'Mobile', 'esraa.mourad20@hms.org', 'Rotating', DATE '2023-08-20', 2, 'DEPT04', 'NRS005');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS021', 'Mostafa', 'Hegazy', 'Male', '01023450021', 'Mobile', 'mostafa.hegazy21@hms.org', 'Morning', DATE '2022-09-21', 3, 'DEPT04', 'NRS005');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS022', 'Mohamed', 'Refaat', 'Male', '01123450022', 'Mobile', 'mohamed.refaat22@hms.org', 'Afternoon', DATE '2021-10-22', 4, 'DEPT04', 'NRS005');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS023', 'Ali', 'Nassar', 'Male', '01223450023', 'Mobile', 'ali.nassar23@hms.org', 'Night', DATE '2020-11-23', 5, 'DEPT05', 'NRS006');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS024', 'Islam', 'Barakat', 'Male', '01523450024', 'Mobile', 'islam.barakat24@hms.org', 'Rotating', DATE '2019-12-24', 6, 'DEPT05', 'NRS006');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS025', 'Mahmoud', 'Awny', 'Male', '01023450025', 'Mobile', 'mahmoud.awny25@hms.org', 'Morning', DATE '2018-01-25', 7, 'DEPT06', 'NRS007');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS026', 'Hossam', 'Diab', 'Male', '01123450026', 'Mobile', 'hossam.diab26@hms.org', 'Afternoon', DATE '2017-02-01', 8, 'DEPT06', 'NRS007');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS027', 'Ramy', 'Shafik', 'Male', '01223450027', 'Mobile', 'ramy.shafik27@hms.org', 'Night', DATE '2016-03-02', 9, 'DEPT07', 'NRS008');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS028', 'Ehab', 'Gaber', 'Male', '0227953028', 'Landline', 'ehab.gaber28@hms.org', 'Rotating', DATE '2024-04-03', 1, 'DEPT07', 'NRS008');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS029', 'Tamer', 'Foad', 'Male', '01023450029', 'Mobile', 'tamer.foad29@hms.org', 'Morning', DATE '2023-05-04', 2, 'DEPT08', 'NRS009');
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID) VALUES ('NRS030', 'Walid', 'Sobhy', 'Male', '01123450030', 'Mobile', 'walid.sobhy30@hms.org', 'Afternoon', DATE '2022-06-05', 3, 'DEPT08', 'NRS009');

COMMIT;

-- ----------------------------------------------------------------------------
-- STUDENT 2: Patient & Admission Management Seeds
-- ----------------------------------------------------------------------------

-- Source: scripts/02_seeds/student2_patient_admission/insert_patient.sql
-- SEED DATA: Patient (Student 2) - 100 rows
-- Row 1 omits PhoneType to exercise DEFAULT ('Mobile').

INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT001', 'Ahmed', 'Mansour', DATE '1948-01-01', 'Male', 'A+', '01055550001', 'ahmed.mansour.001@mail.eg', NULL, 'Tahrir Street', 'Cairo', '11511', '01288880001');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT002', 'Fatma', 'Zaki', DATE '1955-02-02', 'Female', 'A-', '01155550002', 'Mobile', 'fatma.zaki.002@mail.eg', '13', 'El-Haram Avenue', 'Giza', '12511', '01588880002');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT003', 'Mohamed', 'Barakat', DATE '1962-03-03', 'Male', 'B+', '01255550003', 'Mobile', 'mohamed.barakat.003@mail.eg', '16', 'Corniche El-Nil', 'Alexandria', '21500', '01088880003');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT004', 'Aya', 'Khattab', DATE '1969-04-04', 'Female', 'B-', '01555550004', 'Mobile', 'aya.khattab.004@mail.eg', '19', 'Abbas El-Akkad Street', 'Mansoura', '35511', '01188880004');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT005', 'Mahmoud', 'Kamel', DATE '1976-05-05', 'Male', 'AB+', '01055550005', 'Mobile', 'mahmoud.kamel.005@mail.eg', '22', 'Makram Ebeid Street', 'Tanta', '31511', '01288880005');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT006', 'Mariam', 'Yassin', DATE '1983-06-06', 'Female', 'AB-', '01155550006', 'Mobile', 'mariam.yassin.006@mail.eg', '25', 'Salah Salem Road', 'Aswan', '81511', '01588880006');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT007', 'Youssef', 'Fawzy', DATE '1990-07-07', 'Male', 'O+', '01255550007', 'Mobile', 'youssef.fawzy.007@mail.eg', '28', 'El-Thawra Street', 'Luxor', '85951', '01088880007');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT008', 'Sara', 'Ibrahim', DATE '1997-08-08', 'Female', 'O-', '01555550008', 'Mobile', 'sara.ibrahim.008@mail.eg', NULL, 'Pyramids Road', 'Port Said', '42511', '01188880008');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT009', 'Omar', 'Saeed', DATE '2004-09-09', 'Male', 'A+', '01055550009', 'Mobile', 'omar.saeed.009@mail.eg', '34', 'Gameat El-Dewal Street', 'Suez', '43511', '01288880009');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT010', 'Nour', 'Nassar', DATE '2011-10-10', 'Female', 'A-', '01155550010', 'Mobile', 'nour.nassar.010@mail.eg', '37', 'El-Horreya Road', 'Ismailia', '41511', '01588880010');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT011', 'Khaled', 'Helmy', DATE '1950-11-11', 'Male', 'B+', '0235550011', 'Landline', 'khaled.helmy.011@mail.eg', '40', 'Port Said Street', 'Cairo', '11511', '01088880011');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT012', 'Salma', 'Farouk', DATE '1957-12-12', 'Female', 'B-', '01555550012', 'Mobile', 'salma.farouk.012@mail.eg', '43', 'El-Gomhoreya Street', 'Giza', '12511', '01188880012');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT013', 'Tarek', 'Soliman', DATE '1964-01-13', 'Male', 'AB+', '01055550013', 'Mobile', 'tarek.soliman.013@mail.eg', '46', 'Al-Ahram Street', 'Alexandria', '21500', '01288880013');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT014', 'Hana', 'Gaber', DATE '1971-02-14', 'Female', 'AB-', '01155550014', 'Mobile', 'hana.gaber.014@mail.eg', '49', 'El-Nozha Street', 'Mansoura', '35511', '01588880014');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT015', 'Hassan', 'Hassan', DATE '1978-03-15', 'Male', 'O+', '01255550015', 'Mobile', 'hassan.hassan.015@mail.eg', NULL, 'Moustafa El-Nahas Street', 'Tanta', '31511', '01088880015');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT016', 'Mona', 'Mostafa', DATE '1985-04-16', 'Female', 'O-', '01555550016', 'Mobile', 'mona.mostafa.016@mail.eg', '55', 'Tahrir Street', 'Aswan', '81511', '01188880016');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT017', 'Ali', 'Refaat', DATE '1992-05-17', 'Male', 'A+', '01055550017', 'Mobile', 'ali.refaat.017@mail.eg', '58', 'El-Haram Avenue', 'Luxor', '85951', '01288880017');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT018', 'Heba', 'Lotfy', DATE '1999-06-18', 'Female', 'A-', '01155550018', 'Mobile', 'heba.lotfy.018@mail.eg', '61', 'Corniche El-Nil', 'Port Said', '42511', '01588880018');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT019', 'Mostafa', 'Abdelaziz', DATE '2006-07-19', 'Male', 'B+', '01255550019', 'Mobile', 'mostafa.abdelaziz.019@mail.eg', '64', 'Abbas El-Akkad Street', 'Suez', '43511', '01088880019');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT020', 'Dalia', 'Tawfik', DATE '2013-08-20', 'Female', 'B-', '01555550020', 'Mobile', 'dalia.tawfik.020@mail.eg', '67', 'Makram Ebeid Street', 'Ismailia', '41511', '01188880020');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT021', 'Ibrahim', 'Diab', DATE '1952-09-21', 'Male', 'AB+', '0235550021', 'Landline', 'ibrahim.diab.021@mail.eg', '70', 'Salah Salem Road', 'Cairo', '11511', '01288880021');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT022', 'Rania', 'El-Masry', DATE '1959-10-22', 'Female', 'AB-', '01155550022', 'Mobile', 'rania.elmasry.022@mail.eg', NULL, 'El-Thawra Street', 'Giza', '12511', '01588880022');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT023', 'Karim', 'Nabil', DATE '1966-11-23', 'Male', 'O+', '01255550023', 'Mobile', 'karim.nabil.023@mail.eg', '76', 'Pyramids Road', 'Alexandria', '21500', '01088880023');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT024', 'Nadia', 'Hegazy', DATE '1973-12-24', 'Female', 'O-', '01555550024', 'Mobile', 'nadia.hegazy.024@mail.eg', '79', 'Gameat El-Dewal Street', 'Mansoura', '35511', '01188880024');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT025', 'Sherif', 'Shawky', DATE '1980-01-25', 'Male', 'A+', '01055550025', 'Mobile', 'sherif.shawky.025@mail.eg', '82', 'El-Horreya Road', 'Tanta', '31511', '01288880025');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT026', 'Laila', 'Mansour', DATE '1987-02-26', 'Female', 'A-', '01155550026', 'Mobile', 'laila.mansour.026@mail.eg', '85', 'Port Said Street', 'Aswan', '81511', '01588880026');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT027', 'Amr', 'Zaki', DATE '1994-03-27', 'Male', 'B+', '01255550027', 'Mobile', 'amr.zaki.027@mail.eg', '88', 'El-Gomhoreya Street', 'Luxor', '85951', '01088880027');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT028', 'Farah', 'Barakat', DATE '2001-04-01', 'Female', 'B-', '01555550028', 'Mobile', 'farah.barakat.028@mail.eg', '91', 'Al-Ahram Street', 'Port Said', '42511', '01188880028');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT029', 'Wael', 'Khattab', DATE '2008-05-02', 'Male', 'AB+', '01055550029', 'Mobile', 'wael.khattab.029@mail.eg', NULL, 'El-Nozha Street', 'Suez', '43511', '01288880029');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT030', 'Yasmine', 'Kamel', DATE '2015-06-03', 'Female', 'AB-', '01155550030', 'Mobile', 'yasmine.kamel.030@mail.eg', '97', 'Moustafa El-Nahas Street', 'Ismailia', '41511', '01588880030');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT031', 'Hossam', 'Yassin', DATE '1954-07-04', 'Male', 'O+', '0235550031', 'Landline', 'hossam.yassin.031@mail.eg', '100', 'Tahrir Street', 'Cairo', '11511', '01088880031');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT032', 'Reem', 'Fawzy', DATE '1961-08-05', 'Female', 'O-', '01555550032', 'Mobile', 'reem.fawzy.032@mail.eg', '103', 'El-Haram Avenue', 'Giza', '12511', '01188880032');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT033', 'Ramy', 'Ibrahim', DATE '1968-09-06', 'Male', 'A+', '01055550033', 'Mobile', 'ramy.ibrahim.033@mail.eg', '106', 'Corniche El-Nil', 'Alexandria', '21500', '01288880033');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT034', 'Dina', 'Saeed', DATE '1975-10-07', 'Female', 'A-', '01155550034', 'Mobile', 'dina.saeed.034@mail.eg', '109', 'Abbas El-Akkad Street', 'Mansoura', '35511', '01588880034');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT035', 'Tamer', 'Nassar', DATE '1982-11-08', 'Male', 'B+', '01255550035', 'Mobile', 'tamer.nassar.035@mail.eg', '112', 'Makram Ebeid Street', 'Tanta', '31511', '01088880035');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT036', 'Noha', 'Helmy', DATE '1989-12-09', 'Female', 'B-', '01555550036', 'Mobile', 'noha.helmy.036@mail.eg', NULL, 'Salah Salem Road', 'Aswan', '81511', '01188880036');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT037', 'Walid', 'Farouk', DATE '1996-01-10', 'Male', 'AB+', '01055550037', 'Mobile', 'walid.farouk.037@mail.eg', '118', 'El-Thawra Street', 'Luxor', '85951', '01288880037');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT038', 'Amira', 'Soliman', DATE '2003-02-11', 'Female', 'AB-', '01155550038', 'Mobile', 'amira.soliman.038@mail.eg', '121', 'Pyramids Road', 'Port Said', '42511', '01588880038');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT039', 'Ashraf', 'Gaber', DATE '2010-03-12', 'Male', 'O+', '01255550039', 'Mobile', 'ashraf.gaber.039@mail.eg', '124', 'Gameat El-Dewal Street', 'Suez', '43511', '01088880039');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT040', 'Eman', 'Hassan', DATE '1949-04-13', 'Female', 'O-', '01555550040', 'Mobile', 'eman.hassan.040@mail.eg', '127', 'El-Horreya Road', 'Ismailia', '41511', '01188880040');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT041', 'Sameh', 'Mostafa', DATE '1956-05-14', 'Male', 'A+', '0235550041', 'Landline', 'sameh.mostafa.041@mail.eg', '130', 'Port Said Street', 'Cairo', '11511', '01288880041');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT042', 'Hagar', 'Refaat', DATE '1963-06-15', 'Female', 'A-', '01155550042', 'Mobile', 'hagar.refaat.042@mail.eg', '133', 'El-Gomhoreya Street', 'Giza', '12511', '01588880042');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT043', 'Nabil', 'Lotfy', DATE '1970-07-16', 'Male', 'B+', '01255550043', 'Mobile', 'nabil.lotfy.043@mail.eg', NULL, 'Al-Ahram Street', 'Alexandria', '21500', '01088880043');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT044', 'Marwa', 'Abdelaziz', DATE '1977-08-17', 'Female', 'B-', '01555550044', 'Mobile', 'marwa.abdelaziz.044@mail.eg', '139', 'El-Nozha Street', 'Mansoura', '35511', '01188880044');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT045', 'Gamal', 'Tawfik', DATE '1984-09-18', 'Male', 'AB+', '01055550045', 'Mobile', 'gamal.tawfik.045@mail.eg', '142', 'Moustafa El-Nahas Street', 'Tanta', '31511', '01288880045');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT046', 'Esraa', 'Diab', DATE '1991-10-19', 'Female', 'AB-', '01155550046', 'Mobile', 'esraa.diab.046@mail.eg', '145', 'Tahrir Street', 'Aswan', '81511', '01588880046');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT047', 'Adel', 'El-Masry', DATE '1998-11-20', 'Male', 'O+', '01255550047', 'Mobile', 'adel.elmasry.047@mail.eg', '148', 'El-Haram Avenue', 'Luxor', '85951', '01088880047');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT048', 'Basma', 'Nabil', DATE '2005-12-21', 'Female', 'O-', '01555550048', 'Mobile', 'basma.nabil.048@mail.eg', '151', 'Corniche El-Nil', 'Port Said', '42511', '01188880048');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT049', 'Hany', 'Hegazy', DATE '2012-01-22', 'Male', 'A+', '01055550049', 'Mobile', 'hany.hegazy.049@mail.eg', '154', 'Abbas El-Akkad Street', 'Suez', '43511', '01288880049');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT050', 'Samar', 'Shawky', DATE '1951-02-23', 'Female', 'A-', '01155550050', 'Mobile', 'samar.shawky.050@mail.eg', NULL, 'Makram Ebeid Street', 'Ismailia', '41511', '01588880050');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT051', 'Ahmed', 'Mansour', DATE '1958-03-24', 'Male', 'B+', '0235550051', 'Landline', 'ahmed.mansour.051@mail.eg', '160', 'Salah Salem Road', 'Cairo', '11511', '01088880051');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT052', 'Fatma', 'Zaki', DATE '1965-04-25', 'Female', 'B-', '01555550052', 'Mobile', 'fatma.zaki.052@mail.eg', '163', 'El-Thawra Street', 'Giza', '12511', '01188880052');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT053', 'Mohamed', 'Barakat', DATE '1972-05-26', 'Male', 'AB+', '01055550053', 'Mobile', 'mohamed.barakat.053@mail.eg', '166', 'Pyramids Road', 'Alexandria', '21500', '01288880053');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT054', 'Aya', 'Khattab', DATE '1979-06-27', 'Female', 'AB-', '01155550054', 'Mobile', 'aya.khattab.054@mail.eg', '169', 'Gameat El-Dewal Street', 'Mansoura', '35511', '01588880054');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT055', 'Mahmoud', 'Kamel', DATE '1986-07-01', 'Male', 'O+', '01255550055', 'Mobile', 'mahmoud.kamel.055@mail.eg', '172', 'El-Horreya Road', 'Tanta', '31511', '01088880055');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT056', 'Mariam', 'Yassin', DATE '1993-08-02', 'Female', 'O-', '01555550056', 'Mobile', 'mariam.yassin.056@mail.eg', '175', 'Port Said Street', 'Aswan', '81511', '01188880056');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT057', 'Youssef', 'Fawzy', DATE '2000-09-03', 'Male', 'A+', '01055550057', 'Mobile', 'youssef.fawzy.057@mail.eg', NULL, 'El-Gomhoreya Street', 'Luxor', '85951', '01288880057');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT058', 'Sara', 'Ibrahim', DATE '2007-10-04', 'Female', 'A-', '01155550058', 'Mobile', 'sara.ibrahim.058@mail.eg', '181', 'Al-Ahram Street', 'Port Said', '42511', '01588880058');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT059', 'Omar', 'Saeed', DATE '2014-11-05', 'Male', 'B+', '01255550059', 'Mobile', 'omar.saeed.059@mail.eg', '184', 'El-Nozha Street', 'Suez', '43511', '01088880059');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT060', 'Nour', 'Nassar', DATE '1953-12-06', 'Female', 'B-', '01555550060', 'Mobile', 'nour.nassar.060@mail.eg', '187', 'Moustafa El-Nahas Street', 'Ismailia', '41511', '01188880060');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT061', 'Khaled', 'Helmy', DATE '1960-01-07', 'Male', 'AB+', '0235550061', 'Landline', 'khaled.helmy.061@mail.eg', '190', 'Tahrir Street', 'Cairo', '11511', '01288880061');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT062', 'Salma', 'Farouk', DATE '1967-02-08', 'Female', 'AB-', '01155550062', 'Mobile', 'salma.farouk.062@mail.eg', '193', 'El-Haram Avenue', 'Giza', '12511', '01588880062');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT063', 'Tarek', 'Soliman', DATE '1974-03-09', 'Male', 'O+', '01255550063', 'Mobile', 'tarek.soliman.063@mail.eg', '196', 'Corniche El-Nil', 'Alexandria', '21500', '01088880063');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT064', 'Hana', 'Gaber', DATE '1981-04-10', 'Female', 'O-', '01555550064', 'Mobile', 'hana.gaber.064@mail.eg', NULL, 'Abbas El-Akkad Street', 'Mansoura', '35511', '01188880064');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT065', 'Hassan', 'Hassan', DATE '1988-05-11', 'Male', 'A+', '01055550065', 'Mobile', 'hassan.hassan.065@mail.eg', '12', 'Makram Ebeid Street', 'Tanta', '31511', '01288880065');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT066', 'Mona', 'Mostafa', DATE '1995-06-12', 'Female', 'A-', '01155550066', 'Mobile', 'mona.mostafa.066@mail.eg', '15', 'Salah Salem Road', 'Aswan', '81511', '01588880066');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT067', 'Ali', 'Refaat', DATE '2002-07-13', 'Male', 'B+', '01255550067', 'Mobile', 'ali.refaat.067@mail.eg', '18', 'El-Thawra Street', 'Luxor', '85951', '01088880067');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT068', 'Heba', 'Lotfy', DATE '2009-08-14', 'Female', 'B-', '01555550068', 'Mobile', 'heba.lotfy.068@mail.eg', '21', 'Pyramids Road', 'Port Said', '42511', '01188880068');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT069', 'Mostafa', 'Abdelaziz', DATE '1948-09-15', 'Male', 'AB+', '01055550069', 'Mobile', 'mostafa.abdelaziz.069@mail.eg', '24', 'Gameat El-Dewal Street', 'Suez', '43511', '01288880069');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT070', 'Dalia', 'Tawfik', DATE '1955-10-16', 'Female', 'AB-', '01155550070', 'Mobile', 'dalia.tawfik.070@mail.eg', '27', 'El-Horreya Road', 'Ismailia', '41511', '01588880070');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT071', 'Ibrahim', 'Diab', DATE '1962-11-17', 'Male', 'O+', '0235550071', 'Landline', 'ibrahim.diab.071@mail.eg', NULL, 'Port Said Street', 'Cairo', '11511', '01088880071');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT072', 'Rania', 'El-Masry', DATE '1969-12-18', 'Female', 'O-', '01555550072', 'Mobile', 'rania.elmasry.072@mail.eg', '33', 'El-Gomhoreya Street', 'Giza', '12511', '01188880072');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT073', 'Karim', 'Nabil', DATE '1976-01-19', 'Male', 'A+', '01055550073', 'Mobile', 'karim.nabil.073@mail.eg', '36', 'Al-Ahram Street', 'Alexandria', '21500', '01288880073');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT074', 'Nadia', 'Hegazy', DATE '1983-02-20', 'Female', 'A-', '01155550074', 'Mobile', 'nadia.hegazy.074@mail.eg', '39', 'El-Nozha Street', 'Mansoura', '35511', '01588880074');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT075', 'Sherif', 'Shawky', DATE '1990-03-21', 'Male', 'B+', '01255550075', 'Mobile', 'sherif.shawky.075@mail.eg', '42', 'Moustafa El-Nahas Street', 'Tanta', '31511', '01088880075');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT076', 'Laila', 'Mansour', DATE '1997-04-22', 'Female', 'B-', '01555550076', 'Mobile', 'laila.mansour.076@mail.eg', '45', 'Tahrir Street', 'Aswan', '81511', '01188880076');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT077', 'Amr', 'Zaki', DATE '2004-05-23', 'Male', 'AB+', '01055550077', 'Mobile', 'amr.zaki.077@mail.eg', '48', 'El-Haram Avenue', 'Luxor', '85951', '01288880077');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT078', 'Farah', 'Barakat', DATE '2011-06-24', 'Female', 'AB-', '01155550078', 'Mobile', 'farah.barakat.078@mail.eg', NULL, 'Corniche El-Nil', 'Port Said', '42511', '01588880078');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT079', 'Wael', 'Khattab', DATE '1950-07-25', 'Male', 'O+', '01255550079', 'Mobile', 'wael.khattab.079@mail.eg', '54', 'Abbas El-Akkad Street', 'Suez', '43511', '01088880079');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT080', 'Yasmine', 'Kamel', DATE '1957-08-26', 'Female', 'O-', '01555550080', 'Mobile', 'yasmine.kamel.080@mail.eg', '57', 'Makram Ebeid Street', 'Ismailia', '41511', '01188880080');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT081', 'Hossam', 'Yassin', DATE '1964-09-27', 'Male', 'A+', '0235550081', 'Landline', 'hossam.yassin.081@mail.eg', '60', 'Salah Salem Road', 'Cairo', '11511', '01288880081');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT082', 'Reem', 'Fawzy', DATE '1971-10-01', 'Female', 'A-', '01155550082', 'Mobile', 'reem.fawzy.082@mail.eg', '63', 'El-Thawra Street', 'Giza', '12511', '01588880082');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT083', 'Ramy', 'Ibrahim', DATE '1978-11-02', 'Male', 'B+', '01255550083', 'Mobile', 'ramy.ibrahim.083@mail.eg', '66', 'Pyramids Road', 'Alexandria', '21500', '01088880083');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT084', 'Dina', 'Saeed', DATE '1985-12-03', 'Female', 'B-', '01555550084', 'Mobile', 'dina.saeed.084@mail.eg', '69', 'Gameat El-Dewal Street', 'Mansoura', '35511', '01188880084');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT085', 'Tamer', 'Nassar', DATE '1992-01-04', 'Male', 'AB+', '01055550085', 'Mobile', 'tamer.nassar.085@mail.eg', NULL, 'El-Horreya Road', 'Tanta', '31511', '01288880085');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT086', 'Noha', 'Helmy', DATE '1999-02-05', 'Female', 'AB-', '01155550086', 'Mobile', 'noha.helmy.086@mail.eg', '75', 'Port Said Street', 'Aswan', '81511', '01588880086');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT087', 'Walid', 'Farouk', DATE '2006-03-06', 'Male', 'O+', '01255550087', 'Mobile', 'walid.farouk.087@mail.eg', '78', 'El-Gomhoreya Street', 'Luxor', '85951', '01088880087');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT088', 'Amira', 'Soliman', DATE '2013-04-07', 'Female', 'O-', '01555550088', 'Mobile', 'amira.soliman.088@mail.eg', '81', 'Al-Ahram Street', 'Port Said', '42511', '01188880088');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT089', 'Ashraf', 'Gaber', DATE '1952-05-08', 'Male', 'A+', '01055550089', 'Mobile', 'ashraf.gaber.089@mail.eg', '84', 'El-Nozha Street', 'Suez', '43511', '01288880089');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT090', 'Eman', 'Hassan', DATE '1959-06-09', 'Female', 'A-', '01155550090', 'Mobile', 'eman.hassan.090@mail.eg', '87', 'Moustafa El-Nahas Street', 'Ismailia', '41511', '01588880090');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT091', 'Sameh', 'Mostafa', DATE '1966-07-10', 'Male', 'B+', '0235550091', 'Landline', 'sameh.mostafa.091@mail.eg', '90', 'Tahrir Street', 'Cairo', '11511', '01088880091');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT092', 'Hagar', 'Refaat', DATE '1973-08-11', 'Female', 'B-', '01555550092', 'Mobile', 'hagar.refaat.092@mail.eg', NULL, 'El-Haram Avenue', 'Giza', '12511', '01188880092');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT093', 'Nabil', 'Lotfy', DATE '1980-09-12', 'Male', 'AB+', '01055550093', 'Mobile', 'nabil.lotfy.093@mail.eg', '96', 'Corniche El-Nil', 'Alexandria', '21500', '01288880093');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT094', 'Marwa', 'Abdelaziz', DATE '1987-10-13', 'Female', 'AB-', '01155550094', 'Mobile', 'marwa.abdelaziz.094@mail.eg', '99', 'Abbas El-Akkad Street', 'Mansoura', '35511', '01588880094');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT095', 'Gamal', 'Tawfik', DATE '1994-11-14', 'Male', 'O+', '01255550095', 'Mobile', 'gamal.tawfik.095@mail.eg', '102', 'Makram Ebeid Street', 'Tanta', '31511', '01088880095');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT096', 'Esraa', 'Diab', DATE '2001-12-15', 'Female', 'O-', '01555550096', 'Mobile', 'esraa.diab.096@mail.eg', '105', 'Salah Salem Road', 'Aswan', '81511', '01188880096');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT097', 'Adel', 'El-Masry', DATE '2008-01-16', 'Male', 'A+', '01055550097', 'Mobile', 'adel.elmasry.097@mail.eg', '108', 'El-Thawra Street', 'Luxor', '85951', '01288880097');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT098', 'Basma', 'Nabil', DATE '2015-02-17', 'Female', 'A-', '01155550098', 'Mobile', 'basma.nabil.098@mail.eg', '111', 'Pyramids Road', 'Port Said', '42511', '01588880098');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT099', 'Hany', 'Hegazy', DATE '1954-03-18', 'Male', 'B+', '01255550099', 'Mobile', 'hany.hegazy.099@mail.eg', NULL, 'Gameat El-Dewal Street', 'Suez', '43511', '01088880099');
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact) VALUES ('PAT100', 'Samar', 'Shawky', DATE '1961-04-19', 'Female', 'B-', '01555550100', 'Mobile', 'samar.shawky.100@mail.eg', '117', 'El-Horreya Road', 'Ismailia', '41511', '01188880100');

COMMIT;

-- Source: scripts/02_seeds/student2_patient_admission/insert_room.sql
-- SEED DATA: Room (Student 2) - 50 rows
-- Row 1 omits Capacity (1) and AvailabilityStatus ('Available') to exercise DEFAULTS.

INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge) VALUES ('RM001', '101', 'Building A', 'Ground Floor', 'Private', 1800.00);
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM002', '102', 'Building B', 'Ground Floor', 'Semi-Private', 2, 1150.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM003', '103', 'Building C', 'Ground Floor', 'General Ward', 4, 550.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM004', '104', 'Building D', 'Ground Floor', 'ICU', 1, 4650.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM005', '205', 'Building A', '1st Floor', 'Isolation', 1, 2800.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM006', '206', 'Building B', '1st Floor', 'Emergency', 2, 950.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM007', '207', 'Building C', '1st Floor', 'Maternity', 2, 1650.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM008', '208', 'Building D', '1st Floor', 'Pediatric', 3, 950.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM009', '309', 'Building A', '2nd Floor', 'Operating Room', 1, 6150.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM010', '310', 'Building B', '2nd Floor', 'Private', 1, 2000.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM011', '311', 'Building C', '2nd Floor', 'Semi-Private', 2, 1100.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM012', '312', 'Building D', '2nd Floor', 'General Ward', 4, 500.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM013', '413', 'Building A', '3rd Floor', 'ICU', 1, 4600.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM014', '414', 'Building B', '3rd Floor', 'Isolation', 1, 2750.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM015', '415', 'Building C', '3rd Floor', 'Emergency', 2, 1150.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM016', '416', 'Building D', '3rd Floor', 'Maternity', 2, 1600.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM017', '517', 'Building A', '4th Floor', 'Pediatric', 3, 900.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM018', '518', 'Building B', '4th Floor', 'Operating Room', 1, 6100.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM019', '519', 'Building C', '4th Floor', 'Private', 1, 1950.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM020', '520', 'Building D', '4th Floor', 'Semi-Private', 2, 1300.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM021', '621', 'Building A', '5th Floor', 'General Ward', 4, 450.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM022', '622', 'Building B', '5th Floor', 'ICU', 1, 4550.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM023', '623', 'Building C', '5th Floor', 'Isolation', 1, 2700.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM024', '624', 'Building D', '5th Floor', 'Emergency', 2, 1100.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM025', '125', 'Building A', 'Ground Floor', 'Maternity', 2, 1800.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM026', '126', 'Building B', 'Ground Floor', 'Pediatric', 3, 850.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM027', '127', 'Building C', 'Ground Floor', 'Operating Room', 1, 6050.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM028', '128', 'Building D', 'Ground Floor', 'Private', 1, 1900.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM029', '229', 'Building A', '1st Floor', 'Semi-Private', 2, 1250.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM030', '230', 'Building B', '1st Floor', 'General Ward', 4, 650.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM031', '231', 'Building C', '1st Floor', 'ICU', 1, 4500.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM032', '232', 'Building D', '1st Floor', 'Isolation', 1, 2650.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM033', '333', 'Building A', '2nd Floor', 'Emergency', 2, 1050.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM034', '334', 'Building B', '2nd Floor', 'Maternity', 2, 1750.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM035', '335', 'Building C', '2nd Floor', 'Pediatric', 3, 1050.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM036', '336', 'Building D', '2nd Floor', 'Operating Room', 1, 6000.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM037', '437', 'Building A', '3rd Floor', 'Private', 1, 1850.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM038', '438', 'Building B', '3rd Floor', 'Semi-Private', 2, 1200.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM039', '439', 'Building C', '3rd Floor', 'General Ward', 4, 600.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM040', '440', 'Building D', '3rd Floor', 'ICU', 1, 4700.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM041', '541', 'Building A', '4th Floor', 'Isolation', 1, 2600.00, 'Maintenance');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM042', '542', 'Building B', '4th Floor', 'Emergency', 2, 1000.00, 'Maintenance');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM043', '543', 'Building C', '4th Floor', 'Maternity', 2, 1700.00, 'Maintenance');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM044', '544', 'Building D', '4th Floor', 'Pediatric', 3, 1000.00, 'Maintenance');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM045', '645', 'Building A', '5th Floor', 'Operating Room', 1, 6200.00, 'Reserved');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM046', '646', 'Building B', '5th Floor', 'Private', 1, 1800.00, 'Reserved');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM047', '647', 'Building C', '5th Floor', 'Semi-Private', 2, 1150.00, 'Reserved');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM048', '648', 'Building D', '5th Floor', 'General Ward', 4, 550.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM049', '149', 'Building A', 'Ground Floor', 'ICU', 1, 4650.00, 'Available');
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus) VALUES ('RM050', '150', 'Building B', 'Ground Floor', 'Isolation', 1, 2800.00, 'Available');

COMMIT;

-- Source: scripts/02_seeds/student2_patient_admission/insert_admission.sql
-- SEED DATA: Admission (Student 2) - 150 rows
-- Row 1 omits AdmissionDate (SYSDATE), DischargeDate (NULL), and AdmissionStatus ('Admitted') to exercise DEFAULTS.

INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason) VALUES ('ADM001', 'PAT001', 'RM001', 'Acute chest pain evaluation and cardiac telemetry monitoring');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM002', 'PAT002', 'RM002', TRUNC(SYSDATE) - 2, NULL, 'Severe community-acquired pneumonia requiring IV antibiotics', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM003', 'PAT003', 'RM002', TRUNC(SYSDATE) - 3, NULL, 'Post-operative recovery following orthopedic fracture repair', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM004', 'PAT004', 'RM003', TRUNC(SYSDATE) - 4, NULL, 'Uncontrolled diabetic ketoacidosis stabilization', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM005', 'PAT005', 'RM003', TRUNC(SYSDATE) - 5, NULL, 'Acute appendicitis requiring inpatient surgical care', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM006', 'PAT006', 'RM003', TRUNC(SYSDATE) - 6, NULL, 'Hypertensive crisis management and renal monitoring', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM007', 'PAT007', 'RM003', TRUNC(SYSDATE) - 7, NULL, 'Severe asthma exacerbation requiring nebulization therapy', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM008', 'PAT008', 'RM004', TRUNC(SYSDATE) - 8, NULL, 'Cerebrovascular accident observation and neurology workup', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM009', 'PAT009', 'RM005', TRUNC(SYSDATE) - 9, NULL, 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM010', 'PAT010', 'RM006', TRUNC(SYSDATE) - 10, NULL, 'High-grade fever and sepsis protocol administration', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM011', 'PAT011', 'RM006', TRUNC(SYSDATE) - 1, NULL, 'Post-delivery maternal and neonatal observation', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM012', 'PAT012', 'RM007', TRUNC(SYSDATE) - 2, NULL, 'Acute kidney injury fluid and electrolyte management', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM013', 'PAT013', 'RM007', TRUNC(SYSDATE) - 3, NULL, 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM014', 'PAT014', 'RM008', TRUNC(SYSDATE) - 4, NULL, 'Severe community-acquired pneumonia requiring IV antibiotics', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM015', 'PAT015', 'RM008', TRUNC(SYSDATE) - 5, NULL, 'Post-operative recovery following orthopedic fracture repair', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM016', 'PAT016', 'RM008', TRUNC(SYSDATE) - 6, NULL, 'Uncontrolled diabetic ketoacidosis stabilization', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM017', 'PAT017', 'RM009', TRUNC(SYSDATE) - 7, NULL, 'Acute appendicitis requiring inpatient surgical care', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM018', 'PAT018', 'RM010', TRUNC(SYSDATE) - 8, NULL, 'Hypertensive crisis management and renal monitoring', 'Admitted');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM019', 'PAT049', 'RM019', DATE '2022-06-26', DATE '2022-07-04', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM020', 'PAT060', 'RM020', DATE '2022-07-05', DATE '2022-07-14', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM021', 'PAT071', 'RM021', DATE '2022-07-14', DATE '2022-07-24', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM022', 'PAT007', 'RM022', DATE '2022-07-23', DATE '2022-08-03', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM023', 'PAT018', 'RM023', DATE '2022-08-01', DATE '2022-08-13', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM024', 'PAT029', 'RM024', DATE '2022-08-10', DATE '2022-08-23', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM025', 'PAT040', 'RM025', DATE '2022-08-19', DATE '2022-08-21', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM026', 'PAT051', 'RM026', DATE '2022-08-28', DATE '2022-08-31', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM027', 'PAT062', 'RM027', DATE '2022-09-06', DATE '2022-09-10', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM028', 'PAT073', 'RM028', DATE '2022-09-15', DATE '2022-09-20', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM029', 'PAT009', 'RM029', DATE '2022-09-24', DATE '2022-09-30', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM030', 'PAT020', 'RM030', DATE '2022-10-03', DATE '2022-10-10', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM031', 'PAT031', 'RM031', DATE '2022-10-12', DATE '2022-10-20', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM032', 'PAT042', 'RM032', DATE '2022-10-21', DATE '2022-10-30', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM033', 'PAT053', 'RM033', DATE '2022-10-30', DATE '2022-11-09', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM034', 'PAT064', 'RM034', DATE '2022-11-08', DATE '2022-11-19', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM035', 'PAT075', 'RM035', DATE '2022-11-17', DATE '2022-11-29', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM036', 'PAT011', 'RM036', DATE '2022-11-26', DATE '2022-12-09', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM037', 'PAT022', 'RM037', DATE '2022-12-05', DATE '2022-12-07', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM038', 'PAT033', 'RM038', DATE '2022-12-14', DATE '2022-12-17', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM039', 'PAT044', 'RM039', DATE '2022-12-23', DATE '2022-12-27', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM040', 'PAT055', 'RM040', DATE '2023-01-01', DATE '2023-01-06', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM041', 'PAT066', 'RM001', DATE '2023-01-10', DATE '2023-01-16', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM042', 'PAT002', 'RM002', DATE '2023-01-19', DATE '2023-01-26', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM043', 'PAT013', 'RM003', DATE '2023-01-28', DATE '2023-02-05', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM044', 'PAT024', 'RM004', DATE '2023-02-06', DATE '2023-02-15', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM045', 'PAT035', 'RM005', DATE '2023-02-15', DATE '2023-02-25', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM046', 'PAT046', 'RM006', DATE '2023-02-24', DATE '2023-03-07', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM047', 'PAT057', 'RM007', DATE '2023-03-05', DATE '2023-03-17', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM048', 'PAT068', 'RM008', DATE '2023-03-14', DATE '2023-03-27', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM049', 'PAT004', 'RM009', DATE '2023-03-23', DATE '2023-03-25', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM050', 'PAT015', 'RM010', DATE '2023-04-01', DATE '2023-04-04', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM051', 'PAT026', 'RM011', DATE '2023-04-10', DATE '2023-04-14', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM052', 'PAT037', 'RM012', DATE '2023-04-19', DATE '2023-04-24', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM053', 'PAT048', 'RM013', DATE '2023-04-28', DATE '2023-05-04', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM054', 'PAT059', 'RM014', DATE '2023-05-07', DATE '2023-05-14', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM055', 'PAT070', 'RM015', DATE '2023-05-16', DATE '2023-05-24', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM056', 'PAT006', 'RM016', DATE '2023-05-25', DATE '2023-06-03', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM057', 'PAT017', 'RM017', DATE '2023-06-03', DATE '2023-06-13', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM058', 'PAT028', 'RM018', DATE '2023-06-12', DATE '2023-06-23', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM059', 'PAT039', 'RM019', DATE '2023-06-21', DATE '2023-07-03', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM060', 'PAT050', 'RM020', DATE '2023-06-30', DATE '2023-07-13', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM061', 'PAT061', 'RM021', DATE '2023-07-09', DATE '2023-07-11', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM062', 'PAT072', 'RM022', DATE '2023-07-18', DATE '2023-07-21', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM063', 'PAT008', 'RM023', DATE '2023-07-27', DATE '2023-07-31', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM064', 'PAT019', 'RM024', DATE '2023-08-05', DATE '2023-08-10', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM065', 'PAT030', 'RM025', DATE '2023-08-14', DATE '2023-08-20', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM066', 'PAT041', 'RM026', DATE '2023-08-23', DATE '2023-08-30', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM067', 'PAT052', 'RM027', DATE '2023-09-01', DATE '2023-09-09', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM068', 'PAT063', 'RM028', DATE '2023-09-10', DATE '2023-09-19', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM069', 'PAT074', 'RM029', DATE '2023-09-19', DATE '2023-09-29', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM070', 'PAT010', 'RM030', DATE '2023-09-28', DATE '2023-10-09', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM071', 'PAT021', 'RM031', DATE '2023-10-07', DATE '2023-10-19', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM072', 'PAT032', 'RM032', DATE '2023-10-16', DATE '2023-10-29', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM073', 'PAT043', 'RM033', DATE '2023-10-25', DATE '2023-10-27', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM074', 'PAT054', 'RM034', DATE '2023-11-03', DATE '2023-11-06', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM075', 'PAT065', 'RM035', DATE '2023-11-12', DATE '2023-11-16', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM076', 'PAT001', 'RM036', DATE '2023-11-21', DATE '2023-11-26', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM077', 'PAT012', 'RM037', DATE '2023-11-30', DATE '2023-12-06', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM078', 'PAT023', 'RM038', DATE '2023-12-09', DATE '2023-12-16', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM079', 'PAT034', 'RM039', DATE '2023-12-18', DATE '2023-12-26', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM080', 'PAT045', 'RM040', DATE '2023-12-27', DATE '2024-01-05', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM081', 'PAT056', 'RM001', DATE '2024-01-05', DATE '2024-01-15', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM082', 'PAT067', 'RM002', DATE '2024-01-14', DATE '2024-01-25', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM083', 'PAT003', 'RM003', DATE '2024-01-23', DATE '2024-02-04', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM084', 'PAT014', 'RM004', DATE '2024-02-01', DATE '2024-02-14', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM085', 'PAT025', 'RM005', DATE '2024-02-10', DATE '2024-02-12', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM086', 'PAT036', 'RM006', DATE '2024-02-19', DATE '2024-02-22', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM087', 'PAT047', 'RM007', DATE '2024-02-28', DATE '2024-03-03', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM088', 'PAT058', 'RM008', DATE '2024-03-08', DATE '2024-03-13', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM089', 'PAT069', 'RM009', DATE '2024-03-17', DATE '2024-03-23', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM090', 'PAT005', 'RM010', DATE '2024-03-26', DATE '2024-04-02', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM091', 'PAT016', 'RM011', DATE '2024-04-04', DATE '2024-04-12', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM092', 'PAT027', 'RM012', DATE '2024-04-13', DATE '2024-04-22', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM093', 'PAT038', 'RM013', DATE '2024-04-22', DATE '2024-05-02', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM094', 'PAT049', 'RM014', DATE '2024-05-01', DATE '2024-05-12', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM095', 'PAT060', 'RM015', DATE '2024-05-10', DATE '2024-05-22', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM096', 'PAT071', 'RM016', DATE '2024-05-19', DATE '2024-06-01', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM097', 'PAT007', 'RM017', DATE '2024-05-28', DATE '2024-05-30', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM098', 'PAT018', 'RM018', DATE '2024-06-06', DATE '2024-06-09', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM099', 'PAT029', 'RM019', DATE '2024-06-15', DATE '2024-06-19', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM100', 'PAT040', 'RM020', DATE '2024-06-24', DATE '2024-06-29', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM101', 'PAT051', 'RM021', DATE '2024-07-03', DATE '2024-07-09', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM102', 'PAT062', 'RM022', DATE '2024-07-12', DATE '2024-07-19', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM103', 'PAT073', 'RM023', DATE '2024-07-21', DATE '2024-07-29', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM104', 'PAT009', 'RM024', DATE '2024-07-30', DATE '2024-08-08', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM105', 'PAT020', 'RM025', DATE '2024-08-08', DATE '2024-08-18', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM106', 'PAT031', 'RM026', DATE '2024-08-17', DATE '2024-08-28', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM107', 'PAT042', 'RM027', DATE '2024-08-26', DATE '2024-09-07', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM108', 'PAT053', 'RM028', DATE '2024-09-04', DATE '2024-09-17', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM109', 'PAT064', 'RM029', DATE '2024-09-13', DATE '2024-09-15', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM110', 'PAT075', 'RM030', DATE '2024-09-22', DATE '2024-09-25', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM111', 'PAT011', 'RM031', DATE '2024-10-01', DATE '2024-10-05', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM112', 'PAT022', 'RM032', DATE '2024-10-10', DATE '2024-10-15', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM113', 'PAT033', 'RM033', DATE '2024-10-19', DATE '2024-10-25', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM114', 'PAT044', 'RM034', DATE '2024-10-28', DATE '2024-11-04', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM115', 'PAT055', 'RM035', DATE '2024-11-06', DATE '2024-11-14', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM116', 'PAT066', 'RM036', DATE '2024-11-15', DATE '2024-11-24', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM117', 'PAT002', 'RM037', DATE '2024-11-24', DATE '2024-12-04', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM118', 'PAT013', 'RM038', DATE '2024-12-03', DATE '2024-12-14', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM119', 'PAT024', 'RM039', DATE '2024-12-12', DATE '2024-12-24', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM120', 'PAT035', 'RM040', DATE '2024-12-21', DATE '2025-01-03', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM121', 'PAT046', 'RM001', DATE '2024-12-30', DATE '2025-01-01', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM122', 'PAT057', 'RM002', DATE '2025-01-08', DATE '2025-01-11', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM123', 'PAT068', 'RM003', DATE '2025-01-17', DATE '2025-01-21', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM124', 'PAT004', 'RM004', DATE '2025-01-26', DATE '2025-01-31', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM125', 'PAT015', 'RM005', DATE '2025-02-04', DATE '2025-02-10', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM126', 'PAT026', 'RM006', DATE '2025-02-13', DATE '2025-02-20', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM127', 'PAT037', 'RM007', DATE '2025-02-22', DATE '2025-03-02', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM128', 'PAT048', 'RM008', DATE '2025-03-03', DATE '2025-03-12', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM129', 'PAT059', 'RM009', DATE '2025-03-12', DATE '2025-03-22', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM130', 'PAT070', 'RM010', DATE '2025-03-21', DATE '2025-04-01', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM131', 'PAT006', 'RM011', DATE '2025-03-30', DATE '2025-04-11', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM132', 'PAT017', 'RM012', DATE '2025-04-08', DATE '2025-04-21', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM133', 'PAT028', 'RM013', DATE '2025-04-17', DATE '2025-04-19', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM134', 'PAT039', 'RM014', DATE '2025-04-26', DATE '2025-04-29', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM135', 'PAT050', 'RM015', DATE '2022-01-21', DATE '2022-01-25', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM136', 'PAT061', 'RM016', DATE '2022-01-30', DATE '2022-02-04', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM137', 'PAT072', 'RM017', DATE '2022-02-08', DATE '2022-02-14', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM138', 'PAT008', 'RM018', DATE '2022-02-17', DATE '2022-02-24', 'Hypertensive crisis management and renal monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM139', 'PAT019', 'RM019', DATE '2022-02-26', DATE '2022-03-06', 'Severe asthma exacerbation requiring nebulization therapy', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM140', 'PAT030', 'RM020', DATE '2022-03-07', DATE '2022-03-16', 'Cerebrovascular accident observation and neurology workup', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM141', 'PAT041', 'RM021', DATE '2022-03-16', DATE '2022-03-26', 'Gastrointestinal bleeding stabilization and endoscopy prep', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM142', 'PAT052', 'RM022', DATE '2022-03-25', DATE '2022-04-05', 'High-grade fever and sepsis protocol administration', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM143', 'PAT063', 'RM023', DATE '2022-04-03', DATE '2022-04-15', 'Post-delivery maternal and neonatal observation', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM144', 'PAT074', 'RM024', DATE '2022-04-12', DATE '2022-04-25', 'Acute kidney injury fluid and electrolyte management', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM145', 'PAT010', 'RM025', DATE '2022-04-21', DATE '2022-04-23', 'Acute chest pain evaluation and cardiac telemetry monitoring', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM146', 'PAT021', 'RM026', DATE '2022-04-30', DATE '2022-05-03', 'Severe community-acquired pneumonia requiring IV antibiotics', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM147', 'PAT032', 'RM027', DATE '2022-05-09', DATE '2022-05-13', 'Post-operative recovery following orthopedic fracture repair', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM148', 'PAT043', 'RM028', DATE '2022-05-18', DATE '2022-05-23', 'Uncontrolled diabetic ketoacidosis stabilization', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM149', 'PAT054', 'RM029', DATE '2022-05-27', DATE '2022-06-02', 'Acute appendicitis requiring inpatient surgical care', 'Discharged');
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus) VALUES ('ADM150', 'PAT065', 'RM030', DATE '2022-06-05', DATE '2022-06-12', 'Hypertensive crisis management and renal monitoring', 'Discharged');

COMMIT;

-- ----------------------------------------------------------------------------
-- STUDENT 3: Appointments & Medical Records Seeds
-- ----------------------------------------------------------------------------

-- Source: scripts/02_seeds/student3_appointments_records/insert_appointment.sql
-- SEED DATA: Appointment (Student 3) - 300 rows
-- Row 1 omits AppointmentDate (SYSDATE), Status ('Scheduled'), and Notes (NULL) to exercise DEFAULTS.

INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, Reason) VALUES ('APT001', 'PAT001', 'DOC002', 'Routine cardiology follow-up and blood pressure review');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT002', 'PAT002', 'DOC002', TO_DATE('2024-01-12 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT003', 'PAT003', 'DOC003', TO_DATE('2024-01-14 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT004', 'PAT004', 'DOC004', TRUNC(SYSDATE) + 4 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT005', 'PAT005', 'DOC005', TO_DATE('2024-01-18 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT006', 'PAT006', 'DOC006', TO_DATE('2024-01-20 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT007', 'PAT007', 'DOC007', TO_DATE('2024-01-22 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT008', 'PAT008', 'DOC008', TRUNC(SYSDATE) + 8 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT009', 'PAT009', 'DOC009', TO_DATE('2024-01-26 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT010', 'PAT010', 'DOC002', TO_DATE('2024-01-28 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT011', 'PAT011', 'DOC011', TO_DATE('2024-01-30 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT012', 'PAT012', 'DOC012', TRUNC(SYSDATE) + 12 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT013', 'PAT013', 'DOC013', TO_DATE('2024-02-03 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT014', 'PAT014', 'DOC014', TO_DATE('2024-02-05 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT015', 'PAT015', 'DOC015', TO_DATE('2024-02-07 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT016', 'PAT016', 'DOC016', TRUNC(SYSDATE) + 16 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT017', 'PAT017', 'DOC017', TO_DATE('2024-02-11 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT018', 'PAT018', 'DOC018', TO_DATE('2024-02-13 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT019', 'PAT019', 'DOC002', TO_DATE('2024-02-15 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT020', 'PAT020', 'DOC020', TRUNC(SYSDATE) + 20 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT021', 'PAT021', 'DOC001', TO_DATE('2024-02-19 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT022', 'PAT022', 'DOC002', TO_DATE('2024-02-21 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT023', 'PAT023', 'DOC003', TO_DATE('2024-02-23 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT024', 'PAT024', 'DOC004', TRUNC(SYSDATE) + 24 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT025', 'PAT025', 'DOC005', TO_DATE('2024-02-27 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT026', 'PAT026', 'DOC006', TO_DATE('2024-02-29 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT027', 'PAT027', 'DOC007', TO_DATE('2024-03-02 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT028', 'PAT028', 'DOC002', TRUNC(SYSDATE) + 28 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT029', 'PAT029', 'DOC009', TO_DATE('2024-03-06 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT030', 'PAT030', 'DOC010', TO_DATE('2024-03-08 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT031', 'PAT031', 'DOC011', TO_DATE('2024-03-10 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT032', 'PAT032', 'DOC012', TRUNC(SYSDATE) + 32 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT033', 'PAT033', 'DOC013', TO_DATE('2024-03-14 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT034', 'PAT034', 'DOC014', TO_DATE('2024-03-16 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT035', 'PAT035', 'DOC015', TO_DATE('2024-03-18 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT036', 'PAT036', 'DOC016', TRUNC(SYSDATE) + 36 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT037', 'PAT037', 'DOC002', TO_DATE('2024-03-22 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT038', 'PAT038', 'DOC018', TO_DATE('2024-03-24 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT039', 'PAT039', 'DOC019', TO_DATE('2024-03-26 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT040', 'PAT040', 'DOC020', TRUNC(SYSDATE) + 40 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT041', 'PAT041', 'DOC001', TO_DATE('2024-03-30 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT042', 'PAT042', 'DOC002', TO_DATE('2024-04-01 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT043', 'PAT043', 'DOC003', TO_DATE('2024-04-03 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT044', 'PAT044', 'DOC004', TRUNC(SYSDATE) + 44 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT045', 'PAT045', 'DOC005', TO_DATE('2024-04-07 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT046', 'PAT046', 'DOC002', TO_DATE('2024-04-09 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT047', 'PAT047', 'DOC007', TO_DATE('2024-04-11 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT048', 'PAT048', 'DOC008', TRUNC(SYSDATE) + 48 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT049', 'PAT049', 'DOC009', TO_DATE('2024-04-15 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT050', 'PAT050', 'DOC010', TO_DATE('2024-04-17 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT051', 'PAT051', 'DOC011', TO_DATE('2024-04-19 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT052', 'PAT052', 'DOC012', TRUNC(SYSDATE) + 52 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT053', 'PAT053', 'DOC013', TO_DATE('2024-04-23 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT054', 'PAT054', 'DOC014', TO_DATE('2024-04-25 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT055', 'PAT055', 'DOC002', TO_DATE('2024-04-27 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT056', 'PAT056', 'DOC016', TRUNC(SYSDATE) + 56 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT057', 'PAT057', 'DOC017', TO_DATE('2024-05-01 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT058', 'PAT058', 'DOC018', TO_DATE('2024-05-03 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT059', 'PAT059', 'DOC019', TO_DATE('2024-05-05 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT060', 'PAT060', 'DOC020', TRUNC(SYSDATE) + 60 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT061', 'PAT061', 'DOC001', TO_DATE('2024-05-09 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT062', 'PAT062', 'DOC002', TO_DATE('2024-05-11 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT063', 'PAT063', 'DOC003', TO_DATE('2024-05-13 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT064', 'PAT064', 'DOC002', TRUNC(SYSDATE) + 64 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT065', 'PAT065', 'DOC005', TO_DATE('2024-05-17 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT066', 'PAT066', 'DOC006', TO_DATE('2024-05-19 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT067', 'PAT067', 'DOC007', TO_DATE('2024-05-21 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT068', 'PAT068', 'DOC008', TRUNC(SYSDATE) + 68 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT069', 'PAT069', 'DOC009', TO_DATE('2024-05-25 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT070', 'PAT070', 'DOC010', TO_DATE('2024-05-27 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT071', 'PAT071', 'DOC011', TO_DATE('2024-05-29 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT072', 'PAT072', 'DOC012', TRUNC(SYSDATE) + 72 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT073', 'PAT073', 'DOC002', TO_DATE('2024-06-02 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT074', 'PAT074', 'DOC014', TO_DATE('2024-06-04 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT075', 'PAT075', 'DOC015', TO_DATE('2024-06-06 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT076', 'PAT076', 'DOC016', TRUNC(SYSDATE) + 76 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT077', 'PAT077', 'DOC017', TO_DATE('2024-06-10 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT078', 'PAT078', 'DOC018', TO_DATE('2024-06-12 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT079', 'PAT079', 'DOC019', TO_DATE('2024-06-14 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT080', 'PAT080', 'DOC020', TRUNC(SYSDATE) + 80 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT081', 'PAT081', 'DOC001', TO_DATE('2024-06-18 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT082', 'PAT082', 'DOC002', TO_DATE('2024-06-20 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT083', 'PAT083', 'DOC003', TO_DATE('2024-06-22 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT084', 'PAT084', 'DOC004', TRUNC(SYSDATE) + 84 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT085', 'PAT085', 'DOC005', TO_DATE('2024-06-26 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT086', 'PAT086', 'DOC006', TO_DATE('2024-06-28 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT087', 'PAT087', 'DOC007', TO_DATE('2024-06-30 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT088', 'PAT088', 'DOC008', TRUNC(SYSDATE) + 88 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT089', 'PAT089', 'DOC009', TO_DATE('2024-07-04 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT090', 'PAT090', 'DOC010', TO_DATE('2024-07-06 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT091', 'PAT091', 'DOC002', TO_DATE('2024-07-08 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT092', 'PAT092', 'DOC012', TRUNC(SYSDATE) + 2 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT093', 'PAT093', 'DOC013', TO_DATE('2024-07-12 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT094', 'PAT094', 'DOC014', TO_DATE('2024-07-14 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT095', 'PAT095', 'DOC015', TO_DATE('2024-07-16 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT096', 'PAT096', 'DOC016', TRUNC(SYSDATE) + 6 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT097', 'PAT097', 'DOC017', TO_DATE('2024-07-20 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT098', 'PAT098', 'DOC018', TO_DATE('2024-07-22 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT099', 'PAT099', 'DOC019', TO_DATE('2024-07-24 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT100', 'PAT100', 'DOC002', TRUNC(SYSDATE) + 10 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT101', 'PAT001', 'DOC001', TO_DATE('2024-07-28 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT102', 'PAT002', 'DOC002', TO_DATE('2024-07-30 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT103', 'PAT003', 'DOC003', TO_DATE('2024-08-01 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT104', 'PAT004', 'DOC004', TRUNC(SYSDATE) + 14 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT105', 'PAT005', 'DOC005', TO_DATE('2024-08-05 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT106', 'PAT006', 'DOC006', TO_DATE('2024-08-07 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT107', 'PAT007', 'DOC007', TO_DATE('2024-08-09 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT108', 'PAT008', 'DOC008', TRUNC(SYSDATE) + 18 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT109', 'PAT009', 'DOC002', TO_DATE('2024-08-13 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT110', 'PAT010', 'DOC010', TO_DATE('2024-08-15 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT111', 'PAT011', 'DOC011', TO_DATE('2024-08-17 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT112', 'PAT012', 'DOC012', TRUNC(SYSDATE) + 22 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT113', 'PAT013', 'DOC013', TO_DATE('2024-08-21 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT114', 'PAT014', 'DOC014', TO_DATE('2024-08-23 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT115', 'PAT015', 'DOC015', TO_DATE('2024-08-25 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT116', 'PAT016', 'DOC016', TRUNC(SYSDATE) + 26 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT117', 'PAT017', 'DOC017', TO_DATE('2024-08-29 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT118', 'PAT018', 'DOC002', TO_DATE('2024-08-31 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT119', 'PAT019', 'DOC019', TO_DATE('2024-09-02 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT120', 'PAT020', 'DOC020', TRUNC(SYSDATE) + 30 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT121', 'PAT021', 'DOC001', TO_DATE('2024-09-06 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT122', 'PAT022', 'DOC002', TO_DATE('2024-09-08 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT123', 'PAT023', 'DOC003', TO_DATE('2024-09-10 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT124', 'PAT024', 'DOC004', TRUNC(SYSDATE) + 34 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT125', 'PAT025', 'DOC005', TO_DATE('2024-09-14 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT126', 'PAT026', 'DOC006', TO_DATE('2024-09-16 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT127', 'PAT027', 'DOC002', TO_DATE('2024-09-18 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT128', 'PAT028', 'DOC008', TRUNC(SYSDATE) + 38 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT129', 'PAT029', 'DOC009', TO_DATE('2024-09-22 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT130', 'PAT030', 'DOC010', TO_DATE('2024-09-24 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT131', 'PAT031', 'DOC011', TO_DATE('2024-09-26 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT132', 'PAT032', 'DOC012', TRUNC(SYSDATE) + 42 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT133', 'PAT033', 'DOC013', TO_DATE('2024-09-30 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT134', 'PAT034', 'DOC014', TO_DATE('2024-10-02 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT135', 'PAT035', 'DOC015', TO_DATE('2024-10-04 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT136', 'PAT036', 'DOC002', TRUNC(SYSDATE) + 46 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT137', 'PAT037', 'DOC017', TO_DATE('2024-10-08 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT138', 'PAT038', 'DOC018', TO_DATE('2024-10-10 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT139', 'PAT039', 'DOC019', TO_DATE('2024-10-12 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT140', 'PAT040', 'DOC020', TRUNC(SYSDATE) + 50 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT141', 'PAT041', 'DOC001', TO_DATE('2024-10-16 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT142', 'PAT042', 'DOC002', TO_DATE('2024-10-18 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT143', 'PAT043', 'DOC003', TO_DATE('2024-10-20 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT144', 'PAT044', 'DOC004', TRUNC(SYSDATE) + 54 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT145', 'PAT045', 'DOC002', TO_DATE('2024-10-24 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT146', 'PAT046', 'DOC006', TO_DATE('2024-10-26 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT147', 'PAT047', 'DOC007', TO_DATE('2024-10-28 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT148', 'PAT048', 'DOC008', TRUNC(SYSDATE) + 58 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT149', 'PAT049', 'DOC009', TO_DATE('2024-11-01 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT150', 'PAT050', 'DOC010', TO_DATE('2024-11-03 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT151', 'PAT051', 'DOC011', TO_DATE('2024-11-05 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT152', 'PAT052', 'DOC012', TRUNC(SYSDATE) + 62 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT153', 'PAT053', 'DOC013', TO_DATE('2024-11-09 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT154', 'PAT054', 'DOC002', TO_DATE('2024-11-11 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT155', 'PAT055', 'DOC015', TO_DATE('2024-11-13 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT156', 'PAT056', 'DOC016', TRUNC(SYSDATE) + 66 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT157', 'PAT057', 'DOC017', TO_DATE('2024-11-17 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT158', 'PAT058', 'DOC018', TO_DATE('2024-11-19 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT159', 'PAT059', 'DOC019', TO_DATE('2024-11-21 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT160', 'PAT060', 'DOC020', TRUNC(SYSDATE) + 70 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT161', 'PAT061', 'DOC001', TO_DATE('2024-11-25 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT162', 'PAT062', 'DOC002', TO_DATE('2024-11-27 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT163', 'PAT063', 'DOC002', TO_DATE('2024-11-29 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT164', 'PAT064', 'DOC004', TRUNC(SYSDATE) + 74 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT165', 'PAT065', 'DOC005', TO_DATE('2024-12-03 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT166', 'PAT066', 'DOC006', TO_DATE('2024-12-05 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT167', 'PAT067', 'DOC007', TO_DATE('2024-12-07 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT168', 'PAT068', 'DOC008', TRUNC(SYSDATE) + 78 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT169', 'PAT069', 'DOC009', TO_DATE('2024-12-11 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT170', 'PAT070', 'DOC010', TO_DATE('2024-12-13 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT171', 'PAT071', 'DOC011', TO_DATE('2024-12-15 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT172', 'PAT072', 'DOC002', TRUNC(SYSDATE) + 82 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT173', 'PAT073', 'DOC013', TO_DATE('2024-12-19 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT174', 'PAT074', 'DOC014', TO_DATE('2024-12-21 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT175', 'PAT075', 'DOC015', TO_DATE('2024-12-23 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT176', 'PAT076', 'DOC016', TRUNC(SYSDATE) + 86 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT177', 'PAT077', 'DOC017', TO_DATE('2024-12-27 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT178', 'PAT078', 'DOC018', TO_DATE('2024-12-29 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT179', 'PAT079', 'DOC019', TO_DATE('2024-12-31 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT180', 'PAT080', 'DOC020', TRUNC(SYSDATE) + 90 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT181', 'PAT081', 'DOC002', TO_DATE('2025-01-04 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT182', 'PAT082', 'DOC002', TO_DATE('2025-01-06 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT183', 'PAT083', 'DOC003', TO_DATE('2025-01-08 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT184', 'PAT084', 'DOC004', TRUNC(SYSDATE) + 4 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT185', 'PAT085', 'DOC005', TO_DATE('2025-01-12 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT186', 'PAT086', 'DOC006', TO_DATE('2025-01-14 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT187', 'PAT087', 'DOC007', TO_DATE('2025-01-16 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT188', 'PAT088', 'DOC008', TRUNC(SYSDATE) + 8 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT189', 'PAT089', 'DOC009', TO_DATE('2025-01-20 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT190', 'PAT090', 'DOC002', TO_DATE('2025-01-22 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT191', 'PAT091', 'DOC011', TO_DATE('2025-01-24 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT192', 'PAT092', 'DOC012', TRUNC(SYSDATE) + 12 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT193', 'PAT093', 'DOC013', TO_DATE('2025-01-28 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT194', 'PAT094', 'DOC014', TO_DATE('2025-01-30 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT195', 'PAT095', 'DOC015', TO_DATE('2025-02-01 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT196', 'PAT096', 'DOC016', TRUNC(SYSDATE) + 16 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT197', 'PAT097', 'DOC017', TO_DATE('2025-02-05 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT198', 'PAT098', 'DOC018', TO_DATE('2025-02-07 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT199', 'PAT099', 'DOC002', TO_DATE('2025-02-09 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT200', 'PAT100', 'DOC020', TRUNC(SYSDATE) + 20 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT201', 'PAT001', 'DOC001', TO_DATE('2025-02-13 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT202', 'PAT002', 'DOC002', TO_DATE('2025-02-15 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT203', 'PAT003', 'DOC003', TO_DATE('2025-02-17 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT204', 'PAT004', 'DOC004', TRUNC(SYSDATE) + 24 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT205', 'PAT005', 'DOC005', TO_DATE('2025-02-21 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT206', 'PAT006', 'DOC006', TO_DATE('2025-02-23 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT207', 'PAT007', 'DOC007', TO_DATE('2025-02-25 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT208', 'PAT008', 'DOC002', TRUNC(SYSDATE) + 28 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT209', 'PAT009', 'DOC009', TO_DATE('2025-03-01 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT210', 'PAT010', 'DOC010', TO_DATE('2025-03-03 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT211', 'PAT011', 'DOC011', TO_DATE('2025-03-05 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT212', 'PAT012', 'DOC012', TRUNC(SYSDATE) + 32 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT213', 'PAT013', 'DOC013', TO_DATE('2025-03-09 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT214', 'PAT014', 'DOC014', TO_DATE('2025-03-11 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT215', 'PAT015', 'DOC015', TO_DATE('2025-03-13 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT216', 'PAT016', 'DOC016', TRUNC(SYSDATE) + 36 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT217', 'PAT017', 'DOC002', TO_DATE('2025-03-17 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT218', 'PAT018', 'DOC018', TO_DATE('2025-03-19 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT219', 'PAT019', 'DOC019', TO_DATE('2025-03-21 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT220', 'PAT020', 'DOC020', TRUNC(SYSDATE) + 40 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT221', 'PAT021', 'DOC001', TO_DATE('2025-03-25 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT222', 'PAT022', 'DOC002', TO_DATE('2025-03-27 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT223', 'PAT023', 'DOC003', TO_DATE('2025-03-29 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT224', 'PAT024', 'DOC004', TRUNC(SYSDATE) + 44 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT225', 'PAT025', 'DOC005', TO_DATE('2025-04-02 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT226', 'PAT026', 'DOC002', TO_DATE('2025-04-04 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT227', 'PAT027', 'DOC007', TO_DATE('2025-04-06 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT228', 'PAT028', 'DOC008', TRUNC(SYSDATE) + 48 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT229', 'PAT029', 'DOC009', TO_DATE('2025-04-10 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT230', 'PAT030', 'DOC010', TO_DATE('2025-04-12 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT231', 'PAT031', 'DOC011', TO_DATE('2025-04-14 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT232', 'PAT032', 'DOC012', TRUNC(SYSDATE) + 52 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT233', 'PAT033', 'DOC013', TO_DATE('2025-04-18 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT234', 'PAT034', 'DOC014', TO_DATE('2025-04-20 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT235', 'PAT035', 'DOC002', TO_DATE('2025-04-22 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT236', 'PAT036', 'DOC016', TRUNC(SYSDATE) + 56 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT237', 'PAT037', 'DOC017', TO_DATE('2025-04-26 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT238', 'PAT038', 'DOC018', TO_DATE('2025-04-28 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT239', 'PAT039', 'DOC019', TO_DATE('2025-04-30 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT240', 'PAT040', 'DOC020', TRUNC(SYSDATE) + 60 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT241', 'PAT041', 'DOC001', TO_DATE('2025-05-04 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT242', 'PAT042', 'DOC002', TO_DATE('2025-05-06 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT243', 'PAT043', 'DOC003', TO_DATE('2025-05-08 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT244', 'PAT044', 'DOC002', TRUNC(SYSDATE) + 64 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT245', 'PAT045', 'DOC005', TO_DATE('2025-05-12 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT246', 'PAT046', 'DOC006', TO_DATE('2025-05-14 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT247', 'PAT047', 'DOC007', TO_DATE('2025-05-16 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT248', 'PAT048', 'DOC008', TRUNC(SYSDATE) + 68 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT249', 'PAT049', 'DOC009', TO_DATE('2025-05-20 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT250', 'PAT050', 'DOC010', TO_DATE('2025-05-22 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT251', 'PAT051', 'DOC011', TO_DATE('2025-05-24 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT252', 'PAT052', 'DOC012', TRUNC(SYSDATE) + 72 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT253', 'PAT053', 'DOC002', TO_DATE('2025-05-28 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT254', 'PAT054', 'DOC014', TO_DATE('2025-05-30 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT255', 'PAT055', 'DOC015', TO_DATE('2025-06-01 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT256', 'PAT056', 'DOC016', TRUNC(SYSDATE) + 76 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT257', 'PAT057', 'DOC017', TO_DATE('2025-06-05 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT258', 'PAT058', 'DOC018', TO_DATE('2025-06-07 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT259', 'PAT059', 'DOC019', TO_DATE('2025-06-09 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT260', 'PAT060', 'DOC020', TRUNC(SYSDATE) + 80 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT261', 'PAT061', 'DOC001', TO_DATE('2025-06-13 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Routine cardiology follow-up and blood pressure review', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT262', 'PAT062', 'DOC002', TO_DATE('2025-06-15 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Initial consultation for persistent migraine headaches', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT263', 'PAT063', 'DOC003', TO_DATE('2025-06-17 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Post-surgical wound inspection and suture removal', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT264', 'PAT064', 'DOC004', TRUNC(SYSDATE) + 84 + (16/24) + (45/1440), 'Rescheduled', 'Annual pediatric growth and immunization checkup', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT265', 'PAT065', 'DOC005', TO_DATE('2025-06-21 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT266', 'PAT066', 'DOC006', TO_DATE('2025-06-23 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Diabetes medication titration and HbA1c review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT267', 'PAT067', 'DOC007', TO_DATE('2025-06-25 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT268', 'PAT068', 'DOC008', TRUNC(SYSDATE) + 88 + (12/24) + (45/1440), 'Scheduled', 'Pre-operative anesthesia clearance consultation', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT269', 'PAT069', 'DOC009', TO_DATE('2025-06-29 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Follow-up on abnormal laboratory lipid panel results', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT270', 'PAT070', 'DOC010', TO_DATE('2025-07-01 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Oncology chemotherapy cycle review and blood count check', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT271', 'PAT071', 'DOC002', TO_DATE('2025-07-03 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Routine cardiology follow-up and blood pressure review', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT272', 'PAT072', 'DOC012', TRUNC(SYSDATE) + 2 + (16/24) + (45/1440), 'Rescheduled', 'Initial consultation for persistent migraine headaches', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT273', 'PAT073', 'DOC013', TO_DATE('2025-07-07 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT274', 'PAT074', 'DOC014', TO_DATE('2025-07-09 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Annual pediatric growth and immunization checkup', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT275', 'PAT075', 'DOC015', TO_DATE('2025-07-11 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Evaluation of chronic lower back and knee pain', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT276', 'PAT076', 'DOC016', TRUNC(SYSDATE) + 6 + (12/24) + (45/1440), 'Scheduled', 'Diabetes medication titration and HbA1c review', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT277', 'PAT077', 'DOC017', TO_DATE('2025-07-15 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Shortness of breath and spirometry assessment', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT278', 'PAT078', 'DOC018', TO_DATE('2025-07-17 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Pre-operative anesthesia clearance consultation', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT279', 'PAT079', 'DOC019', TO_DATE('2025-07-19 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Follow-up on abnormal laboratory lipid panel results', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT280', 'PAT080', 'DOC002', TRUNC(SYSDATE) + 10 + (16/24) + (45/1440), 'Rescheduled', 'Oncology chemotherapy cycle review and blood count check', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT281', 'PAT081', 'DOC001', TO_DATE('2025-07-23 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT282', 'PAT082', 'DOC002', TO_DATE('2025-07-25 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Initial consultation for persistent migraine headaches', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT283', 'PAT083', 'DOC003', TO_DATE('2025-07-27 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Post-surgical wound inspection and suture removal', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT284', 'PAT084', 'DOC004', TRUNC(SYSDATE) + 14 + (12/24) + (45/1440), 'Scheduled', 'Annual pediatric growth and immunization checkup', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT285', 'PAT085', 'DOC005', TO_DATE('2025-07-31 15:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Evaluation of chronic lower back and knee pain', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT286', 'PAT086', 'DOC006', TO_DATE('2025-08-02 15:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Diabetes medication titration and HbA1c review', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT287', 'PAT087', 'DOC007', TO_DATE('2025-08-04 16:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Shortness of breath and spirometry assessment', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT288', 'PAT088', 'DOC008', TRUNC(SYSDATE) + 18 + (16/24) + (45/1440), 'Rescheduled', 'Pre-operative anesthesia clearance consultation', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT289', 'PAT089', 'DOC002', TO_DATE('2025-08-08 09:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT290', 'PAT090', 'DOC010', TO_DATE('2025-08-10 09:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Oncology chemotherapy cycle review and blood count check', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT291', 'PAT091', 'DOC011', TO_DATE('2025-08-12 10:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Routine cardiology follow-up and blood pressure review', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT292', 'PAT092', 'DOC012', TRUNC(SYSDATE) + 22 + (12/24) + (45/1440), 'Scheduled', 'Initial consultation for persistent migraine headaches', NULL);
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT293', 'PAT093', 'DOC013', TO_DATE('2025-08-16 11:00', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 'Post-surgical wound inspection and suture removal', 'Patient requested cancellation due to travel conflict.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT294', 'PAT094', 'DOC014', TO_DATE('2025-08-18 11:30', 'YYYY-MM-DD HH24:MI'), 'No-Show', 'Annual pediatric growth and immunization checkup', 'Patient did not arrive within 30 minutes of scheduled time.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT295', 'PAT095', 'DOC015', TO_DATE('2025-08-20 12:00', 'YYYY-MM-DD HH24:MI'), 'In-Progress', 'Evaluation of chronic lower back and knee pain', 'Patient currently in examination room with attending physician.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT296', 'PAT096', 'DOC016', TRUNC(SYSDATE) + 26 + (16/24) + (45/1440), 'Rescheduled', 'Diabetes medication titration and HbA1c review', 'Rescheduled to next available clinic slot per patient request.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT297', 'PAT097', 'DOC017', TO_DATE('2025-08-24 13:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Shortness of breath and spirometry assessment', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT298', 'PAT098', 'DOC002', TO_DATE('2025-08-26 13:30', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Pre-operative anesthesia clearance consultation', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT299', 'PAT099', 'DOC019', TO_DATE('2025-08-28 14:00', 'YYYY-MM-DD HH24:MI'), 'Completed', 'Follow-up on abnormal laboratory lipid panel results', 'Consultation completed; clinical plan documented in record.');
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes) VALUES ('APT300', 'PAT100', 'DOC020', TRUNC(SYSDATE) + 30 + (12/24) + (45/1440), 'Scheduled', 'Oncology chemotherapy cycle review and blood count check', NULL);

COMMIT;

-- Source: scripts/02_seeds/student3_appointments_records/insert_medical_record.sql
-- SEED DATA: MedicalRecord (Student 3) - 250 rows
-- Row 1 omits RecordDate (SYSDATE) and FollowUpDate (NULL) to exercise DEFAULTS.

INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes) VALUES ('MR001', 'PAT001', 'DOC002', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Baseline clinical assessment recorded on admission.');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR002', 'PAT002', 'DOC004', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-02-05', DATE '2023-02-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR003', 'PAT003', 'DOC007', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-09', DATE '2023-02-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR004', 'PAT004', 'DOC010', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-02-13', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR005', 'PAT005', 'DOC013', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-17', DATE '2023-03-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR006', 'PAT006', 'DOC016', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-02-21', DATE '2023-03-12');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR007', 'PAT007', 'DOC019', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-25', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR008', 'PAT008', 'DOC002', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-03-01', DATE '2023-03-22');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR009', 'PAT009', 'DOC005', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-05', DATE '2023-03-27');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR010', 'PAT010', 'DOC008', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-03-09', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR011', 'PAT011', 'DOC011', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-13', DATE '2023-04-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR012', 'PAT012', 'DOC014', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-03-17', DATE '2023-04-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR013', 'PAT013', 'DOC017', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-21', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR014', 'PAT014', 'DOC020', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-03-25', DATE '2023-04-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR015', 'PAT015', 'DOC003', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-29', DATE '2023-04-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR016', 'PAT016', 'DOC006', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-04-02', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR017', 'PAT017', 'DOC009', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-06', DATE '2023-05-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR018', 'PAT018', 'DOC012', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-04-10', DATE '2023-05-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR019', 'PAT019', 'DOC015', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-14', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR020', 'PAT020', 'DOC018', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-04-18', DATE '2023-05-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR021', 'PAT021', 'DOC001', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-22', DATE '2023-05-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR022', 'PAT022', 'DOC004', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-04-26', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR023', 'PAT023', 'DOC007', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-30', DATE '2023-06-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR024', 'PAT024', 'DOC010', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-05-04', DATE '2023-06-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR025', 'PAT025', 'DOC013', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-05-08', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR026', 'PAT026', 'DOC016', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-05-12', DATE '2023-06-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR027', 'PAT027', 'DOC019', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-05-16', DATE '2023-06-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR028', 'PAT028', 'DOC002', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-05-20', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR029', 'PAT029', 'DOC005', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-05-24', DATE '2023-07-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR030', 'PAT030', 'DOC008', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-05-28', DATE '2023-07-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR031', 'PAT031', 'DOC011', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-06-01', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR032', 'PAT032', 'DOC014', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-06-05', DATE '2023-07-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR033', 'PAT033', 'DOC017', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-06-09', DATE '2023-07-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR034', 'PAT034', 'DOC020', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-06-13', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR035', 'PAT035', 'DOC003', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-06-17', DATE '2023-08-04');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR036', 'PAT036', 'DOC006', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-06-21', DATE '2023-08-09');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR037', 'PAT037', 'DOC009', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-06-25', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR038', 'PAT038', 'DOC012', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-06-29', DATE '2023-08-19');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR039', 'PAT039', 'DOC015', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-07-03', DATE '2023-08-24');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR040', 'PAT040', 'DOC018', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-07-07', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR041', 'PAT041', 'DOC001', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-07-11', DATE '2023-09-03');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR042', 'PAT042', 'DOC004', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-07-15', DATE '2023-09-08');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR043', 'PAT043', 'DOC007', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-07-19', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR044', 'PAT044', 'DOC010', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-07-23', DATE '2023-09-18');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR045', 'PAT045', 'DOC013', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-07-27', DATE '2023-09-23');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR046', 'PAT046', 'DOC016', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-07-31', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR047', 'PAT047', 'DOC019', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-08-04', DATE '2023-10-03');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR048', 'PAT048', 'DOC002', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-08-08', DATE '2023-10-08');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR049', 'PAT049', 'DOC005', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-08-12', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR050', 'PAT050', 'DOC008', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-08-16', DATE '2023-10-18');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR051', 'PAT051', 'DOC011', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-08-20', DATE '2023-10-23');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR052', 'PAT052', 'DOC014', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-08-24', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR053', 'PAT053', 'DOC017', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-08-28', DATE '2023-11-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR054', 'PAT054', 'DOC020', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-09-01', DATE '2023-11-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR055', 'PAT055', 'DOC003', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-09-05', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR056', 'PAT056', 'DOC006', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-09-09', DATE '2023-11-17');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR057', 'PAT057', 'DOC009', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-09-13', DATE '2023-11-22');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR058', 'PAT058', 'DOC012', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-09-17', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR059', 'PAT059', 'DOC015', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-09-21', DATE '2023-12-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR060', 'PAT060', 'DOC018', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-09-25', DATE '2023-12-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR061', 'PAT061', 'DOC001', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-09-29', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR062', 'PAT062', 'DOC004', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-10-03', DATE '2023-10-18');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR063', 'PAT063', 'DOC007', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-10-07', DATE '2023-10-23');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR064', 'PAT064', 'DOC010', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-10-11', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR065', 'PAT065', 'DOC013', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-10-15', DATE '2023-11-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR066', 'PAT066', 'DOC016', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-10-19', DATE '2023-11-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR067', 'PAT067', 'DOC019', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-10-23', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR068', 'PAT068', 'DOC002', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-10-27', DATE '2023-11-17');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR069', 'PAT069', 'DOC005', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-10-31', DATE '2023-11-22');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR070', 'PAT070', 'DOC008', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-11-04', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR071', 'PAT071', 'DOC011', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-11-08', DATE '2023-12-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR072', 'PAT072', 'DOC014', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-11-12', DATE '2023-12-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR073', 'PAT073', 'DOC017', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-11-16', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR074', 'PAT074', 'DOC020', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-11-20', DATE '2023-12-17');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR075', 'PAT075', 'DOC003', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-11-24', DATE '2023-12-22');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR076', 'PAT076', 'DOC006', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-11-28', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR077', 'PAT077', 'DOC009', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-12-02', DATE '2024-01-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR078', 'PAT078', 'DOC012', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-12-06', DATE '2024-01-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR079', 'PAT079', 'DOC015', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-12-10', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR080', 'PAT080', 'DOC018', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-12-14', DATE '2024-01-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR081', 'PAT081', 'DOC001', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-12-18', DATE '2024-01-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR082', 'PAT082', 'DOC004', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-12-22', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR083', 'PAT083', 'DOC007', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-12-26', DATE '2024-01-31');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR084', 'PAT084', 'DOC010', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-12-30', DATE '2024-02-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR085', 'PAT085', 'DOC013', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-01-03', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR086', 'PAT086', 'DOC016', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-01-07', DATE '2024-02-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR087', 'PAT087', 'DOC019', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-01-11', DATE '2024-02-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR088', 'PAT088', 'DOC002', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-01-15', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR089', 'PAT089', 'DOC005', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-01-19', DATE '2024-03-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR090', 'PAT090', 'DOC008', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-01-23', DATE '2024-03-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR091', 'PAT001', 'DOC012', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-01-27', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR092', 'PAT002', 'DOC015', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-01-31', DATE '2024-03-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR093', 'PAT003', 'DOC018', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-02-04', DATE '2024-03-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR094', 'PAT004', 'DOC001', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-02-08', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR095', 'PAT005', 'DOC004', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-02-12', DATE '2024-03-31');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR096', 'PAT006', 'DOC007', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-02-16', DATE '2024-04-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR097', 'PAT007', 'DOC010', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-02-20', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR098', 'PAT008', 'DOC013', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-02-24', DATE '2024-04-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR099', 'PAT009', 'DOC016', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-02-28', DATE '2024-04-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR100', 'PAT010', 'DOC019', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-03-03', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR101', 'PAT011', 'DOC002', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-03-07', DATE '2024-04-30');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR102', 'PAT012', 'DOC005', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-03-11', DATE '2024-05-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR103', 'PAT013', 'DOC008', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-03-15', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR104', 'PAT014', 'DOC011', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-03-19', DATE '2024-05-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR105', 'PAT015', 'DOC014', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-03-23', DATE '2024-05-20');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR106', 'PAT016', 'DOC017', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-03-27', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR107', 'PAT017', 'DOC020', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-03-31', DATE '2024-05-30');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR108', 'PAT018', 'DOC003', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-04-04', DATE '2024-06-04');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR109', 'PAT019', 'DOC006', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-04-08', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR110', 'PAT020', 'DOC009', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-04-12', DATE '2024-06-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR111', 'PAT021', 'DOC012', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-04-16', DATE '2024-06-19');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR112', 'PAT022', 'DOC015', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-04-20', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR113', 'PAT023', 'DOC018', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-04-24', DATE '2024-06-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR114', 'PAT024', 'DOC001', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-04-28', DATE '2024-07-04');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR115', 'PAT025', 'DOC004', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-05-02', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR116', 'PAT026', 'DOC007', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-05-06', DATE '2024-07-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR117', 'PAT027', 'DOC010', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-05-10', DATE '2024-07-19');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR118', 'PAT028', 'DOC013', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-05-14', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR119', 'PAT029', 'DOC016', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-05-18', DATE '2024-07-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR120', 'PAT030', 'DOC019', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-05-22', DATE '2024-08-03');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR121', 'PAT031', 'DOC002', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-05-26', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR122', 'PAT032', 'DOC005', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-05-30', DATE '2024-06-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR123', 'PAT033', 'DOC008', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-06-03', DATE '2024-06-19');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR124', 'PAT034', 'DOC011', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-06-07', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR125', 'PAT035', 'DOC014', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-06-11', DATE '2024-06-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR126', 'PAT036', 'DOC017', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-06-15', DATE '2024-07-04');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR127', 'PAT037', 'DOC020', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-06-19', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR128', 'PAT038', 'DOC003', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-06-23', DATE '2024-07-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR129', 'PAT039', 'DOC006', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-06-27', DATE '2024-07-19');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR130', 'PAT040', 'DOC009', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-07-01', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR131', 'PAT041', 'DOC012', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-07-05', DATE '2024-07-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR132', 'PAT042', 'DOC015', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-07-09', DATE '2024-08-03');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR133', 'PAT043', 'DOC018', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-07-13', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR134', 'PAT044', 'DOC001', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-07-17', DATE '2024-08-13');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR135', 'PAT045', 'DOC004', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-07-21', DATE '2024-08-18');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR136', 'PAT046', 'DOC007', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-07-25', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR137', 'PAT047', 'DOC010', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-07-29', DATE '2024-08-28');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR138', 'PAT048', 'DOC013', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-08-02', DATE '2024-09-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR139', 'PAT049', 'DOC016', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-08-06', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR140', 'PAT050', 'DOC019', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-08-10', DATE '2024-09-12');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR141', 'PAT051', 'DOC002', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-08-14', DATE '2024-09-17');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR142', 'PAT052', 'DOC005', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-08-18', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR143', 'PAT053', 'DOC008', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-08-22', DATE '2024-09-27');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR144', 'PAT054', 'DOC011', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-08-26', DATE '2024-10-02');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR145', 'PAT055', 'DOC014', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-08-30', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR146', 'PAT056', 'DOC017', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-09-03', DATE '2024-10-12');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR147', 'PAT057', 'DOC020', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-09-07', DATE '2024-10-17');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR148', 'PAT058', 'DOC003', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-09-11', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR149', 'PAT059', 'DOC006', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-09-15', DATE '2024-10-27');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR150', 'PAT060', 'DOC009', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-09-19', DATE '2024-11-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR151', 'PAT061', 'DOC012', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-09-23', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR152', 'PAT062', 'DOC015', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-09-27', DATE '2024-11-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR153', 'PAT063', 'DOC018', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-10-01', DATE '2024-11-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR154', 'PAT064', 'DOC001', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-10-05', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR155', 'PAT065', 'DOC004', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-10-09', DATE '2024-11-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR156', 'PAT066', 'DOC007', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-10-13', DATE '2024-12-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR157', 'PAT067', 'DOC010', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-10-17', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR158', 'PAT068', 'DOC013', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-10-21', DATE '2024-12-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR159', 'PAT069', 'DOC016', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-10-25', DATE '2024-12-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR160', 'PAT070', 'DOC019', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-10-29', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR161', 'PAT071', 'DOC002', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-11-02', DATE '2024-12-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR162', 'PAT072', 'DOC005', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-11-06', DATE '2024-12-31');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR163', 'PAT073', 'DOC008', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-11-10', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR164', 'PAT074', 'DOC011', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-11-14', DATE '2025-01-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR165', 'PAT075', 'DOC014', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-11-18', DATE '2025-01-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR166', 'PAT076', 'DOC017', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2024-11-22', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR167', 'PAT077', 'DOC020', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-11-26', DATE '2025-01-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR168', 'PAT078', 'DOC003', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2024-11-30', DATE '2025-01-30');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR169', 'PAT079', 'DOC006', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-12-04', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR170', 'PAT080', 'DOC009', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2024-12-08', DATE '2025-02-09');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR171', 'PAT081', 'DOC012', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-12-12', DATE '2025-02-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR172', 'PAT082', 'DOC015', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2024-12-16', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR173', 'PAT083', 'DOC018', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-12-20', DATE '2025-02-24');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR174', 'PAT084', 'DOC001', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2024-12-24', DATE '2025-03-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR175', 'PAT085', 'DOC004', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2024-12-28', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR176', 'PAT086', 'DOC007', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2025-01-01', DATE '2025-03-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR177', 'PAT087', 'DOC010', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-01-05', DATE '2025-03-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR178', 'PAT088', 'DOC013', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2025-01-09', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR179', 'PAT089', 'DOC016', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-01-13', DATE '2025-03-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR180', 'PAT090', 'DOC019', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2025-01-17', DATE '2025-03-31');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR181', 'PAT001', 'DOC003', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-01-21', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR182', 'PAT002', 'DOC006', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2025-01-25', DATE '2025-02-09');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR183', 'PAT003', 'DOC009', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-01-29', DATE '2025-02-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR184', 'PAT004', 'DOC012', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2025-02-02', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR185', 'PAT005', 'DOC015', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-02-06', DATE '2025-02-24');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR186', 'PAT006', 'DOC018', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2025-02-10', DATE '2025-03-01');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR187', 'PAT007', 'DOC001', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-02-14', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR188', 'PAT008', 'DOC004', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2025-02-18', DATE '2025-03-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR189', 'PAT009', 'DOC007', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-02-22', DATE '2025-03-16');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR190', 'PAT010', 'DOC010', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2025-02-26', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR191', 'PAT011', 'DOC013', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-03-02', DATE '2025-03-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR192', 'PAT012', 'DOC016', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2025-03-06', DATE '2025-03-31');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR193', 'PAT013', 'DOC019', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-03-10', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR194', 'PAT014', 'DOC002', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2025-03-14', DATE '2025-04-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR195', 'PAT015', 'DOC005', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-03-18', DATE '2025-04-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR196', 'PAT016', 'DOC008', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2025-03-22', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR197', 'PAT017', 'DOC011', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-03-26', DATE '2025-04-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR198', 'PAT018', 'DOC014', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2025-03-30', DATE '2025-04-30');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR199', 'PAT019', 'DOC017', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-04-03', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR200', 'PAT020', 'DOC020', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2025-04-07', DATE '2025-05-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR201', 'PAT021', 'DOC003', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-04-11', DATE '2025-05-15');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR202', 'PAT022', 'DOC006', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2025-04-15', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR203', 'PAT023', 'DOC009', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-04-19', DATE '2025-05-25');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR204', 'PAT024', 'DOC012', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2025-04-23', DATE '2025-05-30');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR205', 'PAT025', 'DOC015', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-04-27', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR206', 'PAT026', 'DOC018', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2025-05-01', DATE '2025-06-09');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR207', 'PAT027', 'DOC001', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-05-05', DATE '2025-06-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR208', 'PAT028', 'DOC004', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2025-05-09', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR209', 'PAT029', 'DOC007', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-05-13', DATE '2025-06-24');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR210', 'PAT030', 'DOC010', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2025-05-17', DATE '2025-06-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR211', 'PAT031', 'DOC013', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-05-21', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR212', 'PAT032', 'DOC016', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2025-05-25', DATE '2025-07-09');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR213', 'PAT033', 'DOC019', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-05-29', DATE '2025-07-14');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR214', 'PAT034', 'DOC002', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2025-06-02', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR215', 'PAT035', 'DOC005', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-06-06', DATE '2025-07-24');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR216', 'PAT036', 'DOC008', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2025-06-10', DATE '2025-07-29');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR217', 'PAT037', 'DOC011', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-06-14', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR218', 'PAT038', 'DOC014', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2025-06-18', DATE '2025-08-08');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR219', 'PAT039', 'DOC017', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-06-22', DATE '2025-08-13');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR220', 'PAT040', 'DOC020', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2025-06-26', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR221', 'PAT041', 'DOC003', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-06-30', DATE '2025-08-23');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR222', 'PAT042', 'DOC006', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2025-07-04', DATE '2025-08-28');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR223', 'PAT043', 'DOC009', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-07-08', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR224', 'PAT044', 'DOC012', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2025-07-12', DATE '2025-09-07');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR225', 'PAT045', 'DOC015', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2025-07-16', DATE '2025-09-12');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR226', 'PAT046', 'DOC018', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-02-01', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR227', 'PAT047', 'DOC001', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-05', DATE '2023-04-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR228', 'PAT048', 'DOC004', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-02-09', DATE '2023-04-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR229', 'PAT049', 'DOC007', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-13', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR230', 'PAT050', 'DOC010', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-02-17', DATE '2023-04-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR231', 'PAT051', 'DOC013', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-02-21', DATE '2023-04-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR232', 'PAT052', 'DOC016', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-02-25', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR233', 'PAT053', 'DOC019', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-01', DATE '2023-05-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR234', 'PAT054', 'DOC002', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-03-05', DATE '2023-05-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR235', 'PAT055', 'DOC005', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-09', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR236', 'PAT056', 'DOC008', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-03-13', DATE '2023-05-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR237', 'PAT057', 'DOC011', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-17', DATE '2023-05-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR238', 'PAT058', 'DOC014', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-03-21', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR239', 'PAT059', 'DOC017', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-03-25', DATE '2023-06-05');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR240', 'PAT060', 'DOC020', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-03-29', DATE '2023-06-10');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR241', 'PAT061', 'DOC003', 'Essential Hypertension Stage 2', 'Prescribed ACE inhibitor daily and low-sodium dietary regimen.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-02', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR242', 'PAT062', 'DOC006', 'Type 2 Diabetes Mellitus', 'Initiated Metformin 500mg twice daily with glycemic self-monitoring.', NULL, DATE '2023-04-06', DATE '2023-04-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR243', 'PAT063', 'DOC009', 'Acute Bacterial Sinusitis', 'Oral Amoxicillin-Clavulanate course for 10 days plus saline spray.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-10', DATE '2023-04-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR244', 'PAT064', 'DOC012', 'Osteoarthritis of Right Knee', 'Physical therapy sessions and topical NSAID anti-inflammatory gel.', NULL, DATE '2023-04-14', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR245', 'PAT065', 'DOC015', 'Chronic Migraine Without Aura', 'Preventive beta-blocker therapy and acute sumatriptan rescue plan.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-18', DATE '2023-05-06');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR246', 'PAT066', 'DOC018', 'Community-Acquired Pneumonia', 'Azithromycin and supportive hydration with chest X-ray follow-up.', NULL, DATE '2023-04-22', DATE '2023-05-11');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR247', 'PAT067', 'DOC001', 'Gastroesophageal Reflux Disease', 'Proton pump inhibitor before breakfast and lifestyle adjustments.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-04-26', NULL);
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR248', 'PAT068', 'DOC004', 'Iron Deficiency Anemia', 'Oral ferrous sulfate supplementation for 3 months with CBC recheck.', NULL, DATE '2023-04-30', DATE '2023-05-21');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR249', 'PAT069', 'DOC007', 'Mild Persistent Bronchial Asthma', 'Inhaled corticosteroid controller and albuterol rescue inhaler.', 'Patient counseled on adherence and warning symptoms.', DATE '2023-05-04', DATE '2023-05-26');
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate) VALUES ('MR250', 'PAT070', 'DOC010', 'Hyperlipidemia Mixed Type', 'Atorvastatin 20mg nightly and Mediterranean diet counseling.', NULL, DATE '2023-05-08', NULL);

COMMIT;

-- Source: scripts/02_seeds/student3_appointments_records/insert_medical_procedure.sql
-- SEED DATA: MedicalProcedure (Student 3) - 100 rows
-- Row 1 omits ProcedureDate (SYSDATE) and Outcome ('Pending') to exercise DEFAULTS.

INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, Duration, OperatingRoom, ProcedureCost) VALUES ('PROC001', 'PAT001', 'DOC002', 'Coronary Angiography and Stent Placement', 90, 'Cath Lab', 45000.00);
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC002', 'PAT002', 'DOC002', 'Laparoscopic Cholecystectomy', TO_DATE('2023-03-08 09:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC003', 'PAT003', 'DOC003', 'Total Knee Arthroplasty', TO_DATE('2023-03-15 10:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC004', 'PAT004', 'DOC004', 'Upper Gastrointestinal Endoscopy', TO_DATE('2023-03-22 11:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC005', 'PAT005', 'DOC005', 'Emergency Appendectomy', TRUNC(SYSDATE) + 4 + (10/24), 60, 'OR-3', 22000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC006', 'PAT006', 'DOC006', 'Carpal Tunnel Release Surgery', TO_DATE('2023-04-05 13:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC007', 'PAT007', 'DOC007', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2023-04-12 08:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC008', 'PAT008', 'DOC008', 'Open Reduction Internal Fixation Femur', TO_DATE('2023-04-19 09:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC009', 'PAT009', 'DOC009', 'Pacemaker Implantation Procedure', TO_DATE('2023-04-26 10:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC010', 'PAT010', 'DOC010', 'Inguinal Hernia Mesh Repair', TO_DATE('2023-05-03 11:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC011', 'PAT011', 'DOC011', 'Coronary Angiography and Stent Placement', TO_DATE('2023-05-10 12:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC012', 'PAT012', 'DOC012', 'Laparoscopic Cholecystectomy', TO_DATE('2023-05-17 13:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC013', 'PAT013', 'DOC013', 'Total Knee Arthroplasty', TRUNC(SYSDATE) + 12 + (10/24), 150, 'OR-2', 85000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC014', 'PAT014', 'DOC014', 'Upper Gastrointestinal Endoscopy', TO_DATE('2023-05-31 09:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC015', 'PAT015', 'DOC015', 'Emergency Appendectomy', TO_DATE('2023-06-07 10:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC016', 'PAT016', 'DOC016', 'Carpal Tunnel Release Surgery', TO_DATE('2023-06-14 11:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC017', 'PAT017', 'DOC017', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2023-06-21 12:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC018', 'PAT018', 'DOC018', 'Open Reduction Internal Fixation Femur', TO_DATE('2023-06-28 13:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC019', 'PAT019', 'DOC019', 'Pacemaker Implantation Procedure', TO_DATE('2023-07-05 08:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC020', 'PAT020', 'DOC020', 'Inguinal Hernia Mesh Repair', TO_DATE('2023-07-12 09:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC021', 'PAT021', 'DOC001', 'Coronary Angiography and Stent Placement', TRUNC(SYSDATE) + 20 + (10/24), 90, 'Cath Lab', 45000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC022', 'PAT022', 'DOC002', 'Laparoscopic Cholecystectomy', TO_DATE('2023-07-26 11:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC023', 'PAT023', 'DOC003', 'Total Knee Arthroplasty', TO_DATE('2023-08-02 12:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC024', 'PAT024', 'DOC004', 'Upper Gastrointestinal Endoscopy', TO_DATE('2023-08-09 13:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC025', 'PAT025', 'DOC005', 'Emergency Appendectomy', TO_DATE('2023-08-16 08:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC026', 'PAT026', 'DOC006', 'Carpal Tunnel Release Surgery', TO_DATE('2023-08-23 09:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC027', 'PAT027', 'DOC007', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2023-08-30 10:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC028', 'PAT028', 'DOC008', 'Open Reduction Internal Fixation Femur', TO_DATE('2023-09-06 11:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC029', 'PAT029', 'DOC009', 'Pacemaker Implantation Procedure', TRUNC(SYSDATE) + 28 + (10/24), 110, 'Cath Lab', 68000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC030', 'PAT030', 'DOC010', 'Inguinal Hernia Mesh Repair', TO_DATE('2023-09-20 13:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC031', 'PAT031', 'DOC011', 'Coronary Angiography and Stent Placement', TO_DATE('2023-09-27 08:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC032', 'PAT032', 'DOC012', 'Laparoscopic Cholecystectomy', TO_DATE('2023-10-04 09:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC033', 'PAT033', 'DOC013', 'Total Knee Arthroplasty', TO_DATE('2023-10-11 10:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC034', 'PAT034', 'DOC014', 'Upper Gastrointestinal Endoscopy', TO_DATE('2023-10-18 11:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC035', 'PAT035', 'DOC015', 'Emergency Appendectomy', TO_DATE('2023-10-25 12:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC036', 'PAT036', 'DOC016', 'Carpal Tunnel Release Surgery', TO_DATE('2023-11-01 13:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC037', 'PAT037', 'DOC017', 'Diagnostic Colonoscopy with Biopsy', TRUNC(SYSDATE) + 36 + (10/24), 50, 'Endoscopy Suite', 8200.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC038', 'PAT038', 'DOC018', 'Open Reduction Internal Fixation Femur', TO_DATE('2023-11-15 09:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC039', 'PAT039', 'DOC019', 'Pacemaker Implantation Procedure', TO_DATE('2023-11-22 10:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC040', 'PAT040', 'DOC020', 'Inguinal Hernia Mesh Repair', TO_DATE('2023-11-29 11:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC041', 'PAT041', 'DOC001', 'Coronary Angiography and Stent Placement', TO_DATE('2023-12-06 12:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC042', 'PAT042', 'DOC002', 'Laparoscopic Cholecystectomy', TO_DATE('2023-12-13 13:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC043', 'PAT043', 'DOC003', 'Total Knee Arthroplasty', TO_DATE('2023-12-20 08:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC044', 'PAT044', 'DOC004', 'Upper Gastrointestinal Endoscopy', TO_DATE('2023-12-27 09:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC045', 'PAT045', 'DOC005', 'Emergency Appendectomy', TRUNC(SYSDATE) + 44 + (10/24), 60, 'OR-3', 22000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC046', 'PAT046', 'DOC006', 'Carpal Tunnel Release Surgery', TO_DATE('2024-01-10 11:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC047', 'PAT047', 'DOC007', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2024-01-17 12:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC048', 'PAT048', 'DOC008', 'Open Reduction Internal Fixation Femur', TO_DATE('2024-01-24 13:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC049', 'PAT049', 'DOC009', 'Pacemaker Implantation Procedure', TO_DATE('2024-01-31 08:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC050', 'PAT050', 'DOC010', 'Inguinal Hernia Mesh Repair', TO_DATE('2024-02-07 09:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC051', 'PAT051', 'DOC011', 'Coronary Angiography and Stent Placement', TO_DATE('2024-02-14 10:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC052', 'PAT052', 'DOC012', 'Laparoscopic Cholecystectomy', TO_DATE('2024-02-21 11:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC053', 'PAT053', 'DOC013', 'Total Knee Arthroplasty', TRUNC(SYSDATE) + 52 + (10/24), 150, 'OR-2', 85000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC054', 'PAT054', 'DOC014', 'Upper Gastrointestinal Endoscopy', TO_DATE('2024-03-06 13:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC055', 'PAT055', 'DOC015', 'Emergency Appendectomy', TO_DATE('2024-03-13 08:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC056', 'PAT056', 'DOC016', 'Carpal Tunnel Release Surgery', TO_DATE('2024-03-20 09:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC057', 'PAT057', 'DOC017', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2024-03-27 10:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC058', 'PAT058', 'DOC018', 'Open Reduction Internal Fixation Femur', TO_DATE('2024-04-03 11:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC059', 'PAT059', 'DOC019', 'Pacemaker Implantation Procedure', TO_DATE('2024-04-10 12:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC060', 'PAT060', 'DOC020', 'Inguinal Hernia Mesh Repair', TO_DATE('2024-04-17 13:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC061', 'PAT061', 'DOC001', 'Coronary Angiography and Stent Placement', TRUNC(SYSDATE) + 60 + (10/24), 90, 'Cath Lab', 45000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC062', 'PAT062', 'DOC002', 'Laparoscopic Cholecystectomy', TO_DATE('2024-05-01 09:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC063', 'PAT063', 'DOC003', 'Total Knee Arthroplasty', TO_DATE('2024-05-08 10:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC064', 'PAT064', 'DOC004', 'Upper Gastrointestinal Endoscopy', TO_DATE('2024-05-15 11:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC065', 'PAT065', 'DOC005', 'Emergency Appendectomy', TO_DATE('2024-05-22 12:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC066', 'PAT066', 'DOC006', 'Carpal Tunnel Release Surgery', TO_DATE('2024-05-29 13:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC067', 'PAT067', 'DOC007', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2024-06-05 08:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC068', 'PAT068', 'DOC008', 'Open Reduction Internal Fixation Femur', TO_DATE('2024-06-12 09:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC069', 'PAT069', 'DOC009', 'Pacemaker Implantation Procedure', TRUNC(SYSDATE) + 68 + (10/24), 110, 'Cath Lab', 68000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC070', 'PAT070', 'DOC010', 'Inguinal Hernia Mesh Repair', TO_DATE('2024-06-26 11:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC071', 'PAT071', 'DOC011', 'Coronary Angiography and Stent Placement', TO_DATE('2024-07-03 12:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC072', 'PAT072', 'DOC012', 'Laparoscopic Cholecystectomy', TO_DATE('2024-07-10 13:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC073', 'PAT073', 'DOC013', 'Total Knee Arthroplasty', TO_DATE('2024-07-17 08:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC074', 'PAT074', 'DOC014', 'Upper Gastrointestinal Endoscopy', TO_DATE('2024-07-24 09:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC075', 'PAT075', 'DOC015', 'Emergency Appendectomy', TO_DATE('2024-07-31 10:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC076', 'PAT076', 'DOC016', 'Carpal Tunnel Release Surgery', TO_DATE('2024-08-07 11:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC077', 'PAT077', 'DOC017', 'Diagnostic Colonoscopy with Biopsy', TRUNC(SYSDATE) + 76 + (10/24), 50, 'Endoscopy Suite', 8200.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC078', 'PAT078', 'DOC018', 'Open Reduction Internal Fixation Femur', TO_DATE('2024-08-21 13:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC079', 'PAT079', 'DOC019', 'Pacemaker Implantation Procedure', TO_DATE('2024-08-28 08:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC080', 'PAT080', 'DOC020', 'Inguinal Hernia Mesh Repair', TO_DATE('2024-09-04 09:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC081', 'PAT081', 'DOC001', 'Coronary Angiography and Stent Placement', TO_DATE('2024-09-11 10:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC082', 'PAT082', 'DOC002', 'Laparoscopic Cholecystectomy', TO_DATE('2024-09-18 11:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC083', 'PAT083', 'DOC003', 'Total Knee Arthroplasty', TO_DATE('2024-09-25 12:00', 'YYYY-MM-DD HH24:MI'), 150, 'OR-2', 85000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC084', 'PAT084', 'DOC004', 'Upper Gastrointestinal Endoscopy', TO_DATE('2024-10-02 13:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC085', 'PAT085', 'DOC005', 'Emergency Appendectomy', TRUNC(SYSDATE) + 84 + (10/24), 60, 'OR-3', 22000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC086', 'PAT001', 'DOC006', 'Carpal Tunnel Release Surgery', TO_DATE('2024-10-16 09:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC087', 'PAT002', 'DOC007', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2024-10-23 10:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC088', 'PAT003', 'DOC008', 'Open Reduction Internal Fixation Femur', TO_DATE('2024-10-30 11:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC089', 'PAT004', 'DOC009', 'Pacemaker Implantation Procedure', TO_DATE('2024-11-06 12:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC090', 'PAT005', 'DOC010', 'Inguinal Hernia Mesh Repair', TO_DATE('2024-11-13 13:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC091', 'PAT006', 'DOC011', 'Coronary Angiography and Stent Placement', TO_DATE('2024-11-20 08:00', 'YYYY-MM-DD HH24:MI'), 90, 'Cath Lab', 45000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC092', 'PAT007', 'DOC012', 'Laparoscopic Cholecystectomy', TO_DATE('2024-11-27 09:00', 'YYYY-MM-DD HH24:MI'), 75, 'OR-1', 28000.00, 'Completed with Complications');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC093', 'PAT008', 'DOC013', 'Total Knee Arthroplasty', TRUNC(SYSDATE) + 92 + (10/24), 150, 'OR-2', 85000.00, 'Pending');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC094', 'PAT009', 'DOC014', 'Upper Gastrointestinal Endoscopy', TO_DATE('2024-12-11 11:00', 'YYYY-MM-DD HH24:MI'), 40, 'Endoscopy Suite', 6500.00, 'In-Progress');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC095', 'PAT010', 'DOC015', 'Emergency Appendectomy', TO_DATE('2024-12-18 12:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-3', 22000.00, 'Unsuccessful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC096', 'PAT011', 'DOC016', 'Carpal Tunnel Release Surgery', TO_DATE('2024-12-25 13:00', 'YYYY-MM-DD HH24:MI'), 35, 'Minor Surgery 1', 9500.00, 'Aborted');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC097', 'PAT012', 'DOC017', 'Diagnostic Colonoscopy with Biopsy', TO_DATE('2025-01-01 08:00', 'YYYY-MM-DD HH24:MI'), 50, 'Endoscopy Suite', 8200.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC098', 'PAT013', 'DOC018', 'Open Reduction Internal Fixation Femur', TO_DATE('2025-01-08 09:00', 'YYYY-MM-DD HH24:MI'), 120, 'OR-2', 52000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC099', 'PAT014', 'DOC019', 'Pacemaker Implantation Procedure', TO_DATE('2025-01-15 10:00', 'YYYY-MM-DD HH24:MI'), 110, 'Cath Lab', 68000.00, 'Successful');
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome) VALUES ('PROC100', 'PAT015', 'DOC020', 'Inguinal Hernia Mesh Repair', TO_DATE('2025-01-22 11:00', 'YYYY-MM-DD HH24:MI'), 65, 'OR-1', 19500.00, 'Completed with Complications');

COMMIT;

-- ----------------------------------------------------------------------------
-- STUDENT 5: Finance & Insurance Management Seeds (before Student 4 for Supplier FK)
-- ----------------------------------------------------------------------------

-- Source: scripts/02_seeds/student5_finance_insurance/insert_supplier.sql
-- SEED DATA: Supplier (Student 5) - 15 rows
-- Row 1 omits PhoneType ('Landline') and ContractStatus ('Active') to exercise DEFAULTS.

INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, BuildingNumber, Street, City, PostalCode) VALUES ('SUP001', 'Pharco Pharmaceuticals', 'Hossam El-Gamal', '0224180001', 'orders@pharco.eg', '12', 'El-Horreya Road', 'Alexandria', '21500');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP002', 'EIPICO Medical Supplies', 'Maged Soliman', '0224180002', 'Landline', 'supply@eipico.eg', '45', 'Tenth of Ramadan St', 'Cairo', '11511', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP003', 'Eva Pharma Egypt', 'Nermine Adel', '0224180003', 'Landline', 'hospital@evapharma.eg', '8', 'Pyramids Road', 'Giza', '12511', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP004', 'Amoun Pharmaceutical Co', 'Khaled Rashad', '0224180004', 'Landline', 'sales@amoun.eg', '22', 'Obour Industrial Blvd', 'Cairo', '11828', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP005', 'Hikma Pharma Egypt', 'Laila Mansour', '01061800005', 'Mobile', 'procurement@hikma.eg', '19', 'Smart Village Way', 'Giza', '12577', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP006', 'Sanofi Egypt Distribution', 'Sherif Kamel', '0224180006', 'Landline', 'b2b@sanofi.eg', '3', 'El-Thawra Street', 'Cairo', '11341', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP007', 'Novartis Pharma Cairo', 'Rania Fathy', '0224180007', 'Landline', 'orders@novartis.eg', '77', 'Corniche El-Nil', 'Cairo', '11431', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP008', 'GlaxoSmithKline Egypt', 'Tarek Nabil', '0224180008', 'Landline', 'care@gsk.eg', '14', 'El-Salam City Road', 'Cairo', '11772', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP009', 'Pfizer Egypt Healthcare', 'Dina Mostafa', '01161800009', 'Mobile', 'hospital@pfizer.eg', '50', 'New Cairo Ninety St', 'Cairo', '11835', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP010', 'AstraZeneca Nile Logistics', 'Wael Ibrahim', '0224180010', 'Landline', 'logistics@astrazeneca.eg', '6', 'Sheikh Zayed Ave', 'Giza', '12588', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP011', 'Sedico Pharmaceuticals', 'Heba Zaki', '0224180011', 'Landline', 'orders@sedico.eg', '31', 'Sixth of October Blvd', 'Giza', '12566', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP012', 'Minapharm Biologics', 'Omar Hegazy', '0224180012', 'Landline', 'biologics@minapharm.eg', '16', 'Badr Industrial St', 'Cairo', '11829', 'Under Review');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP013', 'Rameda Medical Group', 'Salma Tawfik', '01261800013', 'Mobile', 'supply@rameda.eg', '9', 'Industrial Zone Road', 'Giza', '12568', 'Active');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP014', 'Delta Nile Diagnostics', 'Youssef Samir', '0224180014', 'Landline', 'info@deltanile.eg', '28', 'El-Gomhoreya Street', 'Mansoura', '35511', 'Inactive');
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus) VALUES ('SUP015', 'Alexandria MedTech Corp', 'Nadia Barakat', '0224180015', 'Landline', 'contracts@alexmedtech.eg', '41', 'Fouad Street', 'Alexandria', '21519', 'Terminated');

COMMIT;

-- Source: scripts/02_seeds/student5_finance_insurance/insert_insurance.sql
-- SEED DATA: Insurance (Student 5) - 100 rows
-- Row 1 omits InsuranceStatus to exercise DEFAULT ('Active').

INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate) VALUES ('INS001', 'PAT001', 'AXA Egypt', 'POL-AXA-0001', 80.00, TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) + 365);
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS002', 'PAT002', 'Bupa Egypt', 'POL-BUP-0002', 60.00, TRUNC(SYSDATE) - 35, TRUNC(SYSDATE) + 100, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS003', 'PAT003', 'Allianz Egypt', 'POL-ALL-0003', 70.00, TRUNC(SYSDATE) - 40, TRUNC(SYSDATE) + 110, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS004', 'PAT004', 'MetLife Egypt', 'POL-MET-0004', 75.00, TRUNC(SYSDATE) - 45, TRUNC(SYSDATE) + 120, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS005', 'PAT005', 'Misr Insurance', 'POL-MIS-0005', 80.00, TRUNC(SYSDATE) - 50, TRUNC(SYSDATE) + 130, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS006', 'PAT006', 'GIG Egypt', 'POL-GIG-0006', 85.00, TRUNC(SYSDATE) - 55, TRUNC(SYSDATE) + 140, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS007', 'PAT007', 'Delta Insurance', 'POL-DEL-0007', 90.00, TRUNC(SYSDATE) - 60, TRUNC(SYSDATE) + 150, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS008', 'PAT008', 'Universal Health Insurance', 'POL-UNI-0008', 100.00, TRUNC(SYSDATE) - 65, TRUNC(SYSDATE) + 160, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS009', 'PAT009', 'AXA Egypt', 'POL-AXA-0009', 50.00, TRUNC(SYSDATE) - 70, TRUNC(SYSDATE) + 170, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS010', 'PAT010', 'Bupa Egypt', 'POL-BUP-0010', 60.00, TRUNC(SYSDATE) - 75, TRUNC(SYSDATE) + 180, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS011', 'PAT011', 'Allianz Egypt', 'POL-ALL-0011', 70.00, TRUNC(SYSDATE) - 80, TRUNC(SYSDATE) + 190, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS012', 'PAT012', 'MetLife Egypt', 'POL-MET-0012', 75.00, TRUNC(SYSDATE) - 85, TRUNC(SYSDATE) + 200, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS013', 'PAT013', 'Misr Insurance', 'POL-MIS-0013', 80.00, TRUNC(SYSDATE) - 90, TRUNC(SYSDATE) + 210, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS014', 'PAT014', 'GIG Egypt', 'POL-GIG-0014', 85.00, TRUNC(SYSDATE) - 95, TRUNC(SYSDATE) + 220, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS015', 'PAT015', 'Delta Insurance', 'POL-DEL-0015', 90.00, TRUNC(SYSDATE) - 100, TRUNC(SYSDATE) + 230, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS016', 'PAT016', 'Universal Health Insurance', 'POL-UNI-0016', 100.00, TRUNC(SYSDATE) - 105, TRUNC(SYSDATE) + 240, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS017', 'PAT017', 'AXA Egypt', 'POL-AXA-0017', 50.00, TRUNC(SYSDATE) - 110, TRUNC(SYSDATE) + 250, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS018', 'PAT018', 'Bupa Egypt', 'POL-BUP-0018', 60.00, TRUNC(SYSDATE) - 115, TRUNC(SYSDATE) + 260, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS019', 'PAT019', 'Allianz Egypt', 'POL-ALL-0019', 70.00, TRUNC(SYSDATE) - 120, TRUNC(SYSDATE) + 270, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS020', 'PAT020', 'MetLife Egypt', 'POL-MET-0020', 75.00, TRUNC(SYSDATE) - 125, TRUNC(SYSDATE) + 280, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS021', 'PAT021', 'Misr Insurance', 'POL-MIS-0021', 80.00, TRUNC(SYSDATE) - 130, TRUNC(SYSDATE) + 290, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS022', 'PAT022', 'GIG Egypt', 'POL-GIG-0022', 85.00, TRUNC(SYSDATE) - 135, TRUNC(SYSDATE) + 300, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS023', 'PAT023', 'Delta Insurance', 'POL-DEL-0023', 90.00, TRUNC(SYSDATE) - 140, TRUNC(SYSDATE) + 310, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS024', 'PAT024', 'Universal Health Insurance', 'POL-UNI-0024', 100.00, TRUNC(SYSDATE) - 145, TRUNC(SYSDATE) + 320, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS025', 'PAT025', 'AXA Egypt', 'POL-AXA-0025', 50.00, TRUNC(SYSDATE) - 150, TRUNC(SYSDATE) + 330, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS026', 'PAT026', 'Bupa Egypt', 'POL-BUP-0026', 60.00, TRUNC(SYSDATE) - 155, TRUNC(SYSDATE) + 340, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS027', 'PAT027', 'Allianz Egypt', 'POL-ALL-0027', 70.00, TRUNC(SYSDATE) - 160, TRUNC(SYSDATE) + 350, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS028', 'PAT028', 'MetLife Egypt', 'POL-MET-0028', 75.00, TRUNC(SYSDATE) - 165, TRUNC(SYSDATE) + 360, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS029', 'PAT029', 'Misr Insurance', 'POL-MIS-0029', 80.00, TRUNC(SYSDATE) - 170, TRUNC(SYSDATE) + 370, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS030', 'PAT030', 'GIG Egypt', 'POL-GIG-0030', 85.00, TRUNC(SYSDATE) - 175, TRUNC(SYSDATE) + 380, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS031', 'PAT031', 'Delta Insurance', 'POL-DEL-0031', 90.00, TRUNC(SYSDATE) - 180, TRUNC(SYSDATE) + 390, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS032', 'PAT032', 'Universal Health Insurance', 'POL-UNI-0032', 100.00, TRUNC(SYSDATE) - 185, TRUNC(SYSDATE) + 400, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS033', 'PAT033', 'AXA Egypt', 'POL-AXA-0033', 50.00, TRUNC(SYSDATE) - 190, TRUNC(SYSDATE) + 410, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS034', 'PAT034', 'Bupa Egypt', 'POL-BUP-0034', 60.00, TRUNC(SYSDATE) - 195, TRUNC(SYSDATE) + 420, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS035', 'PAT035', 'Allianz Egypt', 'POL-ALL-0035', 70.00, TRUNC(SYSDATE) - 200, TRUNC(SYSDATE) + 430, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS036', 'PAT036', 'MetLife Egypt', 'POL-MET-0036', 75.00, TRUNC(SYSDATE) - 205, TRUNC(SYSDATE) + 440, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS037', 'PAT037', 'Misr Insurance', 'POL-MIS-0037', 80.00, TRUNC(SYSDATE) - 210, TRUNC(SYSDATE) + 450, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS038', 'PAT038', 'GIG Egypt', 'POL-GIG-0038', 85.00, TRUNC(SYSDATE) - 215, TRUNC(SYSDATE) + 95, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS039', 'PAT039', 'Delta Insurance', 'POL-DEL-0039', 90.00, TRUNC(SYSDATE) - 220, TRUNC(SYSDATE) + 105, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS040', 'PAT040', 'Universal Health Insurance', 'POL-UNI-0040', 100.00, TRUNC(SYSDATE) - 225, TRUNC(SYSDATE) + 115, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS041', 'PAT041', 'AXA Egypt', 'POL-AXA-0041', 50.00, TRUNC(SYSDATE) - 230, TRUNC(SYSDATE) + 125, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS042', 'PAT042', 'Bupa Egypt', 'POL-BUP-0042', 60.00, TRUNC(SYSDATE) - 235, TRUNC(SYSDATE) + 135, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS043', 'PAT043', 'Allianz Egypt', 'POL-ALL-0043', 70.00, TRUNC(SYSDATE) - 240, TRUNC(SYSDATE) + 145, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS044', 'PAT044', 'MetLife Egypt', 'POL-MET-0044', 75.00, TRUNC(SYSDATE) - 245, TRUNC(SYSDATE) + 155, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS045', 'PAT045', 'Misr Insurance', 'POL-MIS-0045', 80.00, TRUNC(SYSDATE) - 250, TRUNC(SYSDATE) + 165, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS046', 'PAT046', 'GIG Egypt', 'POL-GIG-0046', 85.00, TRUNC(SYSDATE) - 255, TRUNC(SYSDATE) + 175, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS047', 'PAT047', 'Delta Insurance', 'POL-DEL-0047', 90.00, TRUNC(SYSDATE) - 260, TRUNC(SYSDATE) + 185, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS048', 'PAT048', 'Universal Health Insurance', 'POL-UNI-0048', 100.00, TRUNC(SYSDATE) - 265, TRUNC(SYSDATE) + 195, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS049', 'PAT049', 'AXA Egypt', 'POL-AXA-0049', 50.00, TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) + 205, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS050', 'PAT050', 'Bupa Egypt', 'POL-BUP-0050', 60.00, TRUNC(SYSDATE) - 35, TRUNC(SYSDATE) + 215, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS051', 'PAT051', 'Allianz Egypt', 'POL-ALL-0051', 70.00, TRUNC(SYSDATE) - 40, TRUNC(SYSDATE) + 225, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS052', 'PAT052', 'MetLife Egypt', 'POL-MET-0052', 75.00, TRUNC(SYSDATE) - 45, TRUNC(SYSDATE) + 235, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS053', 'PAT053', 'Misr Insurance', 'POL-MIS-0053', 80.00, TRUNC(SYSDATE) - 50, TRUNC(SYSDATE) + 245, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS054', 'PAT054', 'GIG Egypt', 'POL-GIG-0054', 85.00, TRUNC(SYSDATE) - 55, TRUNC(SYSDATE) + 255, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS055', 'PAT055', 'Delta Insurance', 'POL-DEL-0055', 90.00, TRUNC(SYSDATE) - 60, TRUNC(SYSDATE) + 265, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS056', 'PAT056', 'Universal Health Insurance', 'POL-UNI-0056', 100.00, TRUNC(SYSDATE) - 65, TRUNC(SYSDATE) + 275, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS057', 'PAT057', 'AXA Egypt', 'POL-AXA-0057', 50.00, TRUNC(SYSDATE) - 70, TRUNC(SYSDATE) + 285, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS058', 'PAT058', 'Bupa Egypt', 'POL-BUP-0058', 60.00, TRUNC(SYSDATE) - 75, TRUNC(SYSDATE) + 295, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS059', 'PAT059', 'Allianz Egypt', 'POL-ALL-0059', 70.00, TRUNC(SYSDATE) - 80, TRUNC(SYSDATE) + 305, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS060', 'PAT060', 'MetLife Egypt', 'POL-MET-0060', 75.00, TRUNC(SYSDATE) - 85, TRUNC(SYSDATE) + 315, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS061', 'PAT061', 'Misr Insurance', 'POL-MIS-0061', 80.00, TRUNC(SYSDATE) - 90, TRUNC(SYSDATE) + 325, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS062', 'PAT062', 'GIG Egypt', 'POL-GIG-0062', 85.00, TRUNC(SYSDATE) - 95, TRUNC(SYSDATE) + 335, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS063', 'PAT063', 'Delta Insurance', 'POL-DEL-0063', 90.00, TRUNC(SYSDATE) - 100, TRUNC(SYSDATE) + 345, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS064', 'PAT064', 'Universal Health Insurance', 'POL-UNI-0064', 100.00, TRUNC(SYSDATE) - 105, TRUNC(SYSDATE) + 355, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS065', 'PAT065', 'AXA Egypt', 'POL-AXA-0065', 50.00, TRUNC(SYSDATE) - 110, TRUNC(SYSDATE) + 365, 'Active');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS066', 'PAT001', 'Misr Insurance', 'POL-MIS-0066', 60.00, DATE '2023-07-15', DATE '2024-07-14', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS067', 'PAT002', 'GIG Egypt', 'POL-GIG-0067', 70.00, DATE '2023-07-18', DATE '2024-07-17', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS068', 'PAT003', 'Delta Insurance', 'POL-DEL-0068', 75.00, DATE '2023-07-21', DATE '2024-07-20', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS069', 'PAT004', 'Universal Health Insurance', 'POL-UNI-0069', 80.00, DATE '2023-07-24', DATE '2024-07-23', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS070', 'PAT005', 'AXA Egypt', 'POL-AXA-0070', 85.00, DATE '2023-07-27', DATE '2024-07-26', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS071', 'PAT006', 'Bupa Egypt', 'POL-BUP-0071', 90.00, DATE '2023-07-30', DATE '2024-07-29', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS072', 'PAT007', 'Allianz Egypt', 'POL-ALL-0072', 100.00, DATE '2023-08-02', DATE '2024-08-01', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS073', 'PAT008', 'MetLife Egypt', 'POL-MET-0073', 50.00, DATE '2023-08-05', DATE '2024-08-04', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS074', 'PAT009', 'Misr Insurance', 'POL-MIS-0074', 60.00, DATE '2023-08-08', DATE '2024-08-07', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS075', 'PAT010', 'GIG Egypt', 'POL-GIG-0075', 70.00, DATE '2023-08-11', DATE '2024-08-10', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS076', 'PAT011', 'Delta Insurance', 'POL-DEL-0076', 75.00, DATE '2023-08-14', DATE '2024-08-13', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS077', 'PAT012', 'Universal Health Insurance', 'POL-UNI-0077', 80.00, DATE '2023-08-17', DATE '2024-08-16', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS078', 'PAT013', 'AXA Egypt', 'POL-AXA-0078', 85.00, DATE '2023-08-20', DATE '2024-08-19', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS079', 'PAT014', 'Bupa Egypt', 'POL-BUP-0079', 90.00, DATE '2023-08-23', DATE '2024-08-22', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS080', 'PAT015', 'Allianz Egypt', 'POL-ALL-0080', 100.00, DATE '2023-08-26', DATE '2024-08-25', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS081', 'PAT016', 'MetLife Egypt', 'POL-MET-0081', 50.00, DATE '2023-08-29', DATE '2024-08-28', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS082', 'PAT017', 'Misr Insurance', 'POL-MIS-0082', 60.00, DATE '2023-09-01', DATE '2024-08-31', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS083', 'PAT018', 'GIG Egypt', 'POL-GIG-0083', 70.00, DATE '2023-09-04', DATE '2024-09-03', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS084', 'PAT019', 'Delta Insurance', 'POL-DEL-0084', 75.00, DATE '2023-09-07', DATE '2024-09-06', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS085', 'PAT020', 'Universal Health Insurance', 'POL-UNI-0085', 80.00, DATE '2023-09-10', DATE '2024-09-09', 'Expired');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS086', 'PAT066', 'GIG Egypt', 'POL-GIG-0086', 85.00, DATE '2024-07-20', DATE '2025-07-21', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS087', 'PAT067', 'Delta Insurance', 'POL-DEL-0087', 90.00, DATE '2024-07-22', DATE '2025-07-23', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS088', 'PAT068', 'Universal Health Insurance', 'POL-UNI-0088', 100.00, DATE '2024-07-24', DATE '2025-07-25', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS089', 'PAT069', 'AXA Egypt', 'POL-AXA-0089', 50.00, DATE '2024-07-26', DATE '2025-07-27', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS090', 'PAT070', 'Bupa Egypt', 'POL-BUP-0090', 60.00, DATE '2024-07-28', DATE '2025-07-29', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS091', 'PAT071', 'Allianz Egypt', 'POL-ALL-0091', 70.00, DATE '2024-07-30', DATE '2025-07-31', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS092', 'PAT072', 'MetLife Egypt', 'POL-MET-0092', 75.00, DATE '2024-08-01', DATE '2025-08-02', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS093', 'PAT073', 'Misr Insurance', 'POL-MIS-0093', 80.00, DATE '2024-08-03', DATE '2025-08-04', 'Cancelled');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS094', 'PAT081', 'GIG Egypt', 'POL-GIG-0094', 85.00, DATE '2024-12-04', TRUNC(SYSDATE) + 213, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS095', 'PAT082', 'Delta Insurance', 'POL-DEL-0095', 90.00, DATE '2024-12-06', TRUNC(SYSDATE) + 214, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS096', 'PAT083', 'Universal Health Insurance', 'POL-UNI-0096', 100.00, DATE '2024-12-08', TRUNC(SYSDATE) + 215, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS097', 'PAT084', 'AXA Egypt', 'POL-AXA-0097', 50.00, DATE '2024-12-10', TRUNC(SYSDATE) + 216, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS098', 'PAT085', 'Bupa Egypt', 'POL-BUP-0098', 60.00, DATE '2024-12-12', TRUNC(SYSDATE) + 217, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS099', 'PAT086', 'Allianz Egypt', 'POL-ALL-0099', 70.00, DATE '2024-12-14', TRUNC(SYSDATE) + 218, 'Suspended');
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus) VALUES ('INS100', 'PAT087', 'MetLife Egypt', 'POL-MET-0100', 75.00, DATE '2024-12-16', TRUNC(SYSDATE) + 219, 'Suspended');

COMMIT;

-- Source: scripts/02_seeds/student5_finance_insurance/insert_invoice.sql
-- SEED DATA: Invoice (Student 5) - 200 rows
-- Row 1 omits InvoiceDate (SYSDATE), Discount (0.00), DueDate (SYSDATE + 3), and PaymentStatus ('Unpaid').
-- Note: trg_inv_status_guard requires new invoices to be inserted as Unpaid/Overdue; Payment inserts update them to Paid/Partially Paid.

INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount) VALUES ('INV001', 'PAT001', 1500.00);
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV002', 'PAT002', DATE '2024-03-04', 730.00, 36.50, DATE '2024-03-07', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV003', 'PAT003', DATE '2024-03-07', 950.00, 47.50, DATE '2024-03-10', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV004', 'PAT004', DATE '2024-03-10', 1350.00, 67.50, DATE '2024-03-13', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV005', 'PAT005', DATE '2024-03-13', 2600.00, 0.00, DATE '2024-03-16', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV006', 'PAT006', DATE '2024-03-16', 4000.00, 200.00, DATE '2024-03-19', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV007', 'PAT007', DATE '2024-03-19', 5900.00, 295.00, DATE '2024-03-22', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV008', 'PAT008', DATE '2024-03-22', 8200.00, 410.00, DATE '2024-03-25', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV009', 'PAT009', DATE '2024-03-25', 12550.00, 0.00, DATE '2024-03-28', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV010', 'PAT010', DATE '2024-03-28', 24100.00, 1205.00, DATE '2024-03-31', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV011', 'PAT011', DATE '2024-03-31', 600.00, 30.00, DATE '2024-04-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV012', 'PAT012', DATE '2024-04-03', 880.00, 44.00, DATE '2024-04-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV013', 'PAT013', DATE '2024-04-06', 1100.00, 0.00, DATE '2024-04-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV014', 'PAT014', DATE '2024-04-09', 1500.00, 75.00, DATE '2024-04-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV015', 'PAT015', DATE '2024-04-12', 2400.00, 120.00, DATE '2024-04-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV016', 'PAT016', DATE '2024-04-15', 3800.00, 190.00, DATE '2024-04-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV017', 'PAT017', DATE '2024-04-18', 5700.00, 0.00, DATE '2024-04-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV018', 'PAT018', DATE '2024-04-21', 8350.00, 417.50, DATE '2024-04-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV019', 'PAT019', DATE '2024-04-24', 12700.00, 635.00, DATE '2024-04-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV020', 'PAT020', DATE '2024-04-27', 24250.00, 1212.50, DATE '2024-04-30', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV021', 'PAT021', DATE '2024-04-30', 750.00, 0.00, DATE '2024-05-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV022', 'PAT022', DATE '2024-05-03', 680.00, 34.00, DATE '2024-05-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV023', 'PAT023', DATE '2024-05-06', 900.00, 45.00, DATE '2024-05-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV024', 'PAT024', DATE '2024-05-09', 1300.00, 65.00, DATE '2024-05-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV025', 'PAT025', DATE '2024-05-12', 2550.00, 0.00, DATE '2024-05-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV026', 'PAT026', DATE '2024-05-15', 3950.00, 197.50, DATE '2024-05-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV027', 'PAT027', DATE '2024-05-18', 5850.00, 292.50, DATE '2024-05-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV028', 'PAT028', DATE '2024-05-21', 8500.00, 425.00, DATE '2024-05-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV029', 'PAT029', DATE '2024-05-24', 12500.00, 0.00, DATE '2024-05-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV030', 'PAT030', DATE '2024-05-27', 24050.00, 1202.50, DATE '2024-05-30', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV031', 'PAT031', DATE '2024-05-30', 550.00, 27.50, DATE '2024-06-02', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV032', 'PAT032', DATE '2024-06-02', 830.00, 41.50, DATE '2024-06-05', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV033', 'PAT033', DATE '2024-06-05', 1050.00, 0.00, DATE '2024-06-08', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV034', 'PAT034', DATE '2024-06-08', 1450.00, 72.50, DATE '2024-06-11', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV035', 'PAT035', DATE '2024-06-11', 2700.00, 135.00, DATE '2024-06-14', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV036', 'PAT036', DATE '2024-06-14', 3750.00, 187.50, DATE '2024-06-17', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV037', 'PAT037', DATE '2024-06-17', 5650.00, 0.00, DATE '2024-06-20', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV038', 'PAT038', DATE '2024-06-20', 8300.00, 415.00, DATE '2024-06-23', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV039', 'PAT039', DATE '2024-06-23', 12650.00, 632.50, DATE '2024-06-26', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV040', 'PAT040', DATE '2024-06-26', 24200.00, 1210.00, DATE '2024-06-29', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV041', 'PAT041', DATE '2024-06-29', 700.00, 0.00, DATE '2024-07-02', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV042', 'PAT042', DATE '2024-07-02', 980.00, 49.00, DATE '2024-07-05', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV043', 'PAT043', DATE '2024-07-05', 850.00, 42.50, DATE '2024-07-08', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV044', 'PAT044', DATE '2024-07-08', 1250.00, 62.50, DATE '2024-07-11', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV045', 'PAT045', DATE '2024-07-11', 2500.00, 0.00, DATE '2024-07-14', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV046', 'PAT046', DATE '2024-07-14', 3900.00, 195.00, DATE '2024-07-17', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV047', 'PAT047', DATE '2024-07-17', 5800.00, 290.00, DATE '2024-07-20', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV048', 'PAT048', DATE '2024-07-20', 8450.00, 422.50, DATE '2024-07-23', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV049', 'PAT049', DATE '2024-07-23', 12800.00, 0.00, DATE '2024-07-26', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV050', 'PAT050', DATE '2024-07-26', 24000.00, 1200.00, DATE '2024-07-29', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV051', 'PAT051', DATE '2024-07-29', 500.00, 25.00, DATE '2024-08-01', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV052', 'PAT052', DATE '2024-08-01', 780.00, 39.00, DATE '2024-08-04', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV053', 'PAT053', DATE '2024-08-04', 1000.00, 0.00, DATE '2024-08-07', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV054', 'PAT054', DATE '2024-08-07', 1400.00, 70.00, DATE '2024-08-10', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV055', 'PAT055', DATE '2024-08-10', 2650.00, 132.50, DATE '2024-08-13', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV056', 'PAT056', DATE '2024-08-13', 4050.00, 202.50, DATE '2024-08-16', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV057', 'PAT057', DATE '2024-08-16', 5600.00, 0.00, DATE '2024-08-19', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV058', 'PAT058', DATE '2024-08-19', 8250.00, 412.50, DATE '2024-08-22', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV059', 'PAT059', DATE '2024-08-22', 12600.00, 630.00, DATE '2024-08-25', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV060', 'PAT060', DATE '2024-08-25', 24150.00, 1207.50, DATE '2024-08-28', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV061', 'PAT061', DATE '2024-08-28', 650.00, 0.00, DATE '2024-08-31', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV062', 'PAT062', DATE '2024-08-31', 930.00, 46.50, DATE '2024-09-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV063', 'PAT063', DATE '2024-09-03', 1150.00, 57.50, DATE '2024-09-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV064', 'PAT064', DATE '2024-09-06', 1200.00, 60.00, DATE '2024-09-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV065', 'PAT065', DATE '2024-09-09', 2450.00, 0.00, DATE '2024-09-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV066', 'PAT066', DATE '2024-09-12', 3850.00, 192.50, DATE '2024-09-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV067', 'PAT067', DATE '2024-09-15', 5750.00, 287.50, DATE '2024-09-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV068', 'PAT068', DATE '2024-09-18', 8400.00, 420.00, DATE '2024-09-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV069', 'PAT069', DATE '2024-09-21', 12750.00, 0.00, DATE '2024-09-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV070', 'PAT070', DATE '2024-09-24', 24300.00, 1215.00, DATE '2024-09-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV071', 'PAT071', DATE '2024-09-27', 450.00, 22.50, DATE '2024-09-30', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV072', 'PAT072', DATE '2024-09-30', 730.00, 36.50, DATE '2024-10-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV073', 'PAT073', DATE '2024-10-03', 950.00, 0.00, DATE '2024-10-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV074', 'PAT074', DATE '2024-10-06', 1350.00, 67.50, DATE '2024-10-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV075', 'PAT075', DATE '2024-10-09', 2600.00, 130.00, DATE '2024-10-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV076', 'PAT076', DATE '2024-10-12', 4000.00, 200.00, DATE '2024-10-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV077', 'PAT077', DATE '2024-10-15', 5900.00, 0.00, DATE '2024-10-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV078', 'PAT078', DATE '2024-10-18', 8200.00, 410.00, DATE '2024-10-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV079', 'PAT079', DATE '2024-10-21', 12550.00, 627.50, DATE '2024-10-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV080', 'PAT080', DATE '2024-10-24', 24100.00, 1205.00, DATE '2024-10-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV081', 'PAT081', DATE '2024-10-27', 600.00, 0.00, DATE '2024-10-30', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV082', 'PAT082', DATE '2024-10-30', 880.00, 44.00, DATE '2024-11-02', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV083', 'PAT083', DATE '2024-11-02', 1100.00, 55.00, DATE '2024-11-05', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV084', 'PAT084', DATE '2024-11-05', 1500.00, 75.00, DATE '2024-11-08', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV085', 'PAT085', DATE '2024-11-08', 2400.00, 0.00, DATE '2024-11-11', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV086', 'PAT086', DATE '2024-11-11', 3800.00, 190.00, DATE '2024-11-14', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV087', 'PAT087', DATE '2024-11-14', 5700.00, 285.00, DATE '2024-11-17', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV088', 'PAT088', DATE '2024-11-17', 8350.00, 417.50, DATE '2024-11-20', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV089', 'PAT089', DATE '2024-11-20', 12700.00, 0.00, DATE '2024-11-23', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV090', 'PAT090', DATE '2024-11-23', 24250.00, 1212.50, DATE '2024-11-26', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV091', 'PAT091', DATE '2024-11-26', 750.00, 37.50, DATE '2024-11-29', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV092', 'PAT092', DATE '2024-11-29', 680.00, 34.00, DATE '2024-12-02', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV093', 'PAT093', DATE '2024-12-02', 900.00, 0.00, DATE '2024-12-05', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV094', 'PAT094', DATE '2024-12-05', 1300.00, 65.00, DATE '2024-12-08', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV095', 'PAT095', DATE '2024-12-08', 2550.00, 127.50, DATE '2024-12-11', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV096', 'PAT096', DATE '2024-12-11', 3950.00, 197.50, DATE '2024-12-14', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV097', 'PAT097', DATE '2024-12-14', 5850.00, 0.00, DATE '2024-12-17', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV098', 'PAT098', DATE '2024-12-17', 8500.00, 425.00, DATE '2024-12-20', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV099', 'PAT099', DATE '2024-12-20', 12500.00, 625.00, DATE '2024-12-23', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV100', 'PAT100', DATE '2024-12-23', 24050.00, 1202.50, DATE '2024-12-26', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV101', 'PAT001', DATE '2024-12-26', 550.00, 0.00, DATE '2024-12-29', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV102', 'PAT002', DATE '2024-12-29', 830.00, 41.50, DATE '2025-01-01', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV103', 'PAT003', DATE '2025-01-01', 1050.00, 52.50, DATE '2025-01-04', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV104', 'PAT004', DATE '2025-01-04', 1450.00, 72.50, DATE '2025-01-07', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV105', 'PAT005', DATE '2025-01-07', 2700.00, 0.00, DATE '2025-01-10', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV106', 'PAT006', DATE '2025-01-10', 3750.00, 187.50, DATE '2025-01-13', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV107', 'PAT007', DATE '2025-01-13', 5650.00, 282.50, DATE '2025-01-16', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV108', 'PAT008', DATE '2025-01-16', 8300.00, 415.00, DATE '2025-01-19', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV109', 'PAT009', DATE '2025-01-19', 12650.00, 0.00, DATE '2025-01-22', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV110', 'PAT010', DATE '2025-01-22', 24200.00, 1210.00, DATE '2025-01-25', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV111', 'PAT011', DATE '2025-01-25', 700.00, 35.00, DATE '2025-01-28', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV112', 'PAT012', DATE '2025-01-28', 980.00, 49.00, DATE '2025-01-31', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV113', 'PAT013', DATE '2025-01-31', 850.00, 0.00, DATE '2025-02-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV114', 'PAT014', DATE '2025-02-03', 1250.00, 62.50, DATE '2025-02-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV115', 'PAT015', DATE '2025-02-06', 2500.00, 125.00, DATE '2025-02-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV116', 'PAT016', DATE '2025-02-09', 3900.00, 195.00, DATE '2025-02-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV117', 'PAT017', DATE '2025-02-12', 5800.00, 0.00, DATE '2025-02-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV118', 'PAT018', DATE '2025-02-15', 8450.00, 422.50, DATE '2025-02-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV119', 'PAT019', DATE '2025-02-18', 12800.00, 640.00, DATE '2025-02-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV120', 'PAT020', DATE '2025-02-21', 24000.00, 1200.00, DATE '2025-02-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV121', 'PAT021', DATE '2025-02-24', 500.00, 0.00, DATE '2025-02-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV122', 'PAT022', DATE '2025-02-27', 780.00, 39.00, DATE '2025-03-02', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV123', 'PAT023', DATE '2025-03-02', 1000.00, 50.00, DATE '2025-03-05', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV124', 'PAT024', DATE '2025-03-05', 1400.00, 70.00, DATE '2025-03-08', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV125', 'PAT025', DATE '2025-03-08', 2650.00, 0.00, DATE '2025-03-11', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV126', 'PAT026', DATE '2025-03-11', 4050.00, 202.50, DATE '2025-03-14', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV127', 'PAT027', DATE '2025-03-14', 5600.00, 280.00, DATE '2025-03-17', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV128', 'PAT028', DATE '2025-03-17', 8250.00, 412.50, DATE '2025-03-20', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV129', 'PAT029', DATE '2025-03-20', 12600.00, 0.00, DATE '2025-03-23', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV130', 'PAT030', DATE '2025-03-23', 24150.00, 1207.50, DATE '2025-03-26', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV131', 'PAT031', DATE '2025-03-26', 650.00, 32.50, DATE '2025-03-29', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV132', 'PAT032', DATE '2025-03-29', 930.00, 46.50, DATE '2025-04-01', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV133', 'PAT033', DATE '2025-04-01', 1150.00, 0.00, DATE '2025-04-04', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV134', 'PAT034', DATE '2025-04-04', 1200.00, 60.00, DATE '2025-04-07', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV135', 'PAT035', DATE '2025-04-07', 2450.00, 122.50, DATE '2025-04-10', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV136', 'PAT036', DATE '2025-04-10', 3850.00, 192.50, DATE '2025-04-13', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV137', 'PAT037', DATE '2025-04-13', 5750.00, 0.00, DATE '2025-04-16', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV138', 'PAT038', DATE '2025-04-16', 8400.00, 420.00, DATE '2025-04-19', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV139', 'PAT039', DATE '2025-04-19', 12750.00, 637.50, DATE '2025-04-22', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV140', 'PAT040', DATE '2025-04-22', 24300.00, 1215.00, DATE '2025-04-25', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV141', 'PAT041', DATE '2025-04-25', 450.00, 0.00, DATE '2025-04-28', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV142', 'PAT042', DATE '2025-04-28', 730.00, 36.50, DATE '2025-05-01', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV143', 'PAT043', DATE '2025-05-01', 950.00, 47.50, DATE '2025-05-04', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV144', 'PAT044', DATE '2025-05-04', 1350.00, 67.50, DATE '2025-05-07', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV145', 'PAT045', DATE '2025-05-07', 2600.00, 0.00, DATE '2025-05-10', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV146', 'PAT046', DATE '2025-05-10', 4000.00, 200.00, DATE '2025-05-13', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV147', 'PAT047', DATE '2025-05-13', 5900.00, 295.00, DATE '2025-05-16', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV148', 'PAT048', DATE '2025-05-16', 8200.00, 410.00, DATE '2025-05-19', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV149', 'PAT049', DATE '2025-05-19', 12550.00, 0.00, DATE '2025-05-22', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV150', 'PAT050', DATE '2025-05-22', 24100.00, 1205.00, DATE '2025-05-25', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV151', 'PAT051', DATE '2025-05-25', 600.00, 30.00, DATE '2025-05-28', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV152', 'PAT052', DATE '2025-05-28', 880.00, 44.00, DATE '2025-05-31', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV153', 'PAT053', DATE '2025-05-31', 1100.00, 0.00, DATE '2025-06-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV154', 'PAT054', DATE '2025-06-03', 1500.00, 75.00, DATE '2025-06-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV155', 'PAT055', DATE '2025-06-06', 2400.00, 120.00, DATE '2025-06-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV156', 'PAT056', DATE '2025-06-09', 3800.00, 190.00, DATE '2025-06-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV157', 'PAT057', DATE '2025-06-12', 5700.00, 0.00, DATE '2025-06-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV158', 'PAT058', DATE '2025-06-15', 8350.00, 417.50, DATE '2025-06-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV159', 'PAT059', DATE '2025-06-18', 12700.00, 635.00, DATE '2025-06-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV160', 'PAT060', DATE '2025-06-21', 24250.00, 1212.50, DATE '2025-06-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV161', 'PAT061', DATE '2025-06-24', 750.00, 0.00, DATE '2025-06-27', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV162', 'PAT062', DATE '2025-06-27', 680.00, 34.00, DATE '2025-06-30', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV163', 'PAT063', DATE '2025-06-30', 900.00, 45.00, DATE '2025-07-03', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV164', 'PAT064', DATE '2025-07-03', 1300.00, 65.00, DATE '2025-07-06', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV165', 'PAT065', DATE '2025-07-06', 2550.00, 0.00, DATE '2025-07-09', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV166', 'PAT066', DATE '2025-07-09', 3950.00, 197.50, DATE '2025-07-12', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV167', 'PAT067', DATE '2025-07-12', 5850.00, 292.50, DATE '2025-07-15', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV168', 'PAT068', DATE '2025-07-15', 8500.00, 425.00, DATE '2025-07-18', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV169', 'PAT069', DATE '2025-07-18', 12500.00, 0.00, DATE '2025-07-21', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV170', 'PAT070', DATE '2025-07-21', 24050.00, 1202.50, DATE '2025-07-24', 'Overdue');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV171', 'PAT071', TRUNC(SYSDATE) - 1, 550.00, 27.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV172', 'PAT072', TRUNC(SYSDATE) - 1, 830.00, 41.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV173', 'PAT073', TRUNC(SYSDATE) - 1, 1050.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV174', 'PAT074', TRUNC(SYSDATE) - 1, 1450.00, 72.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV175', 'PAT075', TRUNC(SYSDATE) - 1, 2700.00, 135.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV176', 'PAT076', TRUNC(SYSDATE) - 1, 3750.00, 187.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV177', 'PAT077', TRUNC(SYSDATE) - 1, 5650.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV178', 'PAT078', TRUNC(SYSDATE) - 1, 8300.00, 415.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV179', 'PAT079', TRUNC(SYSDATE) - 1, 12650.00, 632.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV180', 'PAT080', TRUNC(SYSDATE) - 1, 24200.00, 1210.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV181', 'PAT081', TRUNC(SYSDATE) - 1, 700.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV182', 'PAT082', TRUNC(SYSDATE) - 1, 980.00, 49.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV183', 'PAT083', TRUNC(SYSDATE) - 1, 850.00, 42.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV184', 'PAT084', TRUNC(SYSDATE) - 1, 1250.00, 62.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV185', 'PAT085', TRUNC(SYSDATE) - 1, 2500.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV186', 'PAT086', TRUNC(SYSDATE) - 1, 3900.00, 195.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV187', 'PAT087', TRUNC(SYSDATE) - 1, 5800.00, 290.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV188', 'PAT088', TRUNC(SYSDATE) - 1, 8450.00, 422.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV189', 'PAT089', TRUNC(SYSDATE) - 1, 12800.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV190', 'PAT090', TRUNC(SYSDATE) - 1, 24000.00, 1200.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV191', 'PAT091', TRUNC(SYSDATE) - 1, 500.00, 25.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV192', 'PAT092', TRUNC(SYSDATE) - 1, 780.00, 39.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV193', 'PAT093', TRUNC(SYSDATE) - 1, 1000.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV194', 'PAT094', TRUNC(SYSDATE) - 1, 1400.00, 70.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV195', 'PAT095', TRUNC(SYSDATE) - 1, 2650.00, 132.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV196', 'PAT096', TRUNC(SYSDATE) - 1, 4050.00, 202.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV197', 'PAT097', TRUNC(SYSDATE) - 1, 5600.00, 0.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV198', 'PAT098', TRUNC(SYSDATE) - 1, 8250.00, 412.50, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV199', 'PAT099', TRUNC(SYSDATE) - 1, 12600.00, 630.00, TRUNC(SYSDATE) + 2, 'Unpaid');
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus) VALUES ('INV200', 'PAT100', TRUNC(SYSDATE) - 1, 24150.00, 1207.50, TRUNC(SYSDATE) + 2, 'Unpaid');

COMMIT;

-- Source: scripts/02_seeds/student5_finance_insurance/insert_payment.sql
-- SEED DATA: Payment (Student 5) - 250 rows
-- Row 1 omits PaymentDate (SYSDATE) and PaymentStatus ('Completed') to exercise DEFAULTS.

INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference) VALUES ('PAY001', 'INV002', 730.00, 'Debit Card', 'TXN-2026-00001');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY002', 'INV003', DATE '2024-03-08', 950.00, 'Bank Transfer', 'TXN-2026-00002', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY003', 'INV004', DATE '2024-03-11', 1417.50, 'Insurance Claim', 'TXN-2026-00003', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY004', 'INV005', DATE '2024-03-14', 2860.00, 'Credit Card', 'TXN-2026-00004', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY005', 'INV006', DATE '2024-03-17', 4200.00, 'Debit Card', 'TXN-2026-00005', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY006', 'INV007', DATE '2024-03-20', 6195.00, 'Bank Transfer', 'TXN-2026-00006', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY007', 'INV008', DATE '2024-03-23', 8610.00, 'Insurance Claim', 'TXN-2026-00007', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY008', 'INV009', DATE '2024-03-26', 14307.00, 'Credit Card', 'TXN-2026-00008', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY009', 'INV010', DATE '2024-03-29', 26269.00, 'Debit Card', 'TXN-2026-00009', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY010', 'INV011', DATE '2024-04-01', 600.00, 'Bank Transfer', 'TXN-2026-00010', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY011', 'INV012', DATE '2024-04-04', 880.00, 'Insurance Claim', 'TXN-2026-00011', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY012', 'INV013', DATE '2024-04-07', 1210.00, 'Credit Card', 'TXN-2026-00012', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY013', 'INV014', DATE '2024-04-10', 1575.00, 'Debit Card', 'TXN-2026-00013', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY014', 'INV015', DATE '2024-04-13', 2520.00, 'Bank Transfer', 'TXN-2026-00014', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY015', 'INV016', DATE '2024-04-16', 3990.00, 'Insurance Claim', 'TXN-2026-00015', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY016', 'INV017', DATE '2024-04-19', 6270.00, 'Credit Card', 'TXN-2026-00016', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY017', 'INV018', DATE '2024-04-22', 8767.50, 'Debit Card', 'TXN-2026-00017', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY018', 'INV019', DATE '2024-04-25', 13843.00, 'Bank Transfer', 'TXN-2026-00018', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY019', 'INV020', DATE '2024-04-28', 26432.50, 'Insurance Claim', 'TXN-2026-00019', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY020', 'INV021', DATE '2024-05-01', 787.50, 'Credit Card', 'TXN-2026-00020', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY021', 'INV022', DATE '2024-05-04', 680.00, 'Debit Card', 'TXN-2026-00021', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY022', 'INV023', DATE '2024-05-07', 900.00, 'Bank Transfer', 'TXN-2026-00022', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY023', 'INV024', DATE '2024-05-10', 1365.00, 'Insurance Claim', 'TXN-2026-00023', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY024', 'INV025', DATE '2024-05-13', 2805.00, 'Credit Card', 'TXN-2026-00024', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY025', 'INV026', DATE '2024-05-16', 4147.50, 'Debit Card', 'TXN-2026-00025', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY026', 'INV027', DATE '2024-05-19', 6142.50, 'Bank Transfer', 'TXN-2026-00026', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY027', 'INV028', DATE '2024-05-22', 8925.00, 'Insurance Claim', 'TXN-2026-00027', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY028', 'INV029', DATE '2024-05-25', 14250.00, 'Credit Card', 'TXN-2026-00028', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY029', 'INV030', DATE '2024-05-28', 26214.50, 'Debit Card', 'TXN-2026-00029', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY030', 'INV031', DATE '2024-05-31', 550.00, 'Bank Transfer', 'TXN-2026-00030', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY031', 'INV032', DATE '2024-06-03', 830.00, 'Insurance Claim', 'TXN-2026-00031', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY032', 'INV033', DATE '2024-06-06', 1155.00, 'Credit Card', 'TXN-2026-00032', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY033', 'INV034', DATE '2024-06-09', 1522.50, 'Debit Card', 'TXN-2026-00033', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY034', 'INV035', DATE '2024-06-12', 2835.00, 'Bank Transfer', 'TXN-2026-00034', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY035', 'INV036', DATE '2024-06-15', 3937.50, 'Insurance Claim', 'TXN-2026-00035', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY036', 'INV037', DATE '2024-06-18', 6215.00, 'Credit Card', 'TXN-2026-00036', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY037', 'INV038', DATE '2024-06-21', 8715.00, 'Debit Card', 'TXN-2026-00037', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY038', 'INV039', DATE '2024-06-24', 13788.50, 'Bank Transfer', 'TXN-2026-00038', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY039', 'INV040', DATE '2024-06-27', 26378.00, 'Insurance Claim', 'TXN-2026-00039', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY040', 'INV041', DATE '2024-06-30', 735.00, 'Credit Card', 'TXN-2026-00040', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY041', 'INV042', DATE '2024-07-03', 980.00, 'Debit Card', 'TXN-2026-00041', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY042', 'INV043', DATE '2024-07-06', 850.00, 'Bank Transfer', 'TXN-2026-00042', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY043', 'INV044', DATE '2024-07-09', 1312.50, 'Insurance Claim', 'TXN-2026-00043', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY044', 'INV045', DATE '2024-07-12', 2750.00, 'Credit Card', 'TXN-2026-00044', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY045', 'INV046', DATE '2024-07-15', 4095.00, 'Debit Card', 'TXN-2026-00045', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY046', 'INV047', DATE '2024-07-18', 6090.00, 'Bank Transfer', 'TXN-2026-00046', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY047', 'INV048', DATE '2024-07-21', 8872.50, 'Insurance Claim', 'TXN-2026-00047', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY048', 'INV049', DATE '2024-07-24', 14592.00, 'Credit Card', 'TXN-2026-00048', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY049', 'INV050', DATE '2024-07-27', 26160.00, 'Debit Card', 'TXN-2026-00049', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY050', 'INV051', DATE '2024-07-30', 500.00, 'Bank Transfer', 'TXN-2026-00050', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY051', 'INV052', DATE '2024-08-02', 780.00, 'Insurance Claim', 'TXN-2026-00051', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY052', 'INV053', DATE '2024-08-05', 1100.00, 'Credit Card', 'TXN-2026-00052', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY053', 'INV054', DATE '2024-08-08', 1470.00, 'Debit Card', 'TXN-2026-00053', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY054', 'INV055', DATE '2024-08-11', 2782.50, 'Bank Transfer', 'TXN-2026-00054', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY055', 'INV056', DATE '2024-08-14', 4252.50, 'Insurance Claim', 'TXN-2026-00055', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY056', 'INV057', DATE '2024-08-17', 6160.00, 'Credit Card', 'TXN-2026-00056', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY057', 'INV058', DATE '2024-08-20', 8662.50, 'Debit Card', 'TXN-2026-00057', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY058', 'INV059', DATE '2024-08-23', 13734.00, 'Bank Transfer', 'TXN-2026-00058', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY059', 'INV060', DATE '2024-08-26', 26323.50, 'Insurance Claim', 'TXN-2026-00059', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY060', 'INV061', DATE '2024-08-29', 682.50, 'Credit Card', 'TXN-2026-00060', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY061', 'INV062', DATE '2024-09-01', 465.00, 'Debit Card', 'TXN-2026-00061', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY062', 'INV062', DATE '2024-09-02', 465.00, 'Bank Transfer', 'TXN-2026-00062', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY063', 'INV063', DATE '2024-09-04', 603.75, 'Bank Transfer', 'TXN-2026-00063', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY064', 'INV063', DATE '2024-09-05', 603.75, 'Insurance Claim', 'TXN-2026-00064', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY065', 'INV064', DATE '2024-09-07', 630.00, 'Insurance Claim', 'TXN-2026-00065', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY066', 'INV064', DATE '2024-09-08', 630.00, 'Credit Card', 'TXN-2026-00066', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY067', 'INV065', DATE '2024-09-10', 1347.50, 'Credit Card', 'TXN-2026-00067', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY068', 'INV065', DATE '2024-09-11', 1347.50, 'Debit Card', 'TXN-2026-00068', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY069', 'INV066', DATE '2024-09-13', 2021.25, 'Debit Card', 'TXN-2026-00069', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY070', 'INV066', DATE '2024-09-14', 2021.25, 'Bank Transfer', 'TXN-2026-00070', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY071', 'INV067', DATE '2024-09-16', 3018.75, 'Bank Transfer', 'TXN-2026-00071', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY072', 'INV067', DATE '2024-09-17', 3018.75, 'Cash', 'TXN-2026-00072', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY073', 'INV068', DATE '2024-09-19', 4410.00, 'Cash', 'TXN-2026-00073', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY074', 'INV068', DATE '2024-09-20', 4410.00, 'Credit Card', 'TXN-2026-00074', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY075', 'INV069', DATE '2024-09-22', 7267.50, 'Credit Card', 'TXN-2026-00075', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY076', 'INV069', DATE '2024-09-23', 7267.50, 'Debit Card', 'TXN-2026-00076', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY077', 'INV070', DATE '2024-09-25', 13243.50, 'Debit Card', 'TXN-2026-00077', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY078', 'INV070', DATE '2024-09-26', 13243.50, 'Bank Transfer', 'TXN-2026-00078', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY079', 'INV071', DATE '2024-09-28', 225.00, 'Bank Transfer', 'TXN-2026-00079', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY080', 'INV071', DATE '2024-09-29', 225.00, 'Cash', 'TXN-2026-00080', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY081', 'INV072', DATE '2024-10-01', 365.00, 'Cash', 'TXN-2026-00081', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY082', 'INV072', DATE '2024-10-02', 365.00, 'Credit Card', 'TXN-2026-00082', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY083', 'INV073', DATE '2024-10-04', 498.75, 'Credit Card', 'TXN-2026-00083', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY084', 'INV073', DATE '2024-10-05', 498.75, 'Debit Card', 'TXN-2026-00084', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY085', 'INV074', DATE '2024-10-07', 708.75, 'Debit Card', 'TXN-2026-00085', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY086', 'INV074', DATE '2024-10-08', 708.75, 'Bank Transfer', 'TXN-2026-00086', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY087', 'INV075', DATE '2024-10-10', 1365.00, 'Bank Transfer', 'TXN-2026-00087', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY088', 'INV075', DATE '2024-10-11', 1365.00, 'Cash', 'TXN-2026-00088', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY089', 'INV076', DATE '2024-10-13', 2100.00, 'Cash', 'TXN-2026-00089', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY090', 'INV076', DATE '2024-10-14', 2100.00, 'Credit Card', 'TXN-2026-00090', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY091', 'INV077', DATE '2024-10-16', 3245.00, 'Credit Card', 'TXN-2026-00091', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY092', 'INV077', DATE '2024-10-17', 3245.00, 'Debit Card', 'TXN-2026-00092', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY093', 'INV078', DATE '2024-10-19', 4305.00, 'Debit Card', 'TXN-2026-00093', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY094', 'INV078', DATE '2024-10-20', 4305.00, 'Bank Transfer', 'TXN-2026-00094', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY095', 'INV079', DATE '2024-10-22', 6839.75, 'Bank Transfer', 'TXN-2026-00095', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY096', 'INV079', DATE '2024-10-23', 6839.75, 'Cash', 'TXN-2026-00096', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY097', 'INV080', DATE '2024-10-25', 13134.50, 'Cash', 'TXN-2026-00097', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY098', 'INV080', DATE '2024-10-26', 13134.50, 'Credit Card', 'TXN-2026-00098', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY099', 'INV081', DATE '2024-10-28', 315.00, 'Credit Card', 'TXN-2026-00099', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY100', 'INV081', DATE '2024-10-29', 315.00, 'Debit Card', 'TXN-2026-00100', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY101', 'INV082', DATE '2024-10-31', 440.00, 'Debit Card', 'TXN-2026-00101', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY102', 'INV082', DATE '2024-11-01', 440.00, 'Bank Transfer', 'TXN-2026-00102', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY103', 'INV083', DATE '2024-11-03', 577.50, 'Bank Transfer', 'TXN-2026-00103', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY104', 'INV083', DATE '2024-11-04', 577.50, 'Cash', 'TXN-2026-00104', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY105', 'INV084', DATE '2024-11-06', 787.50, 'Cash', 'TXN-2026-00105', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY106', 'INV084', DATE '2024-11-07', 787.50, 'Credit Card', 'TXN-2026-00106', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY107', 'INV085', DATE '2024-11-09', 1320.00, 'Credit Card', 'TXN-2026-00107', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY108', 'INV085', DATE '2024-11-10', 1320.00, 'Debit Card', 'TXN-2026-00108', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY109', 'INV086', DATE '2024-11-12', 1995.00, 'Debit Card', 'TXN-2026-00109', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY110', 'INV086', DATE '2024-11-13', 1995.00, 'Bank Transfer', 'TXN-2026-00110', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY111', 'INV087', DATE '2024-11-15', 2992.50, 'Bank Transfer', 'TXN-2026-00111', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY112', 'INV087', DATE '2024-11-16', 2992.50, 'Cash', 'TXN-2026-00112', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY113', 'INV088', DATE '2024-11-18', 4383.75, 'Cash', 'TXN-2026-00113', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY114', 'INV088', DATE '2024-11-19', 4383.75, 'Credit Card', 'TXN-2026-00114', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY115', 'INV089', DATE '2024-11-21', 7239.00, 'Credit Card', 'TXN-2026-00115', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY116', 'INV089', DATE '2024-11-22', 7239.00, 'Debit Card', 'TXN-2026-00116', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY117', 'INV090', DATE '2024-11-24', 13216.25, 'Debit Card', 'TXN-2026-00117', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY118', 'INV090', DATE '2024-11-25', 13216.25, 'Bank Transfer', 'TXN-2026-00118', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY119', 'INV091', DATE '2024-11-27', 375.00, 'Bank Transfer', 'TXN-2026-00119', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY120', 'INV091', DATE '2024-11-28', 375.00, 'Cash', 'TXN-2026-00120', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY121', 'INV092', DATE '2024-11-30', 340.00, 'Cash', 'TXN-2026-00121', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY122', 'INV092', DATE '2024-12-01', 340.00, 'Credit Card', 'TXN-2026-00122', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY123', 'INV093', DATE '2024-12-03', 472.50, 'Credit Card', 'TXN-2026-00123', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY124', 'INV093', DATE '2024-12-04', 472.50, 'Debit Card', 'TXN-2026-00124', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY125', 'INV094', DATE '2024-12-06', 682.50, 'Debit Card', 'TXN-2026-00125', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY126', 'INV094', DATE '2024-12-07', 682.50, 'Bank Transfer', 'TXN-2026-00126', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY127', 'INV095', DATE '2024-12-09', 1338.75, 'Bank Transfer', 'TXN-2026-00127', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY128', 'INV095', DATE '2024-12-10', 1338.75, 'Cash', 'TXN-2026-00128', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY129', 'INV096', DATE '2024-12-12', 2073.75, 'Cash', 'TXN-2026-00129', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY130', 'INV096', DATE '2024-12-13', 2073.75, 'Credit Card', 'TXN-2026-00130', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY131', 'INV097', DATE '2024-12-15', 3217.50, 'Credit Card', 'TXN-2026-00131', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY132', 'INV097', DATE '2024-12-16', 3217.50, 'Debit Card', 'TXN-2026-00132', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY133', 'INV098', DATE '2024-12-18', 4462.50, 'Debit Card', 'TXN-2026-00133', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY134', 'INV098', DATE '2024-12-19', 4462.50, 'Bank Transfer', 'TXN-2026-00134', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY135', 'INV099', DATE '2024-12-21', 6812.50, 'Bank Transfer', 'TXN-2026-00135', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY136', 'INV099', DATE '2024-12-22', 6812.50, 'Cash', 'TXN-2026-00136', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY137', 'INV100', DATE '2024-12-24', 13107.25, 'Cash', 'TXN-2026-00137', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY138', 'INV100', DATE '2024-12-25', 13107.25, 'Credit Card', 'TXN-2026-00138', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY139', 'INV101', DATE '2024-12-27', 288.75, 'Credit Card', 'TXN-2026-00139', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY140', 'INV101', DATE '2024-12-28', 288.75, 'Debit Card', 'TXN-2026-00140', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY141', 'INV102', DATE '2024-12-30', 415.00, 'Debit Card', 'TXN-2026-00141', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY142', 'INV102', DATE '2024-12-31', 415.00, 'Bank Transfer', 'TXN-2026-00142', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY143', 'INV103', DATE '2025-01-02', 551.25, 'Bank Transfer', 'TXN-2026-00143', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY144', 'INV103', DATE '2025-01-03', 551.25, 'Insurance Claim', 'TXN-2026-00144', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY145', 'INV104', DATE '2025-01-05', 761.25, 'Insurance Claim', 'TXN-2026-00145', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY146', 'INV104', DATE '2025-01-06', 761.25, 'Credit Card', 'TXN-2026-00146', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY147', 'INV105', DATE '2025-01-08', 1485.00, 'Credit Card', 'TXN-2026-00147', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY148', 'INV105', DATE '2025-01-09', 1485.00, 'Debit Card', 'TXN-2026-00148', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY149', 'INV106', DATE '2025-01-11', 1968.75, 'Debit Card', 'TXN-2026-00149', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY150', 'INV106', DATE '2025-01-12', 1968.75, 'Bank Transfer', 'TXN-2026-00150', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY151', 'INV107', DATE '2025-01-14', 2966.25, 'Bank Transfer', 'TXN-2026-00151', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY152', 'INV107', DATE '2025-01-15', 2966.25, 'Insurance Claim', 'TXN-2026-00152', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY153', 'INV108', DATE '2025-01-17', 4357.50, 'Insurance Claim', 'TXN-2026-00153', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY154', 'INV108', DATE '2025-01-18', 4357.50, 'Credit Card', 'TXN-2026-00154', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY155', 'INV109', DATE '2025-01-20', 7210.50, 'Credit Card', 'TXN-2026-00155', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY156', 'INV109', DATE '2025-01-21', 7210.50, 'Debit Card', 'TXN-2026-00156', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY157', 'INV110', DATE '2025-01-23', 13189.00, 'Debit Card', 'TXN-2026-00157', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY158', 'INV110', DATE '2025-01-24', 13189.00, 'Bank Transfer', 'TXN-2026-00158', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY159', 'INV111', DATE '2025-01-26', 350.00, 'Bank Transfer', 'TXN-2026-00159', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY160', 'INV111', DATE '2025-01-27', 350.00, 'Insurance Claim', 'TXN-2026-00160', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY161', 'INV112', DATE '2025-01-29', 441.00, 'Insurance Claim', 'TXN-2026-00161', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY162', 'INV113', DATE '2025-02-01', 401.63, 'Credit Card', 'TXN-2026-00162', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY163', 'INV114', DATE '2025-02-04', 590.63, 'Debit Card', 'TXN-2026-00163', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY164', 'INV115', DATE '2025-02-07', 1181.25, 'Bank Transfer', 'TXN-2026-00164', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY165', 'INV116', DATE '2025-02-10', 1842.75, 'Insurance Claim', 'TXN-2026-00165', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY166', 'INV117', DATE '2025-02-13', 2871.00, 'Credit Card', 'TXN-2026-00166', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY167', 'INV118', DATE '2025-02-16', 3992.63, 'Debit Card', 'TXN-2026-00167', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY168', 'INV119', DATE '2025-02-19', 6278.40, 'Bank Transfer', 'TXN-2026-00168', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY169', 'INV120', DATE '2025-02-22', 11772.00, 'Insurance Claim', 'TXN-2026-00169', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY170', 'INV121', DATE '2025-02-25', 236.25, 'Credit Card', 'TXN-2026-00170', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY171', 'INV122', DATE '2025-02-28', 351.00, 'Debit Card', 'TXN-2026-00171', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY172', 'INV123', DATE '2025-03-03', 472.50, 'Bank Transfer', 'TXN-2026-00172', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY173', 'INV124', DATE '2025-03-06', 661.50, 'Insurance Claim', 'TXN-2026-00173', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY174', 'INV125', DATE '2025-03-09', 1311.75, 'Credit Card', 'TXN-2026-00174', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY175', 'INV126', DATE '2025-03-12', 1913.63, 'Debit Card', 'TXN-2026-00175', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY176', 'INV127', DATE '2025-03-15', 2646.00, 'Bank Transfer', 'TXN-2026-00176', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY177', 'INV128', DATE '2025-03-18', 3898.13, 'Insurance Claim', 'TXN-2026-00177', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY178', 'INV129', DATE '2025-03-21', 6463.80, 'Credit Card', 'TXN-2026-00178', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY179', 'INV130', DATE '2025-03-24', 11845.58, 'Debit Card', 'TXN-2026-00179', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY180', 'INV131', DATE '2025-03-27', 292.50, 'Bank Transfer', 'TXN-2026-00180', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY181', 'INV132', DATE '2025-03-30', 418.50, 'Insurance Claim', 'TXN-2026-00181', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY182', 'INV133', DATE '2025-04-02', 569.25, 'Credit Card', 'TXN-2026-00182', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY183', 'INV134', DATE '2025-04-05', 567.00, 'Debit Card', 'TXN-2026-00183', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY184', 'INV135', DATE '2025-04-08', 1157.63, 'Bank Transfer', 'TXN-2026-00184', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY185', 'INV136', DATE '2025-04-11', 1819.13, 'Insurance Claim', 'TXN-2026-00185', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY186', 'INV137', DATE '2025-04-14', 2846.25, 'Credit Card', 'TXN-2026-00186', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY187', 'INV138', DATE '2025-04-17', 3969.00, 'Debit Card', 'TXN-2026-00187', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY188', 'INV139', DATE '2025-04-20', 6253.88, 'Bank Transfer', 'TXN-2026-00188', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY189', 'INV140', DATE '2025-04-23', 11919.15, 'Insurance Claim', 'TXN-2026-00189', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY190', 'INV141', DATE '2025-04-26', 212.63, 'Credit Card', 'TXN-2026-00190', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY191', 'INV142', DATE '2025-04-29', 328.50, 'Debit Card', 'TXN-2026-00191', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY192', 'INV143', DATE '2025-05-02', 427.50, 'Bank Transfer', 'TXN-2026-00192', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY193', 'INV144', DATE '2025-05-05', 637.88, 'Insurance Claim', 'TXN-2026-00193', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY194', 'INV145', DATE '2025-05-08', 1287.00, 'Credit Card', 'TXN-2026-00194', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY195', 'INV146', DATE '2025-05-11', 1890.00, 'Debit Card', 'TXN-2026-00195', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY196', 'INV147', DATE '2025-05-14', 2787.75, 'Bank Transfer', 'TXN-2026-00196', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY197', 'INV148', DATE '2025-05-17', 3874.50, 'Insurance Claim', 'TXN-2026-00197', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY198', 'INV149', DATE '2025-05-20', 6438.15, 'Credit Card', 'TXN-2026-00198', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY199', 'INV150', DATE '2025-05-23', 11821.05, 'Debit Card', 'TXN-2026-00199', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY200', 'INV151', DATE '2025-05-26', 270.00, 'Bank Transfer', 'TXN-2026-00200', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY201', 'INV152', DATE '2025-05-29', 396.00, 'Insurance Claim', 'TXN-2026-00201', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY202', 'INV153', DATE '2025-06-01', 544.50, 'Credit Card', 'TXN-2026-00202', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY203', 'INV154', DATE '2025-06-04', 708.75, 'Debit Card', 'TXN-2026-00203', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY204', 'INV155', DATE '2025-06-07', 1134.00, 'Bank Transfer', 'TXN-2026-00204', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY205', 'INV156', DATE '2025-06-10', 1795.50, 'Insurance Claim', 'TXN-2026-00205', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY206', 'INV157', DATE '2025-06-13', 2821.50, 'Credit Card', 'TXN-2026-00206', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY207', 'INV158', DATE '2025-06-16', 3945.38, 'Debit Card', 'TXN-2026-00207', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY208', 'INV159', DATE '2025-06-19', 6229.35, 'Bank Transfer', 'TXN-2026-00208', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY209', 'INV160', DATE '2025-06-22', 11894.63, 'Insurance Claim', 'TXN-2026-00209', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY210', 'INV161', DATE '2025-06-25', 354.38, 'Credit Card', 'TXN-2026-00210', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY211', 'INV162', DATE '2025-06-28', 204.00, 'Debit Card', 'TXN-2026-00211', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY212', 'INV162', DATE '2025-06-28', 204.00, 'Bank Transfer', 'TXN-2026-00212', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY213', 'INV163', DATE '2025-07-01', 270.00, 'Bank Transfer', 'TXN-2026-00213', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY214', 'INV163', DATE '2025-07-01', 270.00, 'Insurance Claim', 'TXN-2026-00214', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY215', 'INV164', DATE '2025-07-04', 409.50, 'Insurance Claim', 'TXN-2026-00215', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY216', 'INV164', DATE '2025-07-04', 409.50, 'Credit Card', 'TXN-2026-00216', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY217', 'INV165', DATE '2025-07-07', 841.50, 'Credit Card', 'TXN-2026-00217', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY218', 'INV165', DATE '2025-07-07', 841.50, 'Debit Card', 'TXN-2026-00218', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY219', 'INV166', DATE '2025-07-10', 1244.25, 'Debit Card', 'TXN-2026-00219', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY220', 'INV166', DATE '2025-07-10', 1244.25, 'Bank Transfer', 'TXN-2026-00220', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY221', 'INV167', DATE '2025-07-13', 1842.75, 'Bank Transfer', 'TXN-2026-00221', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY222', 'INV167', DATE '2025-07-13', 1842.75, 'Cash', 'TXN-2026-00222', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY223', 'INV168', DATE '2025-07-16', 2677.50, 'Cash', 'TXN-2026-00223', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY224', 'INV168', DATE '2025-07-16', 2677.50, 'Credit Card', 'TXN-2026-00224', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY225', 'INV169', DATE '2025-07-19', 4275.00, 'Credit Card', 'TXN-2026-00225', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY226', 'INV169', DATE '2025-07-19', 4275.00, 'Debit Card', 'TXN-2026-00226', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY227', 'INV170', TRUNC(SYSDATE), 7864.35, 'Debit Card', 'TXN-2026-00227', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY228', 'INV170', TRUNC(SYSDATE), 7864.35, 'Bank Transfer', 'TXN-2026-00228', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY229', 'INV171', TRUNC(SYSDATE), 165.00, 'Bank Transfer', 'TXN-2026-00229', 'Completed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY230', 'INV171', TRUNC(SYSDATE), 165.00, 'Cash', 'TXN-2026-00230', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY231', 'INV172', TRUNC(SYSDATE), 415.00, 'Cash', 'TXN-2026-00231', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY232', 'INV173', TRUNC(SYSDATE), 577.50, 'Credit Card', 'TXN-2026-00232', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY233', 'INV174', TRUNC(SYSDATE), 761.25, 'Debit Card', 'TXN-2026-00233', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY234', 'INV175', TRUNC(SYSDATE), 1417.50, 'Bank Transfer', 'TXN-2026-00234', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY235', 'INV176', TRUNC(SYSDATE), 1968.75, 'Cash', 'TXN-2026-00235', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY236', 'INV177', TRUNC(SYSDATE), 3107.50, 'Credit Card', 'TXN-2026-00236', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY237', 'INV178', TRUNC(SYSDATE), 4357.50, 'Debit Card', 'TXN-2026-00237', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY238', 'INV179', TRUNC(SYSDATE), 6894.25, 'Bank Transfer', 'TXN-2026-00238', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY239', 'INV180', TRUNC(SYSDATE), 13189.00, 'Cash', 'TXN-2026-00239', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY240', 'INV181', TRUNC(SYSDATE), 367.50, 'Credit Card', 'TXN-2026-00240', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY241', 'INV182', TRUNC(SYSDATE), 490.00, 'Debit Card', 'TXN-2026-00241', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY242', 'INV183', TRUNC(SYSDATE), 425.00, 'Bank Transfer', 'TXN-2026-00242', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY243', 'INV184', TRUNC(SYSDATE), 656.25, 'Cash', 'TXN-2026-00243', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY244', 'INV185', TRUNC(SYSDATE), 1375.00, 'Credit Card', 'TXN-2026-00244', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY245', 'INV186', TRUNC(SYSDATE), 2047.50, 'Debit Card', 'TXN-2026-00245', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY246', 'INV187', TRUNC(SYSDATE), 3045.00, 'Bank Transfer', 'TXN-2026-00246', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY247', 'INV188', TRUNC(SYSDATE), 4436.25, 'Cash', 'TXN-2026-00247', 'Refunded');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY248', 'INV189', TRUNC(SYSDATE), 7296.00, 'Credit Card', 'TXN-2026-00248', 'Pending');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY249', 'INV190', TRUNC(SYSDATE), 13080.00, 'Debit Card', 'TXN-2026-00249', 'Failed');
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus) VALUES ('PAY250', 'INV191', TRUNC(SYSDATE), 250.00, 'Bank Transfer', 'TXN-2026-00250', 'Refunded');

COMMIT;

-- ----------------------------------------------------------------------------
-- STUDENT 4: Pharmacy & Laboratory Management Seeds
-- ----------------------------------------------------------------------------

-- Source: scripts/02_seeds/student4_pharmacy_lab/insert_medication.sql
-- SEED DATA: Medication (Student 4) - 50 rows
-- Row 1 omits QuantityInStock (0) and ImportDate (SYSDATE) to exercise DEFAULTS.

INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, ExpirationDate, SupplierID) VALUES ('MED001', 'Amoxicillin 500mg', 'Pharco Pharma', 'Antibiotic', 'Capsule', 45.00, TRUNC(SYSDATE) + 730, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED002', 'Paracetamol 500mg', 'EIPICO Labs', 'Analgesic', 'Tablet', 18.50, 850, TRUNC(SYSDATE) - 35, TRUNC(SYSDATE) + 195, 'SUP003');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED003', 'Ibuprofen 400mg', 'Eva Pharma', 'Antipyretic', 'Tablet', 26.00, 900, TRUNC(SYSDATE) - 40, TRUNC(SYSDATE) + 210, 'SUP004');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED004', 'Amlodipine 5mg', 'Amoun Pharma', 'Antihypertensive', 'Tablet', 55.00, 950, TRUNC(SYSDATE) - 45, TRUNC(SYSDATE) + 225, 'SUP005');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED005', 'Metformin 850mg', 'Hikma Pharma', 'Antidiabetic', 'Tablet', 38.00, 1000, TRUNC(SYSDATE) - 50, TRUNC(SYSDATE) + 240, 'SUP006');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED006', 'Enoxaparin 40mg', 'Sanofi Egypt', 'Anticoagulant', 'Injection', 210.00, 1050, TRUNC(SYSDATE) - 55, TRUNC(SYSDATE) + 255, 'SUP007');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED007', 'Cetirizine 10mg', 'Novartis Cairo', 'Antihistamine', 'Tablet', 32.00, 1100, TRUNC(SYSDATE) - 60, TRUNC(SYSDATE) + 270, 'SUP008');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED008', 'Salbutamol Inhaler', 'GSK Healthcare', 'Bronchodilator', 'Inhaler', 95.00, 1150, TRUNC(SYSDATE) - 65, TRUNC(SYSDATE) + 285, 'SUP009');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED009', 'Atorvastatin 20mg', 'Pfizer Egypt', 'Statin', 'Tablet', 78.00, 1200, TRUNC(SYSDATE) - 70, TRUNC(SYSDATE) + 300, 'SUP010');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED010', 'Omeprazole 20mg', 'AstraZeneca Nile', 'Gastrointestinal', 'Capsule', 62.00, 1250, TRUNC(SYSDATE) - 75, TRUNC(SYSDATE) + 315, 'SUP011');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED011', 'Prednisolone 5mg', 'Sedico Pharma', 'Corticosteroid', 'Tablet', 29.00, 1300, TRUNC(SYSDATE) - 80, TRUNC(SYSDATE) + 330, 'SUP012');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED012', 'Sertraline 50mg', 'Minapharm Bio', 'Antidepressant', 'Tablet', 115.00, 1350, TRUNC(SYSDATE) - 85, TRUNC(SYSDATE) + 345, 'SUP013');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED013', 'Oseltamivir 75mg', 'Rameda Group', 'Antiviral', 'Capsule', 185.00, 1400, TRUNC(SYSDATE) - 90, TRUNC(SYSDATE) + 360, 'SUP014');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED014', 'Bisoprolol 5mg', 'Pharco Pharma', 'Cardiovascular', 'Tablet', 64.00, 1450, TRUNC(SYSDATE) - 95, TRUNC(SYSDATE) + 375, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED015', 'Hydrocortisone 1%', 'EIPICO Labs', 'Dermatological', 'Cream', 42.00, 1500, TRUNC(SYSDATE) - 100, TRUNC(SYSDATE) + 390, 'SUP002');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED016', 'Azithromycin 500mg', 'Eva Pharma', 'Antibiotic', 'Tablet', 88.00, 1550, TRUNC(SYSDATE) - 105, TRUNC(SYSDATE) + 405, 'SUP003');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED017', 'Ceftriaxone 1g Vial', 'Amoun Pharma', 'Antibiotic', 'Injection', 125.00, 1600, TRUNC(SYSDATE) - 110, TRUNC(SYSDATE) + 420, 'SUP004');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED018', 'Diclofenac Sodium', 'Hikma Pharma', 'Analgesic', 'Suppository', 48.00, 1650, TRUNC(SYSDATE) - 115, TRUNC(SYSDATE) + 435, 'SUP005');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED019', 'Losartan 50mg', 'Sanofi Egypt', 'Antihypertensive', 'Tablet', 72.00, 1700, TRUNC(SYSDATE) - 120, TRUNC(SYSDATE) + 450, 'SUP006');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED020', 'Insulin Glargine', 'Sanofi Egypt', 'Antidiabetic', 'Injection', 390.00, 1750, TRUNC(SYSDATE) - 125, TRUNC(SYSDATE) + 465, 'SUP007');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED021', 'Clopidogrel 75mg', 'Novartis Cairo', 'Anticoagulant', 'Tablet', 130.00, 1800, TRUNC(SYSDATE) - 130, TRUNC(SYSDATE) + 480, 'SUP008');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED022', 'Loratadine Syrup', 'GSK Healthcare', 'Antihistamine', 'Syrup', 44.00, 1850, TRUNC(SYSDATE) - 135, TRUNC(SYSDATE) + 495, 'SUP009');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED023', 'Budesonide Inhaler', 'AstraZeneca Nile', 'Bronchodilator', 'Inhaler', 240.00, 1900, TRUNC(SYSDATE) - 140, TRUNC(SYSDATE) + 510, 'SUP010');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED024', 'Rosuvastatin 10mg', 'Pfizer Egypt', 'Statin', 'Tablet', 98.00, 1950, TRUNC(SYSDATE) - 145, TRUNC(SYSDATE) + 525, 'SUP011');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED025', 'Esomeprazole 40mg', 'AstraZeneca Nile', 'Gastrointestinal', 'Capsule', 112.00, 2000, TRUNC(SYSDATE) - 150, TRUNC(SYSDATE) + 540, 'SUP012');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED026', 'Dexamethasone 4mg', 'Sedico Pharma', 'Corticosteroid', 'Injection', 36.00, 2050, TRUNC(SYSDATE) - 155, TRUNC(SYSDATE) + 555, 'SUP013');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED027', 'Escitalopram 10mg', 'Minapharm Bio', 'Antidepressant', 'Tablet', 145.00, 2100, TRUNC(SYSDATE) - 160, TRUNC(SYSDATE) + 570, 'SUP014');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED028', 'Acyclovir 400mg', 'Rameda Group', 'Antiviral', 'Tablet', 82.00, 2150, TRUNC(SYSDATE) - 165, TRUNC(SYSDATE) + 585, 'SUP015');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED029', 'Digoxin 0.25mg', 'Pharco Pharma', 'Cardiovascular', 'Tablet', 34.00, 2200, TRUNC(SYSDATE) - 170, TRUNC(SYSDATE) + 600, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED030', 'Mupirocin Ointment', 'EIPICO Labs', 'Dermatological', 'Ointment', 68.00, 2250, TRUNC(SYSDATE) - 175, TRUNC(SYSDATE) + 615, 'SUP003');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED031', 'Ciprofloxacin 500mg', 'Eva Pharma', 'Antibiotic', 'Tablet', 74.00, 2300, TRUNC(SYSDATE) - 180, TRUNC(SYSDATE) + 630, 'SUP004');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED032', 'Tramadol Relief 50mg', 'Amoun Pharma', 'Analgesic', 'Capsule', 110.00, 2350, TRUNC(SYSDATE) - 185, TRUNC(SYSDATE) + 645, 'SUP005');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED033', 'Captopril 25mg', 'Hikma Pharma', 'Antihypertensive', 'Tablet', 28.00, 2400, TRUNC(SYSDATE) - 190, TRUNC(SYSDATE) + 660, 'SUP006');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED034', 'Gliclazide 60mg', 'Sanofi Egypt', 'Antidiabetic', 'Tablet', 85.00, 2450, TRUNC(SYSDATE) - 195, TRUNC(SYSDATE) + 675, 'SUP007');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED035', 'Warfarin 5mg', 'Novartis Cairo', 'Anticoagulant', 'Tablet', 46.00, 2500, TRUNC(SYSDATE) - 200, TRUNC(SYSDATE) + 690, 'SUP008');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED036', 'Fexofenadine 120mg', 'GSK Healthcare', 'Antihistamine', 'Tablet', 66.00, 2550, TRUNC(SYSDATE) - 205, TRUNC(SYSDATE) + 705, 'SUP009');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED037', 'Ipratropium Drops', 'AstraZeneca Nile', 'Bronchodilator', 'Drops', 79.00, 2600, TRUNC(SYSDATE) - 210, TRUNC(SYSDATE) + 720, 'SUP010');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED038', 'Simvastatin 20mg', 'Pfizer Egypt', 'Statin', 'Tablet', 58.00, 2650, TRUNC(SYSDATE) - 215, TRUNC(SYSDATE) + 735, 'SUP011');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED039', 'Ondansetron 4mg', 'Sedico Pharma', 'Gastrointestinal', 'Injection', 92.00, 2700, TRUNC(SYSDATE) - 220, TRUNC(SYSDATE) + 750, 'SUP012');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED040', 'Methylprednisolone', 'Minapharm Bio', 'Corticosteroid', 'Injection', 165.00, 2750, TRUNC(SYSDATE) - 225, TRUNC(SYSDATE) + 765, 'SUP013');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED041', 'Fluoxetine 20mg', 'Rameda Group', 'Antidepressant', 'Capsule', 89.00, 800, TRUNC(SYSDATE) - 230, TRUNC(SYSDATE) + 180, 'SUP014');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED042', 'Valacyclovir 500mg', 'Pharco Pharma', 'Antiviral', 'Tablet', 195.00, 850, TRUNC(SYSDATE) - 235, TRUNC(SYSDATE) + 195, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED043', 'Nitroglycerin Patch', 'EIPICO Labs', 'Cardiovascular', 'Patch', 155.00, 900, TRUNC(SYSDATE) - 240, TRUNC(SYSDATE) + 210, 'SUP002');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED044', 'Ketoconazole Cream', 'Eva Pharma', 'Dermatological', 'Cream', 54.00, 950, TRUNC(SYSDATE) - 245, TRUNC(SYSDATE) + 225, 'SUP003');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED045', 'Metronidazole 500mg', 'Amoun Pharma', 'Antibiotic', 'Suspension', 39.00, 1000, TRUNC(SYSDATE) - 250, TRUNC(SYSDATE) + 240, 'SUP004');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED046', 'Vitamin D3 5000IU', 'Hikma Pharma', 'Other', 'Capsule', 75.00, 1050, TRUNC(SYSDATE) - 255, TRUNC(SYSDATE) + 255, 'SUP005');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED047', 'Ferrous Sulfate Tabs', 'Pharco Pharma', 'Other', 'Tablet', 31.00, 1100, TRUNC(SYSDATE) - 260, TRUNC(SYSDATE) + 270, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED048', 'Calcium Carbonate', 'Pharco Pharma', 'Other', 'Tablet', 43.00, 1150, TRUNC(SYSDATE) - 265, TRUNC(SYSDATE) + 285, 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED049', 'Amoxicillin Susp Old', 'Pharco Pharma', 'Antibiotic', 'Suspension', 35.00, 15, DATE '2022-06-18', DATE '2024-07-19', 'SUP001');
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID) VALUES ('MED050', 'Cough Relief Old', 'Pharco Pharma', 'Other', 'Syrup', 27.00, 15, DATE '2022-06-19', DATE '2024-07-20', 'SUP001');

COMMIT;

-- Source: scripts/02_seeds/student4_pharmacy_lab/insert_prescription.sql
-- SEED DATA: Prescription (Student 4) - 300 rows
-- Row 1 omits QuantityPrescribed (1), DispenseStatus ('Pending'), PrescriptionDate (SYSDATE), and Notes (NULL).

INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration) VALUES ('RX001', 'PAT001', 'DOC002', 'MED001', '500 mg', 'Three times daily', 7);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX002', 'PAT001', 'DOC002', 'MED003', '400 mg', 'Twice daily', 7, 2, 'Dispensed', TO_DATE('2024-02-03 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX003', 'PAT002', 'DOC003', 'MED004', '10 mg', 'Three times daily', 10, 3, 'Dispensed', TO_DATE('2024-02-05 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX004', 'PAT003', 'DOC004', 'MED005', '20 mg', 'Four times daily', 14, 5, 'Pending', TO_DATE('2024-02-07 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX005', 'PAT004', 'DOC005', 'MED006', '5 mg', 'Every 6 hours', 30, 10, 'Cancelled', TO_DATE('2024-02-09 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX006', 'PAT005', 'DOC006', 'MED007', '100 mg', 'Every 8 hours', 60, 14, 'Dispensed', TO_DATE('2024-02-11 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX007', 'PAT006', 'DOC007', 'MED008', '250 mg', 'Every 12 hours', 90, 20, 'Dispensed', TO_DATE('2024-02-13 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX008', 'PAT007', 'DOC008', 'MED009', '1 puff', 'As needed (PRN)', 5, 30, 'Dispensed', TO_DATE('2024-02-15 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX009', 'PAT008', 'DOC009', 'MED010', '5 ml', 'At bedtime', 7, 1, 'Pending', TO_DATE('2024-02-17 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX010', 'PAT009', 'DOC010', 'MED002', '40 mg', 'Weekly', 10, 2, 'Cancelled', TO_DATE('2024-02-19 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX011', 'PAT010', 'DOC011', 'MED001', '500 mg', 'Before meals', 14, 3, 'Pending', TO_DATE('2024-02-21 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX012', 'PAT011', 'DOC012', 'MED013', '400 mg', 'After meals', 30, 5, 'Dispensed', TO_DATE('2024-02-23 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX013', 'PAT012', 'DOC013', 'MED014', '10 mg', 'Once daily', 60, 10, 'Dispensed', TO_DATE('2024-02-25 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX014', 'PAT013', 'DOC014', 'MED015', '20 mg', 'Twice daily', 90, 14, 'Pending', TO_DATE('2024-02-27 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX015', 'PAT014', 'DOC015', 'MED016', '5 mg', 'Three times daily', 5, 20, 'Cancelled', TO_DATE('2024-02-29 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX016', 'PAT015', 'DOC016', 'MED017', '100 mg', 'Four times daily', 7, 30, 'Dispensed', TO_DATE('2024-03-02 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX017', 'PAT001', 'DOC017', 'MED018', '250 mg', 'Every 6 hours', 10, 1, 'Dispensed', TO_DATE('2024-03-04 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX018', 'PAT002', 'DOC018', 'MED019', '1 puff', 'Every 8 hours', 14, 2, 'Dispensed', TO_DATE('2024-03-06 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX019', 'PAT003', 'DOC019', 'MED002', '5 ml', 'Every 12 hours', 30, 3, 'Pending', TO_DATE('2024-03-08 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX020', 'PAT004', 'DOC020', 'MED021', '40 mg', 'As needed (PRN)', 60, 5, 'Cancelled', TO_DATE('2024-03-10 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX021', 'PAT005', 'DOC001', 'MED022', '500 mg', 'At bedtime', 90, 10, 'Dispensed', TO_DATE('2024-03-12 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX022', 'PAT006', 'DOC002', 'MED023', '400 mg', 'Weekly', 5, 14, 'Dispensed', TO_DATE('2024-03-14 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX023', 'PAT007', 'DOC003', 'MED024', '10 mg', 'Before meals', 7, 20, 'Dispensed', TO_DATE('2024-03-16 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX024', 'PAT008', 'DOC004', 'MED025', '20 mg', 'After meals', 10, 30, 'Pending', TO_DATE('2024-03-18 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX025', 'PAT009', 'DOC005', 'MED026', '5 mg', 'Once daily', 14, 1, 'Cancelled', TO_DATE('2024-03-20 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX026', 'PAT010', 'DOC006', 'MED001', '100 mg', 'Twice daily', 30, 2, 'Pending', TO_DATE('2024-03-22 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX027', 'PAT011', 'DOC007', 'MED028', '250 mg', 'Three times daily', 60, 3, 'Dispensed', TO_DATE('2024-03-24 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX028', 'PAT012', 'DOC008', 'MED002', '1 puff', 'Four times daily', 90, 5, 'Dispensed', TO_DATE('2024-03-26 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX029', 'PAT013', 'DOC009', 'MED030', '5 ml', 'Every 6 hours', 5, 10, 'Pending', TO_DATE('2024-03-28 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX030', 'PAT014', 'DOC010', 'MED031', '40 mg', 'Every 8 hours', 7, 14, 'Cancelled', TO_DATE('2024-03-30 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX031', 'PAT015', 'DOC011', 'MED032', '500 mg', 'Every 12 hours', 10, 20, 'Dispensed', TO_DATE('2024-04-01 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX032', 'PAT001', 'DOC012', 'MED033', '400 mg', 'As needed (PRN)', 14, 30, 'Dispensed', TO_DATE('2024-04-03 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX033', 'PAT002', 'DOC013', 'MED034', '10 mg', 'At bedtime', 30, 1, 'Dispensed', TO_DATE('2024-04-05 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX034', 'PAT003', 'DOC014', 'MED035', '20 mg', 'Weekly', 60, 2, 'Pending', TO_DATE('2024-04-07 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX035', 'PAT004', 'DOC015', 'MED036', '5 mg', 'Before meals', 90, 3, 'Cancelled', TO_DATE('2024-04-09 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX036', 'PAT005', 'DOC016', 'MED037', '100 mg', 'After meals', 5, 5, 'Dispensed', TO_DATE('2024-04-11 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX037', 'PAT006', 'DOC017', 'MED002', '250 mg', 'Once daily', 7, 10, 'Dispensed', TO_DATE('2024-04-13 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX038', 'PAT007', 'DOC018', 'MED039', '1 puff', 'Twice daily', 10, 14, 'Dispensed', TO_DATE('2024-04-15 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX039', 'PAT008', 'DOC019', 'MED040', '5 ml', 'Three times daily', 14, 20, 'Pending', TO_DATE('2024-04-17 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX040', 'PAT009', 'DOC020', 'MED041', '40 mg', 'Four times daily', 30, 30, 'Cancelled', TO_DATE('2024-04-19 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX041', 'PAT010', 'DOC001', 'MED001', '500 mg', 'Every 6 hours', 60, 1, 'Cancelled', TO_DATE('2024-04-21 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX042', 'PAT011', 'DOC002', 'MED043', '400 mg', 'Every 8 hours', 90, 2, 'Dispensed', TO_DATE('2024-04-23 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX043', 'PAT012', 'DOC003', 'MED044', '10 mg', 'Every 12 hours', 5, 3, 'Dispensed', TO_DATE('2024-04-25 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX044', 'PAT013', 'DOC004', 'MED045', '20 mg', 'As needed (PRN)', 7, 5, 'Pending', TO_DATE('2024-04-27 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX045', 'PAT014', 'DOC005', 'MED046', '5 mg', 'At bedtime', 10, 10, 'Cancelled', TO_DATE('2024-04-29 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX046', 'PAT015', 'DOC006', 'MED002', '100 mg', 'Weekly', 14, 14, 'Dispensed', TO_DATE('2024-05-01 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX047', 'PAT001', 'DOC007', 'MED048', '250 mg', 'Before meals', 30, 20, 'Dispensed', TO_DATE('2024-05-03 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX048', 'PAT002', 'DOC008', 'MED002', '1 puff', 'After meals', 60, 30, 'Dispensed', TO_DATE('2024-05-05 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX049', 'PAT003', 'DOC009', 'MED003', '5 ml', 'Once daily', 90, 1, 'Pending', TO_DATE('2024-05-07 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX050', 'PAT004', 'DOC010', 'MED004', '40 mg', 'Twice daily', 5, 2, 'Cancelled', TO_DATE('2024-05-09 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX051', 'PAT005', 'DOC011', 'MED005', '500 mg', 'Three times daily', 7, 3, 'Dispensed', TO_DATE('2024-05-11 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX052', 'PAT006', 'DOC012', 'MED006', '400 mg', 'Four times daily', 10, 5, 'Dispensed', TO_DATE('2024-05-13 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX053', 'PAT007', 'DOC013', 'MED007', '10 mg', 'Every 6 hours', 14, 10, 'Dispensed', TO_DATE('2024-05-15 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX054', 'PAT008', 'DOC014', 'MED008', '20 mg', 'Every 8 hours', 30, 14, 'Pending', TO_DATE('2024-05-17 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX055', 'PAT009', 'DOC015', 'MED002', '5 mg', 'Every 12 hours', 60, 20, 'Cancelled', TO_DATE('2024-05-19 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX056', 'PAT010', 'DOC016', 'MED010', '100 mg', 'As needed (PRN)', 90, 30, 'Dispensed', TO_DATE('2024-05-21 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX057', 'PAT011', 'DOC017', 'MED011', '250 mg', 'At bedtime', 5, 1, 'Dispensed', TO_DATE('2024-05-23 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX058', 'PAT012', 'DOC018', 'MED012', '1 puff', 'Weekly', 7, 2, 'Dispensed', TO_DATE('2024-05-25 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX059', 'PAT013', 'DOC019', 'MED013', '5 ml', 'Before meals', 10, 3, 'Pending', TO_DATE('2024-05-27 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX060', 'PAT014', 'DOC020', 'MED014', '40 mg', 'After meals', 14, 5, 'Cancelled', TO_DATE('2024-05-29 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX061', 'PAT015', 'DOC001', 'MED015', '500 mg', 'Once daily', 30, 10, 'Dispensed', TO_DATE('2024-05-31 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX062', 'PAT001', 'DOC002', 'MED016', '400 mg', 'Twice daily', 60, 14, 'Dispensed', TO_DATE('2024-06-02 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX063', 'PAT002', 'DOC003', 'MED017', '10 mg', 'Three times daily', 90, 20, 'Dispensed', TO_DATE('2024-06-04 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX064', 'PAT003', 'DOC004', 'MED002', '20 mg', 'Four times daily', 5, 30, 'Pending', TO_DATE('2024-06-06 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX065', 'PAT004', 'DOC005', 'MED019', '5 mg', 'Every 6 hours', 7, 1, 'Cancelled', TO_DATE('2024-06-08 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX066', 'PAT005', 'DOC006', 'MED020', '100 mg', 'Every 8 hours', 10, 2, 'Dispensed', TO_DATE('2024-06-10 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX067', 'PAT006', 'DOC007', 'MED021', '250 mg', 'Every 12 hours', 14, 3, 'Dispensed', TO_DATE('2024-06-12 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX068', 'PAT007', 'DOC008', 'MED022', '1 puff', 'As needed (PRN)', 30, 5, 'Dispensed', TO_DATE('2024-06-14 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX069', 'PAT008', 'DOC009', 'MED023', '5 ml', 'At bedtime', 60, 10, 'Pending', TO_DATE('2024-06-16 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX070', 'PAT009', 'DOC010', 'MED024', '40 mg', 'Weekly', 90, 14, 'Cancelled', TO_DATE('2024-06-18 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX071', 'PAT010', 'DOC011', 'MED025', '500 mg', 'Before meals', 5, 20, 'Dispensed', TO_DATE('2024-06-20 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX072', 'PAT011', 'DOC012', 'MED026', '400 mg', 'After meals', 7, 30, 'Dispensed', TO_DATE('2024-06-22 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX073', 'PAT012', 'DOC013', 'MED002', '10 mg', 'Once daily', 10, 1, 'Dispensed', TO_DATE('2024-06-24 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX074', 'PAT013', 'DOC014', 'MED028', '20 mg', 'Twice daily', 14, 2, 'Pending', TO_DATE('2024-06-26 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX075', 'PAT014', 'DOC015', 'MED029', '5 mg', 'Three times daily', 30, 3, 'Cancelled', TO_DATE('2024-06-28 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX076', 'PAT015', 'DOC016', 'MED030', '100 mg', 'Four times daily', 60, 5, 'Dispensed', TO_DATE('2024-06-30 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX077', 'PAT001', 'DOC017', 'MED031', '250 mg', 'Every 6 hours', 90, 10, 'Dispensed', TO_DATE('2024-07-02 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX078', 'PAT002', 'DOC018', 'MED032', '1 puff', 'Every 8 hours', 5, 14, 'Dispensed', TO_DATE('2024-07-04 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX079', 'PAT003', 'DOC019', 'MED033', '5 ml', 'Every 12 hours', 7, 20, 'Pending', TO_DATE('2024-07-06 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX080', 'PAT004', 'DOC020', 'MED034', '40 mg', 'As needed (PRN)', 10, 30, 'Cancelled', TO_DATE('2024-07-08 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX081', 'PAT005', 'DOC001', 'MED035', '500 mg', 'At bedtime', 14, 1, 'Dispensed', TO_DATE('2024-07-10 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX082', 'PAT006', 'DOC002', 'MED002', '400 mg', 'Weekly', 30, 2, 'Dispensed', TO_DATE('2024-07-12 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX083', 'PAT007', 'DOC003', 'MED037', '10 mg', 'Before meals', 60, 3, 'Dispensed', TO_DATE('2024-07-14 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX084', 'PAT008', 'DOC004', 'MED038', '20 mg', 'After meals', 90, 5, 'Pending', TO_DATE('2024-07-16 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX085', 'PAT009', 'DOC005', 'MED039', '5 mg', 'Once daily', 5, 10, 'Cancelled', TO_DATE('2024-07-18 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX086', 'PAT010', 'DOC006', 'MED040', '100 mg', 'Twice daily', 7, 14, 'Dispensed', TO_DATE('2024-07-20 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX087', 'PAT011', 'DOC007', 'MED041', '250 mg', 'Three times daily', 10, 20, 'Dispensed', TO_DATE('2024-07-22 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX088', 'PAT012', 'DOC008', 'MED042', '1 puff', 'Four times daily', 14, 30, 'Dispensed', TO_DATE('2024-07-24 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX089', 'PAT013', 'DOC009', 'MED043', '5 ml', 'Every 6 hours', 30, 1, 'Pending', TO_DATE('2024-07-26 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX090', 'PAT014', 'DOC010', 'MED044', '40 mg', 'Every 8 hours', 60, 2, 'Cancelled', TO_DATE('2024-07-28 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX091', 'PAT015', 'DOC011', 'MED002', '500 mg', 'Every 12 hours', 90, 3, 'Dispensed', TO_DATE('2024-07-30 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX092', 'PAT001', 'DOC012', 'MED046', '400 mg', 'As needed (PRN)', 5, 5, 'Dispensed', TO_DATE('2024-08-01 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX093', 'PAT002', 'DOC013', 'MED047', '10 mg', 'At bedtime', 7, 10, 'Dispensed', TO_DATE('2024-08-03 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX094', 'PAT003', 'DOC014', 'MED048', '20 mg', 'Weekly', 10, 14, 'Pending', TO_DATE('2024-08-05 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX095', 'PAT004', 'DOC015', 'MED002', '5 mg', 'Before meals', 14, 20, 'Cancelled', TO_DATE('2024-08-07 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX096', 'PAT005', 'DOC016', 'MED003', '100 mg', 'After meals', 30, 30, 'Dispensed', TO_DATE('2024-08-09 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX097', 'PAT006', 'DOC017', 'MED004', '250 mg', 'Once daily', 60, 1, 'Dispensed', TO_DATE('2024-08-11 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX098', 'PAT007', 'DOC018', 'MED005', '1 puff', 'Twice daily', 90, 2, 'Dispensed', TO_DATE('2024-08-13 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX099', 'PAT008', 'DOC019', 'MED006', '5 ml', 'Three times daily', 5, 3, 'Pending', TO_DATE('2024-08-15 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX100', 'PAT009', 'DOC020', 'MED002', '40 mg', 'Four times daily', 7, 5, 'Cancelled', TO_DATE('2024-08-17 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX101', 'PAT010', 'DOC001', 'MED008', '500 mg', 'Every 6 hours', 10, 10, 'Dispensed', TO_DATE('2024-08-19 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX102', 'PAT011', 'DOC002', 'MED009', '400 mg', 'Every 8 hours', 14, 14, 'Dispensed', TO_DATE('2024-08-21 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX103', 'PAT012', 'DOC003', 'MED010', '10 mg', 'Every 12 hours', 30, 20, 'Dispensed', TO_DATE('2024-08-23 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX104', 'PAT013', 'DOC004', 'MED011', '20 mg', 'As needed (PRN)', 60, 30, 'Pending', TO_DATE('2024-08-25 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX105', 'PAT014', 'DOC005', 'MED012', '5 mg', 'At bedtime', 90, 1, 'Cancelled', TO_DATE('2024-08-27 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX106', 'PAT015', 'DOC006', 'MED013', '100 mg', 'Weekly', 5, 2, 'Dispensed', TO_DATE('2024-08-29 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX107', 'PAT016', 'DOC007', 'MED014', '250 mg', 'Before meals', 7, 3, 'Dispensed', TO_DATE('2024-08-31 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX108', 'PAT017', 'DOC008', 'MED015', '1 puff', 'After meals', 10, 5, 'Dispensed', TO_DATE('2024-09-02 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX109', 'PAT018', 'DOC009', 'MED002', '5 ml', 'Once daily', 14, 10, 'Pending', TO_DATE('2024-09-04 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX110', 'PAT019', 'DOC010', 'MED017', '40 mg', 'Twice daily', 30, 14, 'Cancelled', TO_DATE('2024-09-06 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX111', 'PAT020', 'DOC011', 'MED018', '500 mg', 'Three times daily', 60, 20, 'Dispensed', TO_DATE('2024-09-08 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX112', 'PAT021', 'DOC012', 'MED019', '400 mg', 'Four times daily', 90, 30, 'Dispensed', TO_DATE('2024-09-10 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX113', 'PAT022', 'DOC013', 'MED020', '10 mg', 'Every 6 hours', 5, 1, 'Dispensed', TO_DATE('2024-09-12 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX114', 'PAT023', 'DOC014', 'MED021', '20 mg', 'Every 8 hours', 7, 2, 'Pending', TO_DATE('2024-09-14 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX115', 'PAT024', 'DOC015', 'MED022', '5 mg', 'Every 12 hours', 10, 3, 'Cancelled', TO_DATE('2024-09-16 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX116', 'PAT025', 'DOC016', 'MED023', '100 mg', 'As needed (PRN)', 14, 5, 'Dispensed', TO_DATE('2024-09-18 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX117', 'PAT026', 'DOC017', 'MED024', '250 mg', 'At bedtime', 30, 10, 'Dispensed', TO_DATE('2024-09-20 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX118', 'PAT027', 'DOC018', 'MED002', '1 puff', 'Weekly', 60, 14, 'Dispensed', TO_DATE('2024-09-22 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX119', 'PAT028', 'DOC019', 'MED026', '5 ml', 'Before meals', 90, 20, 'Pending', TO_DATE('2024-09-24 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX120', 'PAT029', 'DOC020', 'MED027', '40 mg', 'After meals', 5, 30, 'Cancelled', TO_DATE('2024-09-26 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX121', 'PAT030', 'DOC001', 'MED028', '500 mg', 'Once daily', 7, 1, 'Dispensed', TO_DATE('2024-09-28 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX122', 'PAT031', 'DOC002', 'MED029', '400 mg', 'Twice daily', 10, 2, 'Dispensed', TO_DATE('2024-09-30 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX123', 'PAT032', 'DOC003', 'MED030', '10 mg', 'Three times daily', 14, 3, 'Dispensed', TO_DATE('2024-10-02 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX124', 'PAT033', 'DOC004', 'MED031', '20 mg', 'Four times daily', 30, 5, 'Pending', TO_DATE('2024-10-04 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX125', 'PAT034', 'DOC005', 'MED032', '5 mg', 'Every 6 hours', 60, 10, 'Cancelled', TO_DATE('2024-10-06 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX126', 'PAT035', 'DOC006', 'MED033', '100 mg', 'Every 8 hours', 90, 14, 'Dispensed', TO_DATE('2024-10-08 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX127', 'PAT036', 'DOC007', 'MED002', '250 mg', 'Every 12 hours', 5, 20, 'Dispensed', TO_DATE('2024-10-10 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX128', 'PAT037', 'DOC008', 'MED035', '1 puff', 'As needed (PRN)', 7, 30, 'Dispensed', TO_DATE('2024-10-12 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX129', 'PAT038', 'DOC009', 'MED036', '5 ml', 'At bedtime', 10, 1, 'Pending', TO_DATE('2024-10-14 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX130', 'PAT039', 'DOC010', 'MED037', '40 mg', 'Weekly', 14, 2, 'Cancelled', TO_DATE('2024-10-16 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX131', 'PAT040', 'DOC011', 'MED038', '500 mg', 'Before meals', 30, 3, 'Dispensed', TO_DATE('2024-10-18 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX132', 'PAT041', 'DOC012', 'MED039', '400 mg', 'After meals', 60, 5, 'Dispensed', TO_DATE('2024-10-20 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX133', 'PAT042', 'DOC013', 'MED040', '10 mg', 'Once daily', 90, 10, 'Dispensed', TO_DATE('2024-10-22 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX134', 'PAT043', 'DOC014', 'MED041', '20 mg', 'Twice daily', 5, 14, 'Pending', TO_DATE('2024-10-24 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX135', 'PAT044', 'DOC015', 'MED042', '5 mg', 'Three times daily', 7, 20, 'Cancelled', TO_DATE('2024-10-26 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX136', 'PAT045', 'DOC016', 'MED002', '100 mg', 'Four times daily', 10, 30, 'Dispensed', TO_DATE('2024-10-28 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX137', 'PAT046', 'DOC017', 'MED044', '250 mg', 'Every 6 hours', 14, 1, 'Dispensed', TO_DATE('2024-10-30 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX138', 'PAT047', 'DOC018', 'MED045', '1 puff', 'Every 8 hours', 30, 2, 'Dispensed', TO_DATE('2024-11-01 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX139', 'PAT048', 'DOC019', 'MED046', '5 ml', 'Every 12 hours', 60, 3, 'Pending', TO_DATE('2024-11-03 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX140', 'PAT049', 'DOC020', 'MED047', '40 mg', 'As needed (PRN)', 90, 5, 'Cancelled', TO_DATE('2024-11-05 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX141', 'PAT050', 'DOC001', 'MED048', '500 mg', 'At bedtime', 5, 10, 'Dispensed', TO_DATE('2024-11-07 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX142', 'PAT051', 'DOC002', 'MED002', '400 mg', 'Weekly', 7, 14, 'Dispensed', TO_DATE('2024-11-09 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX143', 'PAT052', 'DOC003', 'MED003', '10 mg', 'Before meals', 10, 20, 'Dispensed', TO_DATE('2024-11-11 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX144', 'PAT053', 'DOC004', 'MED004', '20 mg', 'After meals', 14, 30, 'Pending', TO_DATE('2024-11-13 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX145', 'PAT054', 'DOC005', 'MED002', '5 mg', 'Once daily', 30, 1, 'Cancelled', TO_DATE('2024-11-15 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX146', 'PAT055', 'DOC006', 'MED006', '100 mg', 'Twice daily', 60, 2, 'Dispensed', TO_DATE('2024-11-17 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX147', 'PAT056', 'DOC007', 'MED007', '250 mg', 'Three times daily', 90, 3, 'Dispensed', TO_DATE('2024-11-19 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX148', 'PAT057', 'DOC008', 'MED008', '1 puff', 'Four times daily', 5, 5, 'Dispensed', TO_DATE('2024-11-21 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX149', 'PAT058', 'DOC009', 'MED009', '5 ml', 'Every 6 hours', 7, 10, 'Pending', TO_DATE('2024-11-23 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX150', 'PAT059', 'DOC010', 'MED010', '40 mg', 'Every 8 hours', 10, 14, 'Cancelled', TO_DATE('2024-11-25 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX151', 'PAT060', 'DOC011', 'MED011', '500 mg', 'Every 12 hours', 14, 20, 'Dispensed', TO_DATE('2024-11-27 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX152', 'PAT061', 'DOC012', 'MED012', '400 mg', 'As needed (PRN)', 30, 30, 'Dispensed', TO_DATE('2024-11-29 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX153', 'PAT062', 'DOC013', 'MED013', '10 mg', 'At bedtime', 60, 1, 'Dispensed', TO_DATE('2024-12-01 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX154', 'PAT063', 'DOC014', 'MED002', '20 mg', 'Weekly', 90, 2, 'Pending', TO_DATE('2024-12-03 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX155', 'PAT064', 'DOC015', 'MED015', '5 mg', 'Before meals', 5, 3, 'Cancelled', TO_DATE('2024-12-05 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX156', 'PAT065', 'DOC016', 'MED016', '100 mg', 'After meals', 7, 5, 'Dispensed', TO_DATE('2024-12-07 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX157', 'PAT066', 'DOC017', 'MED017', '250 mg', 'Once daily', 10, 10, 'Dispensed', TO_DATE('2024-12-09 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX158', 'PAT067', 'DOC018', 'MED018', '1 puff', 'Twice daily', 14, 14, 'Dispensed', TO_DATE('2024-12-11 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX159', 'PAT068', 'DOC019', 'MED019', '5 ml', 'Three times daily', 30, 20, 'Pending', TO_DATE('2024-12-13 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX160', 'PAT069', 'DOC020', 'MED020', '40 mg', 'Four times daily', 60, 30, 'Cancelled', TO_DATE('2024-12-15 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX161', 'PAT070', 'DOC001', 'MED021', '500 mg', 'Every 6 hours', 90, 1, 'Dispensed', TO_DATE('2024-12-17 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX162', 'PAT071', 'DOC002', 'MED022', '400 mg', 'Every 8 hours', 5, 2, 'Dispensed', TO_DATE('2024-12-19 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX163', 'PAT072', 'DOC003', 'MED002', '10 mg', 'Every 12 hours', 7, 3, 'Dispensed', TO_DATE('2024-12-21 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX164', 'PAT073', 'DOC004', 'MED024', '20 mg', 'As needed (PRN)', 10, 5, 'Pending', TO_DATE('2024-12-23 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX165', 'PAT074', 'DOC005', 'MED025', '5 mg', 'At bedtime', 14, 10, 'Cancelled', TO_DATE('2024-12-25 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX166', 'PAT075', 'DOC006', 'MED026', '100 mg', 'Weekly', 30, 14, 'Dispensed', TO_DATE('2024-12-27 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX167', 'PAT076', 'DOC007', 'MED027', '250 mg', 'Before meals', 60, 20, 'Dispensed', TO_DATE('2024-12-29 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX168', 'PAT077', 'DOC008', 'MED028', '1 puff', 'After meals', 90, 30, 'Dispensed', TO_DATE('2024-12-31 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX169', 'PAT078', 'DOC009', 'MED029', '5 ml', 'Once daily', 5, 1, 'Pending', TO_DATE('2025-01-02 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX170', 'PAT079', 'DOC010', 'MED030', '40 mg', 'Twice daily', 7, 2, 'Cancelled', TO_DATE('2025-01-04 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX171', 'PAT080', 'DOC011', 'MED031', '500 mg', 'Three times daily', 10, 3, 'Dispensed', TO_DATE('2025-01-06 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX172', 'PAT081', 'DOC012', 'MED002', '400 mg', 'Four times daily', 14, 5, 'Dispensed', TO_DATE('2025-01-08 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX173', 'PAT082', 'DOC013', 'MED033', '10 mg', 'Every 6 hours', 30, 10, 'Dispensed', TO_DATE('2025-01-10 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX174', 'PAT083', 'DOC014', 'MED034', '20 mg', 'Every 8 hours', 60, 14, 'Pending', TO_DATE('2025-01-12 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX175', 'PAT084', 'DOC015', 'MED035', '5 mg', 'Every 12 hours', 90, 20, 'Cancelled', TO_DATE('2025-01-14 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX176', 'PAT085', 'DOC016', 'MED036', '100 mg', 'As needed (PRN)', 5, 30, 'Dispensed', TO_DATE('2025-01-16 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX177', 'PAT086', 'DOC017', 'MED037', '250 mg', 'At bedtime', 7, 1, 'Dispensed', TO_DATE('2025-01-18 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX178', 'PAT087', 'DOC018', 'MED038', '1 puff', 'Weekly', 10, 2, 'Dispensed', TO_DATE('2025-01-20 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX179', 'PAT088', 'DOC019', 'MED039', '5 ml', 'Before meals', 14, 3, 'Pending', TO_DATE('2025-01-22 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX180', 'PAT089', 'DOC020', 'MED040', '40 mg', 'After meals', 30, 5, 'Cancelled', TO_DATE('2025-01-24 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX181', 'PAT090', 'DOC001', 'MED002', '500 mg', 'Once daily', 60, 10, 'Dispensed', TO_DATE('2025-01-26 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX182', 'PAT091', 'DOC002', 'MED042', '400 mg', 'Twice daily', 90, 14, 'Dispensed', TO_DATE('2025-01-28 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX183', 'PAT092', 'DOC003', 'MED043', '10 mg', 'Three times daily', 5, 20, 'Dispensed', TO_DATE('2025-01-30 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX184', 'PAT093', 'DOC004', 'MED044', '20 mg', 'Four times daily', 7, 30, 'Pending', TO_DATE('2025-02-01 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX185', 'PAT094', 'DOC005', 'MED045', '5 mg', 'Every 6 hours', 10, 1, 'Cancelled', TO_DATE('2025-02-03 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX186', 'PAT095', 'DOC006', 'MED046', '100 mg', 'Every 8 hours', 14, 2, 'Dispensed', TO_DATE('2025-02-05 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX187', 'PAT096', 'DOC007', 'MED047', '250 mg', 'Every 12 hours', 30, 3, 'Dispensed', TO_DATE('2025-02-07 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX188', 'PAT097', 'DOC008', 'MED048', '1 puff', 'As needed (PRN)', 60, 5, 'Dispensed', TO_DATE('2025-02-09 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX189', 'PAT098', 'DOC009', 'MED002', '5 ml', 'At bedtime', 90, 10, 'Pending', TO_DATE('2025-02-11 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX190', 'PAT099', 'DOC010', 'MED002', '40 mg', 'Weekly', 5, 14, 'Cancelled', TO_DATE('2025-02-13 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX191', 'PAT100', 'DOC011', 'MED004', '500 mg', 'Before meals', 7, 20, 'Dispensed', TO_DATE('2025-02-15 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX192', 'PAT016', 'DOC012', 'MED005', '400 mg', 'After meals', 10, 30, 'Dispensed', TO_DATE('2025-02-17 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX193', 'PAT017', 'DOC013', 'MED006', '10 mg', 'Once daily', 14, 1, 'Dispensed', TO_DATE('2025-02-19 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX194', 'PAT018', 'DOC014', 'MED007', '20 mg', 'Twice daily', 30, 2, 'Pending', TO_DATE('2025-02-21 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX195', 'PAT019', 'DOC015', 'MED008', '5 mg', 'Three times daily', 60, 3, 'Cancelled', TO_DATE('2025-02-23 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX196', 'PAT020', 'DOC016', 'MED009', '100 mg', 'Four times daily', 90, 5, 'Dispensed', TO_DATE('2025-02-25 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX197', 'PAT021', 'DOC017', 'MED010', '250 mg', 'Every 6 hours', 5, 10, 'Dispensed', TO_DATE('2025-02-27 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX198', 'PAT022', 'DOC018', 'MED011', '1 puff', 'Every 8 hours', 7, 14, 'Dispensed', TO_DATE('2025-03-01 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX199', 'PAT023', 'DOC019', 'MED002', '5 ml', 'Every 12 hours', 10, 20, 'Pending', TO_DATE('2025-03-03 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX200', 'PAT024', 'DOC020', 'MED013', '40 mg', 'As needed (PRN)', 14, 30, 'Cancelled', TO_DATE('2025-03-05 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX201', 'PAT025', 'DOC001', 'MED014', '500 mg', 'At bedtime', 30, 1, 'Dispensed', TO_DATE('2025-03-07 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX202', 'PAT026', 'DOC002', 'MED015', '400 mg', 'Weekly', 60, 2, 'Dispensed', TO_DATE('2025-03-09 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX203', 'PAT027', 'DOC003', 'MED016', '10 mg', 'Before meals', 90, 3, 'Dispensed', TO_DATE('2025-03-11 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX204', 'PAT028', 'DOC004', 'MED017', '20 mg', 'After meals', 5, 5, 'Pending', TO_DATE('2025-03-13 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX205', 'PAT029', 'DOC005', 'MED018', '5 mg', 'Once daily', 7, 10, 'Cancelled', TO_DATE('2025-03-15 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX206', 'PAT030', 'DOC006', 'MED019', '100 mg', 'Twice daily', 10, 14, 'Dispensed', TO_DATE('2025-03-17 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX207', 'PAT031', 'DOC007', 'MED020', '250 mg', 'Three times daily', 14, 20, 'Dispensed', TO_DATE('2025-03-19 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX208', 'PAT032', 'DOC008', 'MED002', '1 puff', 'Four times daily', 30, 30, 'Dispensed', TO_DATE('2025-03-21 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX209', 'PAT033', 'DOC009', 'MED022', '5 ml', 'Every 6 hours', 60, 1, 'Pending', TO_DATE('2025-03-23 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX210', 'PAT034', 'DOC010', 'MED023', '40 mg', 'Every 8 hours', 90, 2, 'Cancelled', TO_DATE('2025-03-25 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX211', 'PAT035', 'DOC011', 'MED024', '500 mg', 'Every 12 hours', 5, 3, 'Dispensed', TO_DATE('2025-03-27 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX212', 'PAT036', 'DOC012', 'MED025', '400 mg', 'As needed (PRN)', 7, 5, 'Dispensed', TO_DATE('2025-03-29 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX213', 'PAT037', 'DOC013', 'MED026', '10 mg', 'At bedtime', 10, 10, 'Dispensed', TO_DATE('2025-03-31 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX214', 'PAT038', 'DOC014', 'MED027', '20 mg', 'Weekly', 14, 14, 'Pending', TO_DATE('2025-04-02 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX215', 'PAT039', 'DOC015', 'MED028', '5 mg', 'Before meals', 30, 20, 'Cancelled', TO_DATE('2025-04-04 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX216', 'PAT040', 'DOC016', 'MED029', '100 mg', 'After meals', 60, 30, 'Dispensed', TO_DATE('2025-04-06 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX217', 'PAT041', 'DOC017', 'MED002', '250 mg', 'Once daily', 90, 1, 'Dispensed', TO_DATE('2025-04-08 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX218', 'PAT042', 'DOC018', 'MED031', '1 puff', 'Twice daily', 5, 2, 'Dispensed', TO_DATE('2025-04-10 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX219', 'PAT043', 'DOC019', 'MED032', '5 ml', 'Three times daily', 7, 3, 'Pending', TO_DATE('2025-04-12 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX220', 'PAT044', 'DOC020', 'MED033', '40 mg', 'Four times daily', 10, 5, 'Cancelled', TO_DATE('2025-04-14 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX221', 'PAT045', 'DOC001', 'MED034', '500 mg', 'Every 6 hours', 14, 10, 'Dispensed', TO_DATE('2025-04-16 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX222', 'PAT046', 'DOC002', 'MED035', '400 mg', 'Every 8 hours', 30, 14, 'Dispensed', TO_DATE('2025-04-18 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX223', 'PAT047', 'DOC003', 'MED036', '10 mg', 'Every 12 hours', 60, 20, 'Dispensed', TO_DATE('2025-04-20 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX224', 'PAT048', 'DOC004', 'MED037', '20 mg', 'As needed (PRN)', 90, 30, 'Pending', TO_DATE('2025-04-22 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX225', 'PAT049', 'DOC005', 'MED038', '5 mg', 'At bedtime', 5, 1, 'Cancelled', TO_DATE('2025-04-24 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX226', 'PAT050', 'DOC006', 'MED002', '100 mg', 'Weekly', 7, 2, 'Dispensed', TO_DATE('2025-04-26 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX227', 'PAT051', 'DOC007', 'MED040', '250 mg', 'Before meals', 10, 3, 'Dispensed', TO_DATE('2025-04-28 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX228', 'PAT052', 'DOC008', 'MED041', '1 puff', 'After meals', 14, 5, 'Dispensed', TO_DATE('2025-04-30 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX229', 'PAT053', 'DOC009', 'MED042', '5 ml', 'Once daily', 30, 10, 'Pending', TO_DATE('2025-05-02 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX230', 'PAT054', 'DOC010', 'MED043', '40 mg', 'Twice daily', 60, 14, 'Cancelled', TO_DATE('2025-05-04 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX231', 'PAT055', 'DOC011', 'MED044', '500 mg', 'Three times daily', 90, 20, 'Dispensed', TO_DATE('2025-05-06 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX232', 'PAT056', 'DOC012', 'MED045', '400 mg', 'Four times daily', 5, 30, 'Dispensed', TO_DATE('2025-05-08 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX233', 'PAT057', 'DOC013', 'MED046', '10 mg', 'Every 6 hours', 7, 1, 'Dispensed', TO_DATE('2025-05-10 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX234', 'PAT058', 'DOC014', 'MED047', '20 mg', 'Every 8 hours', 10, 2, 'Pending', TO_DATE('2025-05-12 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX235', 'PAT059', 'DOC015', 'MED002', '5 mg', 'Every 12 hours', 14, 3, 'Cancelled', TO_DATE('2025-05-14 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX236', 'PAT060', 'DOC016', 'MED002', '100 mg', 'As needed (PRN)', 30, 5, 'Dispensed', TO_DATE('2025-05-16 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX237', 'PAT061', 'DOC017', 'MED003', '250 mg', 'At bedtime', 60, 10, 'Dispensed', TO_DATE('2025-05-18 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX238', 'PAT062', 'DOC018', 'MED004', '1 puff', 'Weekly', 90, 14, 'Dispensed', TO_DATE('2025-05-20 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX239', 'PAT063', 'DOC019', 'MED005', '5 ml', 'Before meals', 5, 20, 'Pending', TO_DATE('2025-05-22 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX240', 'PAT064', 'DOC020', 'MED006', '40 mg', 'After meals', 7, 30, 'Cancelled', TO_DATE('2025-05-24 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX241', 'PAT065', 'DOC001', 'MED007', '500 mg', 'Once daily', 10, 1, 'Dispensed', TO_DATE('2025-05-26 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX242', 'PAT066', 'DOC002', 'MED008', '400 mg', 'Twice daily', 14, 2, 'Dispensed', TO_DATE('2025-05-28 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX243', 'PAT067', 'DOC003', 'MED009', '10 mg', 'Three times daily', 30, 3, 'Dispensed', TO_DATE('2025-05-30 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX244', 'PAT068', 'DOC004', 'MED002', '20 mg', 'Four times daily', 60, 5, 'Pending', TO_DATE('2025-06-01 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX245', 'PAT069', 'DOC005', 'MED011', '5 mg', 'Every 6 hours', 90, 10, 'Cancelled', TO_DATE('2025-06-03 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX246', 'PAT070', 'DOC006', 'MED012', '100 mg', 'Every 8 hours', 5, 14, 'Dispensed', TO_DATE('2025-06-05 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX247', 'PAT071', 'DOC007', 'MED013', '250 mg', 'Every 12 hours', 7, 20, 'Dispensed', TO_DATE('2025-06-07 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX248', 'PAT072', 'DOC008', 'MED014', '1 puff', 'As needed (PRN)', 10, 30, 'Dispensed', TO_DATE('2025-06-09 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX249', 'PAT073', 'DOC009', 'MED015', '5 ml', 'At bedtime', 14, 1, 'Pending', TO_DATE('2025-06-11 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX250', 'PAT074', 'DOC010', 'MED016', '40 mg', 'Weekly', 30, 2, 'Cancelled', TO_DATE('2025-06-13 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX251', 'PAT075', 'DOC011', 'MED017', '500 mg', 'Before meals', 60, 3, 'Dispensed', TO_DATE('2025-06-15 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX252', 'PAT076', 'DOC012', 'MED018', '400 mg', 'After meals', 90, 5, 'Dispensed', TO_DATE('2025-06-17 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX253', 'PAT077', 'DOC013', 'MED002', '10 mg', 'Once daily', 5, 10, 'Dispensed', TO_DATE('2025-06-19 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX254', 'PAT078', 'DOC014', 'MED020', '20 mg', 'Twice daily', 7, 14, 'Pending', TO_DATE('2025-06-21 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX255', 'PAT079', 'DOC015', 'MED021', '5 mg', 'Three times daily', 10, 20, 'Cancelled', TO_DATE('2025-06-23 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX256', 'PAT080', 'DOC016', 'MED022', '100 mg', 'Four times daily', 14, 30, 'Dispensed', TO_DATE('2025-06-25 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX257', 'PAT081', 'DOC017', 'MED023', '250 mg', 'Every 6 hours', 30, 1, 'Dispensed', TO_DATE('2025-06-27 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX258', 'PAT082', 'DOC018', 'MED024', '1 puff', 'Every 8 hours', 60, 2, 'Dispensed', TO_DATE('2025-06-29 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX259', 'PAT083', 'DOC019', 'MED025', '5 ml', 'Every 12 hours', 90, 3, 'Pending', TO_DATE('2025-07-01 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX260', 'PAT084', 'DOC020', 'MED026', '40 mg', 'As needed (PRN)', 5, 5, 'Cancelled', TO_DATE('2025-07-03 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX261', 'PAT085', 'DOC001', 'MED027', '500 mg', 'At bedtime', 7, 10, 'Dispensed', TO_DATE('2025-07-05 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX262', 'PAT086', 'DOC002', 'MED002', '400 mg', 'Weekly', 10, 14, 'Dispensed', TO_DATE('2025-07-07 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX263', 'PAT087', 'DOC003', 'MED029', '10 mg', 'Before meals', 14, 20, 'Dispensed', TO_DATE('2025-07-09 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX264', 'PAT088', 'DOC004', 'MED030', '20 mg', 'After meals', 30, 30, 'Pending', TO_DATE('2025-07-11 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX265', 'PAT089', 'DOC005', 'MED031', '5 mg', 'Once daily', 60, 1, 'Cancelled', TO_DATE('2025-07-13 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX266', 'PAT090', 'DOC006', 'MED032', '100 mg', 'Twice daily', 90, 2, 'Dispensed', TO_DATE('2025-07-15 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX267', 'PAT091', 'DOC007', 'MED033', '250 mg', 'Three times daily', 5, 3, 'Dispensed', TO_DATE('2025-07-17 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX268', 'PAT092', 'DOC008', 'MED034', '1 puff', 'Four times daily', 7, 5, 'Dispensed', TO_DATE('2025-07-19 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX269', 'PAT093', 'DOC009', 'MED035', '5 ml', 'Every 6 hours', 10, 10, 'Pending', TO_DATE('2025-07-21 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX270', 'PAT094', 'DOC010', 'MED036', '40 mg', 'Every 8 hours', 14, 14, 'Cancelled', TO_DATE('2025-07-23 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX271', 'PAT095', 'DOC011', 'MED002', '500 mg', 'Every 12 hours', 30, 20, 'Dispensed', TO_DATE('2025-07-25 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX272', 'PAT096', 'DOC012', 'MED038', '400 mg', 'As needed (PRN)', 60, 30, 'Dispensed', TO_DATE('2025-07-27 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX273', 'PAT097', 'DOC013', 'MED039', '10 mg', 'At bedtime', 90, 1, 'Dispensed', TO_DATE('2025-07-29 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX274', 'PAT098', 'DOC014', 'MED040', '20 mg', 'Weekly', 5, 2, 'Pending', TO_DATE('2025-07-31 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX275', 'PAT099', 'DOC015', 'MED041', '5 mg', 'Before meals', 7, 3, 'Cancelled', TO_DATE('2025-08-02 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX276', 'PAT100', 'DOC016', 'MED042', '100 mg', 'After meals', 10, 5, 'Dispensed', TO_DATE('2025-08-04 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX277', 'PAT016', 'DOC017', 'MED043', '250 mg', 'Once daily', 14, 10, 'Dispensed', TO_DATE('2025-08-06 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX278', 'PAT017', 'DOC018', 'MED044', '1 puff', 'Twice daily', 30, 14, 'Dispensed', TO_DATE('2025-08-08 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX279', 'PAT018', 'DOC019', 'MED045', '5 ml', 'Three times daily', 60, 20, 'Pending', TO_DATE('2025-08-10 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX280', 'PAT019', 'DOC020', 'MED002', '40 mg', 'Four times daily', 90, 30, 'Cancelled', TO_DATE('2025-08-12 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX281', 'PAT020', 'DOC001', 'MED047', '500 mg', 'Every 6 hours', 5, 1, 'Dispensed', TO_DATE('2025-08-14 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX282', 'PAT021', 'DOC002', 'MED048', '400 mg', 'Every 8 hours', 7, 2, 'Dispensed', TO_DATE('2025-08-16 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX283', 'PAT022', 'DOC003', 'MED002', '10 mg', 'Every 12 hours', 10, 3, 'Dispensed', TO_DATE('2025-08-18 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX284', 'PAT023', 'DOC004', 'MED003', '20 mg', 'As needed (PRN)', 14, 5, 'Pending', TO_DATE('2025-08-20 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX285', 'PAT024', 'DOC005', 'MED004', '5 mg', 'At bedtime', 30, 10, 'Cancelled', TO_DATE('2025-08-22 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX286', 'PAT025', 'DOC006', 'MED005', '100 mg', 'Weekly', 60, 14, 'Dispensed', TO_DATE('2025-08-24 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX287', 'PAT026', 'DOC007', 'MED006', '250 mg', 'Before meals', 90, 20, 'Dispensed', TO_DATE('2025-08-26 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX288', 'PAT027', 'DOC008', 'MED007', '1 puff', 'After meals', 5, 30, 'Dispensed', TO_DATE('2025-08-28 12:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX289', 'PAT028', 'DOC009', 'MED002', '5 ml', 'Once daily', 7, 1, 'Pending', TO_DATE('2025-08-30 09:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX290', 'PAT029', 'DOC010', 'MED009', '40 mg', 'Twice daily', 10, 2, 'Cancelled', TO_DATE('2025-09-01 09:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX291', 'PAT030', 'DOC011', 'MED010', '500 mg', 'Three times daily', 14, 3, 'Dispensed', TO_DATE('2025-09-03 09:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX292', 'PAT031', 'DOC012', 'MED011', '400 mg', 'Four times daily', 30, 5, 'Dispensed', TO_DATE('2025-09-05 10:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX293', 'PAT032', 'DOC013', 'MED012', '10 mg', 'Every 6 hours', 60, 10, 'Dispensed', TO_DATE('2025-09-07 10:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX294', 'PAT033', 'DOC014', 'MED013', '20 mg', 'Every 8 hours', 90, 14, 'Pending', TO_DATE('2025-09-09 10:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX295', 'PAT034', 'DOC015', 'MED014', '5 mg', 'Every 12 hours', 5, 20, 'Cancelled', TO_DATE('2025-09-11 11:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX296', 'PAT035', 'DOC016', 'MED015', '100 mg', 'As needed (PRN)', 7, 30, 'Dispensed', TO_DATE('2025-09-13 11:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX297', 'PAT036', 'DOC017', 'MED016', '250 mg', 'At bedtime', 10, 1, 'Dispensed', TO_DATE('2025-09-15 11:40', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX298', 'PAT037', 'DOC018', 'MED002', '1 puff', 'Weekly', 14, 2, 'Dispensed', TO_DATE('2025-09-17 12:00', 'YYYY-MM-DD HH24:MI'), 'Take with a full glass of water as directed.');
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX299', 'PAT038', 'DOC019', 'MED018', '5 ml', 'Before meals', 30, 3, 'Pending', TO_DATE('2025-09-19 12:20', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes) VALUES ('RX300', 'PAT039', 'DOC020', 'MED019', '40 mg', 'After meals', 60, 5, 'Cancelled', TO_DATE('2025-09-21 12:40', 'YYYY-MM-DD HH24:MI'), NULL);

COMMIT;

-- Source: scripts/02_seeds/student4_pharmacy_lab/insert_laboratory_test.sql
-- SEED DATA: LaboratoryTest (Student 4) - 200 rows
-- Row 1 omits RequestedDate (SYSDATE), CompletedDate (NULL), TestStatus ('Pending'), and TestResult (NULL).

INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, TestCost) VALUES ('LAB001', 'PAT001', 'DOC002', 'Complete Blood Count (CBC)', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB002', 'PAT002', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-01-18', DATE '2024-01-20', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB003', 'PAT003', 'DOC003', 'Lipid Profile Panel', DATE '2024-01-21', DATE '2024-01-24', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB004', 'PAT004', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-01-24', NULL, 'Pending', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB005', 'PAT005', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-01-27', NULL, 'In-Progress', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB006', 'PAT006', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-01-30', NULL, 'Sample Collected', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB007', 'PAT007', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-02-02', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB008', 'PAT008', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-02-05', DATE '2024-02-09', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB009', 'PAT009', 'DOC009', 'Liver Function Test Panel', DATE '2024-02-08', DATE '2024-02-09', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB010', 'PAT010', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-02-11', DATE '2024-02-13', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB011', 'PAT011', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-02-14', NULL, 'Pending', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB012', 'PAT012', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-02-17', NULL, 'In-Progress', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB013', 'PAT013', 'DOC013', 'Lipid Profile Panel', DATE '2024-02-20', NULL, 'Sample Collected', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB014', 'PAT014', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-02-23', NULL, 'Cancelled', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB015', 'PAT015', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-02-26', DATE '2024-02-29', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB016', 'PAT016', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-02-29', DATE '2024-03-04', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB017', 'PAT017', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-03-03', DATE '2024-03-04', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB018', 'PAT018', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-03-06', NULL, 'Pending', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB019', 'PAT019', 'DOC019', 'Liver Function Test Panel', DATE '2024-03-09', NULL, 'In-Progress', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB020', 'PAT020', 'DOC020', 'Renal Function Urea Creatinine', DATE '2024-03-12', NULL, 'Sample Collected', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB021', 'PAT021', 'DOC001', 'Complete Blood Count (CBC)', DATE '2024-03-15', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB022', 'PAT022', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-03-18', DATE '2024-03-20', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB023', 'PAT023', 'DOC003', 'Lipid Profile Panel', DATE '2024-03-21', DATE '2024-03-24', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB024', 'PAT024', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-03-24', DATE '2024-03-28', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB025', 'PAT025', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-03-27', NULL, 'Pending', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB026', 'PAT026', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-03-30', NULL, 'In-Progress', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB027', 'PAT027', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-04-02', NULL, 'Sample Collected', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB028', 'PAT028', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-04-05', NULL, 'Cancelled', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB029', 'PAT029', 'DOC009', 'Liver Function Test Panel', DATE '2024-04-08', DATE '2024-04-09', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB030', 'PAT030', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-04-11', DATE '2024-04-13', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB031', 'PAT031', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-04-14', DATE '2024-04-17', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB032', 'PAT032', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-04-17', NULL, 'Pending', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB033', 'PAT033', 'DOC013', 'Lipid Profile Panel', DATE '2024-04-20', NULL, 'In-Progress', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB034', 'PAT034', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-04-23', NULL, 'Sample Collected', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB035', 'PAT035', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-04-26', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB036', 'PAT036', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-04-29', DATE '2024-05-03', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB037', 'PAT037', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-05-02', DATE '2024-05-03', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB038', 'PAT038', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-05-05', DATE '2024-05-07', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB039', 'PAT039', 'DOC019', 'Liver Function Test Panel', DATE '2024-05-08', NULL, 'Pending', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB040', 'PAT040', 'DOC020', 'Renal Function Urea Creatinine', DATE '2024-05-11', NULL, 'In-Progress', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB041', 'PAT041', 'DOC001', 'Complete Blood Count (CBC)', DATE '2024-05-14', NULL, 'Sample Collected', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB042', 'PAT042', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-05-17', NULL, 'Cancelled', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB043', 'PAT043', 'DOC003', 'Lipid Profile Panel', DATE '2024-05-20', DATE '2024-05-23', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB044', 'PAT044', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-05-23', DATE '2024-05-27', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB045', 'PAT045', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-05-26', DATE '2024-05-27', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB046', 'PAT046', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-05-29', NULL, 'Pending', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB047', 'PAT047', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-06-01', NULL, 'In-Progress', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB048', 'PAT048', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-06-04', NULL, 'Sample Collected', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB049', 'PAT049', 'DOC009', 'Liver Function Test Panel', DATE '2024-06-07', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB050', 'PAT050', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-06-10', DATE '2024-06-12', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB051', 'PAT051', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-06-13', DATE '2024-06-16', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB052', 'PAT052', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-06-16', DATE '2024-06-20', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB053', 'PAT053', 'DOC013', 'Lipid Profile Panel', DATE '2024-06-19', NULL, 'Pending', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB054', 'PAT054', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-06-22', NULL, 'In-Progress', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB055', 'PAT055', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-06-25', NULL, 'Sample Collected', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB056', 'PAT056', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-06-28', NULL, 'Cancelled', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB057', 'PAT057', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-07-01', DATE '2024-07-02', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB058', 'PAT058', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-07-04', DATE '2024-07-06', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB059', 'PAT059', 'DOC019', 'Liver Function Test Panel', DATE '2024-07-07', DATE '2024-07-10', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB060', 'PAT060', 'DOC020', 'Renal Function Urea Creatinine', DATE '2024-07-10', NULL, 'Pending', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB061', 'PAT061', 'DOC001', 'Complete Blood Count (CBC)', DATE '2024-07-13', NULL, 'In-Progress', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB062', 'PAT062', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-07-16', NULL, 'Sample Collected', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB063', 'PAT063', 'DOC003', 'Lipid Profile Panel', DATE '2024-07-19', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB064', 'PAT064', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-07-22', DATE '2024-07-26', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB065', 'PAT065', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-07-25', DATE '2024-07-26', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB066', 'PAT066', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-07-28', DATE '2024-07-30', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB067', 'PAT067', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-07-31', NULL, 'Pending', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB068', 'PAT068', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-08-03', NULL, 'In-Progress', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB069', 'PAT069', 'DOC009', 'Liver Function Test Panel', DATE '2024-08-06', NULL, 'Sample Collected', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB070', 'PAT070', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-08-09', NULL, 'Cancelled', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB071', 'PAT071', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-08-12', DATE '2024-08-15', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB072', 'PAT072', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-08-15', DATE '2024-08-19', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB073', 'PAT073', 'DOC013', 'Lipid Profile Panel', DATE '2024-08-18', DATE '2024-08-19', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB074', 'PAT074', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-08-21', NULL, 'Pending', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB075', 'PAT075', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-08-24', NULL, 'In-Progress', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB076', 'PAT076', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-08-27', NULL, 'Sample Collected', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB077', 'PAT077', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-08-30', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB078', 'PAT078', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-09-02', DATE '2024-09-04', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB079', 'PAT079', 'DOC019', 'Liver Function Test Panel', DATE '2024-09-05', DATE '2024-09-08', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB080', 'PAT080', 'DOC020', 'Renal Function Urea Creatinine', DATE '2024-09-08', DATE '2024-09-12', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB081', 'PAT081', 'DOC001', 'Complete Blood Count (CBC)', DATE '2024-09-11', NULL, 'Pending', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB082', 'PAT082', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-09-14', NULL, 'In-Progress', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB083', 'PAT083', 'DOC003', 'Lipid Profile Panel', DATE '2024-09-17', NULL, 'Sample Collected', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB084', 'PAT084', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-09-20', NULL, 'Cancelled', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB085', 'PAT085', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-09-23', DATE '2024-09-24', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB086', 'PAT086', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-09-26', DATE '2024-09-28', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB087', 'PAT087', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-09-29', DATE '2024-10-02', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB088', 'PAT088', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-10-02', NULL, 'Pending', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB089', 'PAT089', 'DOC009', 'Liver Function Test Panel', DATE '2024-10-05', NULL, 'In-Progress', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB090', 'PAT090', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-10-08', NULL, 'Sample Collected', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB091', 'PAT091', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-10-11', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB092', 'PAT092', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-10-14', DATE '2024-10-18', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB093', 'PAT093', 'DOC013', 'Lipid Profile Panel', DATE '2024-10-17', DATE '2024-10-18', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB094', 'PAT094', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-10-20', DATE '2024-10-22', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB095', 'PAT095', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-10-23', NULL, 'Pending', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB096', 'PAT096', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-10-26', NULL, 'In-Progress', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB097', 'PAT097', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-10-29', NULL, 'Sample Collected', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB098', 'PAT098', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-11-01', NULL, 'Cancelled', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB099', 'PAT099', 'DOC019', 'Liver Function Test Panel', DATE '2024-11-04', DATE '2024-11-07', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB100', 'PAT100', 'DOC020', 'Renal Function Urea Creatinine', DATE '2024-11-07', DATE '2024-11-11', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB101', 'PAT001', 'DOC001', 'Complete Blood Count (CBC)', DATE '2024-11-10', DATE '2024-11-11', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB102', 'PAT002', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2024-11-13', NULL, 'Pending', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB103', 'PAT003', 'DOC003', 'Lipid Profile Panel', DATE '2024-11-16', NULL, 'In-Progress', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB104', 'PAT004', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2024-11-19', NULL, 'Sample Collected', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB105', 'PAT005', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2024-11-22', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB106', 'PAT006', 'DOC006', 'Cardiac Troponin I Assay', DATE '2024-11-25', DATE '2024-11-27', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB107', 'PAT007', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2024-11-28', DATE '2024-12-01', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB108', 'PAT008', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2024-12-01', DATE '2024-12-05', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB109', 'PAT009', 'DOC009', 'Liver Function Test Panel', DATE '2024-12-04', NULL, 'Pending', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB110', 'PAT010', 'DOC010', 'Renal Function Urea Creatinine', DATE '2024-12-07', NULL, 'In-Progress', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB111', 'PAT011', 'DOC011', 'Complete Blood Count (CBC)', DATE '2024-12-10', NULL, 'Sample Collected', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB112', 'PAT012', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2024-12-13', NULL, 'Cancelled', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB113', 'PAT013', 'DOC013', 'Lipid Profile Panel', DATE '2024-12-16', DATE '2024-12-17', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB114', 'PAT014', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2024-12-19', DATE '2024-12-21', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB115', 'PAT015', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2024-12-22', DATE '2024-12-25', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB116', 'PAT016', 'DOC016', 'Cardiac Troponin I Assay', DATE '2024-12-25', NULL, 'Pending', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB117', 'PAT017', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2024-12-28', NULL, 'In-Progress', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB118', 'PAT018', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2024-12-31', NULL, 'Sample Collected', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB119', 'PAT019', 'DOC019', 'Liver Function Test Panel', DATE '2025-01-03', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB120', 'PAT020', 'DOC020', 'Renal Function Urea Creatinine', DATE '2025-01-06', DATE '2025-01-10', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB121', 'PAT021', 'DOC001', 'Complete Blood Count (CBC)', DATE '2025-01-09', DATE '2025-01-10', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB122', 'PAT022', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2025-01-12', DATE '2025-01-14', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB123', 'PAT023', 'DOC003', 'Lipid Profile Panel', DATE '2025-01-15', NULL, 'Pending', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB124', 'PAT024', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2025-01-18', NULL, 'In-Progress', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB125', 'PAT025', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2025-01-21', NULL, 'Sample Collected', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB126', 'PAT026', 'DOC006', 'Cardiac Troponin I Assay', DATE '2025-01-24', NULL, 'Cancelled', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB127', 'PAT027', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2025-01-27', DATE '2025-01-30', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB128', 'PAT028', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2025-01-30', DATE '2025-02-03', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB129', 'PAT029', 'DOC009', 'Liver Function Test Panel', DATE '2025-02-02', DATE '2025-02-03', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB130', 'PAT030', 'DOC010', 'Renal Function Urea Creatinine', DATE '2025-02-05', NULL, 'Pending', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB131', 'PAT031', 'DOC011', 'Complete Blood Count (CBC)', DATE '2025-02-08', NULL, 'In-Progress', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB132', 'PAT032', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2025-02-11', NULL, 'Sample Collected', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB133', 'PAT033', 'DOC013', 'Lipid Profile Panel', DATE '2025-02-14', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB134', 'PAT034', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2025-02-17', DATE '2025-02-19', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB135', 'PAT035', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2025-02-20', DATE '2025-02-23', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB136', 'PAT036', 'DOC016', 'Cardiac Troponin I Assay', DATE '2025-02-23', DATE '2025-02-27', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB137', 'PAT037', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2025-02-26', NULL, 'Pending', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB138', 'PAT038', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2025-03-01', NULL, 'In-Progress', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB139', 'PAT039', 'DOC019', 'Liver Function Test Panel', DATE '2025-03-04', NULL, 'Sample Collected', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB140', 'PAT040', 'DOC020', 'Renal Function Urea Creatinine', DATE '2025-03-07', NULL, 'Cancelled', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB141', 'PAT041', 'DOC001', 'Complete Blood Count (CBC)', DATE '2025-03-10', DATE '2025-03-11', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB142', 'PAT042', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2025-03-13', DATE '2025-03-15', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB143', 'PAT043', 'DOC003', 'Lipid Profile Panel', DATE '2025-03-16', DATE '2025-03-19', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB144', 'PAT044', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2025-03-19', NULL, 'Pending', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB145', 'PAT045', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2025-03-22', NULL, 'In-Progress', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB146', 'PAT046', 'DOC006', 'Cardiac Troponin I Assay', DATE '2025-03-25', NULL, 'Sample Collected', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB147', 'PAT047', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2025-03-28', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB148', 'PAT048', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2025-03-31', DATE '2025-04-04', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB149', 'PAT049', 'DOC009', 'Liver Function Test Panel', DATE '2025-04-03', DATE '2025-04-04', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB150', 'PAT050', 'DOC010', 'Renal Function Urea Creatinine', DATE '2025-04-06', DATE '2025-04-08', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB151', 'PAT051', 'DOC011', 'Complete Blood Count (CBC)', DATE '2025-04-09', NULL, 'Pending', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB152', 'PAT052', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2025-04-12', NULL, 'In-Progress', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB153', 'PAT053', 'DOC013', 'Lipid Profile Panel', DATE '2025-04-15', NULL, 'Sample Collected', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB154', 'PAT054', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2025-04-18', NULL, 'Cancelled', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB155', 'PAT055', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2025-04-21', DATE '2025-04-24', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB156', 'PAT056', 'DOC016', 'Cardiac Troponin I Assay', DATE '2025-04-24', DATE '2025-04-28', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB157', 'PAT057', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2025-04-27', DATE '2025-04-28', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB158', 'PAT058', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2025-04-30', NULL, 'Pending', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB159', 'PAT059', 'DOC019', 'Liver Function Test Panel', DATE '2025-05-03', NULL, 'In-Progress', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB160', 'PAT060', 'DOC020', 'Renal Function Urea Creatinine', DATE '2025-05-06', NULL, 'Sample Collected', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB161', 'PAT061', 'DOC001', 'Complete Blood Count (CBC)', DATE '2025-05-09', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB162', 'PAT062', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2025-05-12', DATE '2025-05-14', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB163', 'PAT063', 'DOC003', 'Lipid Profile Panel', DATE '2025-05-15', DATE '2025-05-18', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB164', 'PAT064', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2025-05-18', DATE '2025-05-22', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB165', 'PAT065', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2025-05-21', NULL, 'Pending', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB166', 'PAT066', 'DOC006', 'Cardiac Troponin I Assay', DATE '2025-05-24', NULL, 'In-Progress', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB167', 'PAT067', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2025-05-27', NULL, 'Sample Collected', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB168', 'PAT068', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2025-05-30', NULL, 'Cancelled', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB169', 'PAT069', 'DOC009', 'Liver Function Test Panel', DATE '2025-06-02', DATE '2025-06-03', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB170', 'PAT070', 'DOC010', 'Renal Function Urea Creatinine', DATE '2025-06-05', DATE '2025-06-07', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB171', 'PAT071', 'DOC011', 'Complete Blood Count (CBC)', DATE '2025-06-08', DATE '2025-06-11', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB172', 'PAT072', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2025-06-11', NULL, 'Pending', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB173', 'PAT073', 'DOC013', 'Lipid Profile Panel', DATE '2025-06-14', NULL, 'In-Progress', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB174', 'PAT074', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2025-06-17', NULL, 'Sample Collected', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB175', 'PAT075', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2025-06-20', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB176', 'PAT076', 'DOC016', 'Cardiac Troponin I Assay', DATE '2025-06-23', DATE '2025-06-27', 'Completed', 'Troponin I < 0.01 ng/mL - negative for acute myocardial injury.', 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB177', 'PAT077', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2025-06-26', DATE '2025-06-27', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB178', 'PAT078', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2025-06-29', DATE '2025-07-01', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB179', 'PAT079', 'DOC019', 'Liver Function Test Panel', DATE '2025-07-02', NULL, 'Pending', NULL, 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB180', 'PAT080', 'DOC020', 'Renal Function Urea Creatinine', DATE '2025-07-05', NULL, 'In-Progress', NULL, 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB181', 'PAT081', 'DOC001', 'Complete Blood Count (CBC)', DATE '2025-07-08', NULL, 'Sample Collected', NULL, 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB182', 'PAT082', 'DOC002', 'Comprehensive Metabolic Panel', DATE '2025-07-11', NULL, 'Cancelled', NULL, 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB183', 'PAT083', 'DOC003', 'Lipid Profile Panel', DATE '2025-07-14', DATE '2025-07-17', 'Completed', 'Total cholesterol 195 mg/dL, LDL 118 mg/dL, HDL 52 mg/dL.', 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB184', 'PAT084', 'DOC004', 'Hemoglobin A1c (HbA1c)', DATE '2025-07-17', DATE '2025-07-21', 'Completed', 'HbA1c measured at 6.4% indicating borderline glycemic control.', 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB185', 'PAT085', 'DOC005', 'Thyroid Stimulating Hormone', DATE '2025-07-20', DATE '2025-07-21', 'Completed', 'TSH 2.1 mIU/L - normal euthyroid status.', 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB186', 'PAT086', 'DOC006', 'Cardiac Troponin I Assay', DATE '2025-07-23', NULL, 'Pending', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB187', 'PAT087', 'DOC007', 'Urinalysis Complete Microscopy', DATE '2025-07-26', NULL, 'In-Progress', NULL, 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB188', 'PAT088', 'DOC008', 'C-Reactive Protein Quantitative', DATE '2025-07-29', NULL, 'Sample Collected', NULL, 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB189', 'PAT089', 'DOC009', 'Liver Function Test Panel', DATE '2025-08-01', NULL, 'Cancelled', 'Order cancelled by requesting physician prior to assay.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB190', 'PAT090', 'DOC010', 'Renal Function Urea Creatinine', DATE '2025-08-04', DATE '2025-08-06', 'Completed', 'Serum creatinine 0.95 mg/dL, eGFR > 90 mL/min - normal.', 230.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB191', 'PAT091', 'DOC011', 'Complete Blood Count (CBC)', DATE '2025-08-07', DATE '2025-08-10', 'Completed', 'WBC 6.8, RBC 4.9, Hgb 14.2 g/dL - within normal limits.', 180.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB192', 'PAT092', 'DOC012', 'Comprehensive Metabolic Panel', DATE '2025-08-10', DATE '2025-08-14', 'Completed', 'Electrolytes and hepatic enzymes within reference range.', 320.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB193', 'PAT093', 'DOC013', 'Lipid Profile Panel', DATE '2025-08-13', NULL, 'Pending', NULL, 260.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB194', 'PAT094', 'DOC014', 'Hemoglobin A1c (HbA1c)', DATE '2025-08-16', NULL, 'In-Progress', NULL, 240.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB195', 'PAT095', 'DOC015', 'Thyroid Stimulating Hormone', DATE '2025-08-19', NULL, 'Sample Collected', NULL, 290.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB196', 'PAT096', 'DOC016', 'Cardiac Troponin I Assay', DATE '2025-08-22', NULL, 'Cancelled', NULL, 450.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB197', 'PAT097', 'DOC017', 'Urinalysis Complete Microscopy', DATE '2025-08-25', DATE '2025-08-26', 'Completed', 'Clear yellow urine, negative for nitrites and leukocyte esterase.', 120.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB198', 'PAT098', 'DOC018', 'C-Reactive Protein Quantitative', DATE '2025-08-28', DATE '2025-08-30', 'Completed', 'CRP 4.2 mg/L - mild nonspecific inflammatory elevation.', 210.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB199', 'PAT099', 'DOC019', 'Liver Function Test Panel', DATE '2025-08-31', DATE '2025-09-03', 'Completed', 'ALT 24 U/L, AST 22 U/L, Total Bilirubin 0.8 mg/dL - normal.', 310.00);
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost) VALUES ('LAB200', 'PAT100', 'DOC020', 'Renal Function Urea Creatinine', DATE '2025-09-03', NULL, 'Pending', NULL, 230.00);

COMMIT;
