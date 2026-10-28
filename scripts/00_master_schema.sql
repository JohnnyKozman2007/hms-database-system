-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - MASTER DDL SCHEMA SCRIPT
-- Module: Data Modeling for DB (4FTC2063) - 2026/27 Academic Year
-- Target Database: Oracle Database / Oracle APEX
-- Tables: 16 Entities created in strict foreign key dependency order
-- ============================================================================

-- ============================================================================
-- LEVEL 1: Independent Tables (No Foreign Keys)
-- ============================================================================

-- 1. Department (Owner: Student 1)
CREATE TABLE Department (
    DepartmentID            NUMBER(5)           CONSTRAINT pk_department PRIMARY KEY,
    DepartmentName          VARCHAR2(50)        NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    Location                VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    DepartmentDescription   VARCHAR2(255)
);

-- 2. Patient (Owner: Student 2)
CREATE TABLE Patient (
    PatientID               NUMBER(8)           CONSTRAINT pk_patient PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    DateOfBirth             DATE                NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_pat_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    BloodType               VARCHAR2(5)         CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(150)       NOT NULL,
    EmergencyContact        VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       CONSTRAINT uq_pat_email UNIQUE
);

-- 3. Room (Owner: Student 2)
CREATE TABLE Room (
    RoomID                  NUMBER(5)           CONSTRAINT pk_room PRIMARY KEY,
    RoomNumber              VARCHAR2(10)        NOT NULL CONSTRAINT uq_room_num UNIQUE,
    Floor                   NUMBER(2)           NOT NULL CONSTRAINT chk_room_floor CHECK (Floor >= 0),
    RoomType                VARCHAR2(30)        NOT NULL CONSTRAINT chk_room_type CHECK (RoomType IN ('General Ward', 'Semi-Private', 'Private', 'ICU', 'Operation Theater')),
    Capacity                NUMBER(3)           NOT NULL CONSTRAINT chk_room_cap CHECK (Capacity > 0),
    DailyCharge             NUMBER(10,2)        NOT NULL CONSTRAINT chk_room_charge CHECK (DailyCharge >= 0),
    AvailabilityStatus      VARCHAR2(20)        DEFAULT 'Available' NOT NULL CONSTRAINT chk_room_avail CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance'))
);

-- 4. Supplier (Owner: Student 5)
CREATE TABLE Supplier (
    SupplierID              NUMBER(5)           CONSTRAINT pk_supplier PRIMARY KEY,
    CompanyName             VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_name UNIQUE,
    ContactPerson           VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_email UNIQUE,
    Address                 VARCHAR2(150)       NOT NULL,
    ContractStatus          VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_supp_status CHECK (ContractStatus IN ('Active', 'Inactive', 'Terminated', 'Under Review'))
);

-- ============================================================================
-- LEVEL 2: Entities depending on Level 1
-- ============================================================================

-- 5. Doctor (Owner: Student 1) - Depends on Department
CREATE TABLE Doctor (
    DoctorID                NUMBER(5)           CONSTRAINT pk_doctor PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_doc_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_doc_email UNIQUE,
    Specialty               VARCHAR2(100)       NOT NULL,
    HireDate                DATE                NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_doc_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(5)           NOT NULL,
    CONSTRAINT fk_doc_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- 6. Nurse (Owner: Student 1) - Depends on Department
CREATE TABLE Nurse (
    NurseID                 NUMBER(5)           CONSTRAINT pk_nurse PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_nurse_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_nurse_email UNIQUE,
    Shift                   VARCHAR2(20)        NOT NULL CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Day', 'Night', 'Rotational')),
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_nurse_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(5)           NOT NULL,
    CONSTRAINT fk_nurse_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- 7. Medication (Owner: Student 4) - Depends on Supplier
CREATE TABLE Medication (
    MedicationID            NUMBER(5)           CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL,
    DosageForm              VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Inhaler', 'Drops')),
    UnitPrice               NUMBER(10,2)        NOT NULL CONSTRAINT chk_med_price CHECK (UnitPrice > 0),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0),
    ExpirationDate          DATE                NOT NULL,
    SupplierID              NUMBER(5)           NOT NULL,
    CONSTRAINT fk_med_supp FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- 8. Insurance (Owner: Student 5) - Depends on Patient
CREATE TABLE Insurance (
    InsuranceID             NUMBER(8)           CONSTRAINT pk_insurance PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    InsuranceCompany        VARCHAR2(100)       NOT NULL,
    PolicyNumber            VARCHAR2(50)        NOT NULL CONSTRAINT uq_ins_policy UNIQUE,
    CoveragePercentage      NUMBER(5,2)         NOT NULL CONSTRAINT chk_ins_cov CHECK (CoveragePercentage BETWEEN 0 AND 100),
    StartDate               DATE                NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    InsuranceStatus         VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_ins_status CHECK (InsuranceStatus IN ('Active', 'Expired', 'Cancelled', 'Suspended')),
    CONSTRAINT fk_ins_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_ins_dates CHECK (ExpirationDate >= StartDate)
);

-- 9. Invoice (Owner: Student 5) - Depends on Patient
CREATE TABLE Invoice (
    InvoiceID               NUMBER(8)           CONSTRAINT pk_invoice PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    InvoiceDate             DATE                DEFAULT SYSDATE NOT NULL,
    TotalAmount             NUMBER(10,2)        NOT NULL CONSTRAINT chk_inv_total CHECK (TotalAmount >= 0),
    TaxAmount               NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_inv_tax CHECK (TaxAmount >= 0),
    Discount                NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_inv_disc CHECK (Discount >= 0),
    DueDate                 DATE                NOT NULL,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Unpaid' NOT NULL CONSTRAINT chk_inv_status CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Partially Paid', 'Overdue')),
    CONSTRAINT fk_inv_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_inv_dates CHECK (DueDate >= InvoiceDate)
);

-- ============================================================================
-- LEVEL 3: Entities depending on Level 1 & 2
-- ============================================================================

-- 10. Admission (Owner: Student 2) - Depends on Patient & Room
CREATE TABLE Admission (
    AdmissionID             NUMBER(8)           CONSTRAINT pk_admission PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    RoomID                  NUMBER(5)           NOT NULL,
    AdmissionDate           DATE                NOT NULL,
    DischargeDate           DATE,
    AdmissionReason         VARCHAR2(200)       NOT NULL,
    AdmissionStatus         VARCHAR2(20)        DEFAULT 'Admitted' NOT NULL CONSTRAINT chk_adm_status CHECK (AdmissionStatus IN ('Admitted', 'Discharged', 'Transferred')),
    CONSTRAINT fk_adm_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_adm_room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT chk_adm_dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)
);

-- 11. Appointment (Owner: Student 3) - Depends on Patient & Doctor
CREATE TABLE Appointment (
    AppointmentID           NUMBER(8)           CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    AppointmentDate         DATE                NOT NULL,
    AppointmentTime         VARCHAR2(10)        NOT NULL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    Reason                  VARCHAR2(200)       NOT NULL,
    Notes                   VARCHAR2(255),
    CONSTRAINT fk_apt_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_apt_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- 12. MedicalRecord (Owner: Student 3) - Depends on Patient & Doctor
CREATE TABLE MedicalRecord (
    RecordID                NUMBER(8)           CONSTRAINT pk_record PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    Diagnosis               VARCHAR2(200)       NOT NULL,
    Treatment               VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(255),
    RecordDate              DATE                DEFAULT SYSDATE NOT NULL,
    FollowUpDate            DATE,
    CONSTRAINT fk_rec_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_rec_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_rec_dates CHECK (FollowUpDate IS NULL OR FollowUpDate >= RecordDate)
);

-- 13. MedicalProcedure (Owner: Student 3) - Depends on Patient & Doctor
CREATE TABLE MedicalProcedure (
    ProcedureID             NUMBER(8)           CONSTRAINT pk_procedure PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    ProcedureName           VARCHAR2(100)       NOT NULL,
    ProcedureDate           DATE                NOT NULL,
    OperatingRoom           VARCHAR2(20)        NOT NULL,
    Duration                NUMBER(4)           NOT NULL CONSTRAINT chk_proc_dur CHECK (Duration > 0),
    ProcedureCost           NUMBER(10,2)        NOT NULL CONSTRAINT chk_proc_cost CHECK (ProcedureCost >= 0),
    Outcome                 VARCHAR2(100)       DEFAULT 'Successful' NOT NULL CONSTRAINT chk_proc_outcome CHECK (Outcome IN ('Successful', 'Complications', 'Under Observation', 'Incomplete')),
    CONSTRAINT fk_proc_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_proc_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- 14. LaboratoryTest (Owner: Student 4) - Depends on Patient & Doctor
CREATE TABLE LaboratoryTest (
    TestID                  NUMBER(8)           CONSTRAINT pk_labtest PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    TestType                VARCHAR2(100)       NOT NULL,
    RequestedDate           DATE                NOT NULL,
    CompletedDate           DATE,
    TestStatus              VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_test_status CHECK (TestStatus IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    TestResult              VARCHAR2(255),
    TestCost                NUMBER(10,2)        NOT NULL CONSTRAINT chk_test_cost CHECK (TestCost >= 0),
    CONSTRAINT fk_test_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_test_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_test_dates CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate)
);

-- 15. Payment (Owner: Student 5) - Depends on Invoice
CREATE TABLE Payment (
    PaymentID               NUMBER(8)           CONSTRAINT pk_payment PRIMARY KEY,
    InvoiceID               NUMBER(8)           NOT NULL,
    PaymentDate             DATE                DEFAULT SYSDATE NOT NULL,
    AmountPaid              NUMBER(10,2)        NOT NULL CONSTRAINT chk_pay_amt CHECK (AmountPaid > 0),
    PaymentMethod           VARCHAR2(30)        NOT NULL CONSTRAINT chk_pay_method CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Insurance Claim')),
    TransactionReference    VARCHAR2(100)       NOT NULL CONSTRAINT uq_pay_ref UNIQUE,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Completed' NOT NULL CONSTRAINT chk_pay_status CHECK (PaymentStatus IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_pay_inv FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
);

-- ============================================================================
-- LEVEL 4: Intersection Entity depending on Patient, Doctor, Medication
-- ============================================================================

-- 16. Prescription (Owner: Student 4) - Depends on Patient, Doctor, Medication
CREATE TABLE Prescription (
    PrescriptionID          NUMBER(8)           CONSTRAINT pk_prescription PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    MedicationID            NUMBER(5)           NOT NULL,
    Dosage                  VARCHAR2(50)        NOT NULL,
    Frequency               VARCHAR2(50)        NOT NULL,
    Duration                VARCHAR2(50)        NOT NULL,
    PrescriptionDate        DATE                DEFAULT SYSDATE NOT NULL,
    Notes                   VARCHAR2(255),
    CONSTRAINT fk_presc_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_presc_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_presc_med FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID)
);

COMMIT;
