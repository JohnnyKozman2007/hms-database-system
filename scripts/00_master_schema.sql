-- HMS Master Schema Script (Oracle SQL / Oracle APEX)
-- Creates all 16 tables in student-grouped FK order: Student 1 -> 2 -> 3 -> 5 -> 4.

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
