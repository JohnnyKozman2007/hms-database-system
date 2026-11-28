-- HMS Master Schema & Features Script (Oracle SQL / Oracle APEX)
-- Creates all 16 tables in student-grouped FK order (Student 1 -> 2 -> 3 -> 5 -> 4)
-- followed by all 26 Global date triggers & Student 1-5 advanced PL/SQL objects.

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
-- Stored Procedure: sp_cancel_appointment
-- Module: Data Modeling for DB (4FTC2063)
-- Subsystem: Appointments and Medical Records
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_cancel_appointment (
    p_appointment_id IN VARCHAR2,
    p_reason         IN VARCHAR2
) IS
BEGIN
    UPDATE Appointment
    SET Status = 'Cancelled',
        Notes  = p_reason
    WHERE AppointmentID = p_appointment_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Appointment not found: ' || p_appointment_id);
    END IF;
END sp_cancel_appointment;
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
