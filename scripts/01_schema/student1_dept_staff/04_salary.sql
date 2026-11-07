-- ============================================================================
-- Entity: Salary (Student 1 - Department and Staff Management) [EXTRA WORK]
-- Description: Manages compensation, allowances, deductions, and net pay for
--              all hospital medical staff (Doctors and Nurses).
-- Level 3 Table: Dependent on Doctor and Nurse (Mutually Exclusive Arc FK)
-- ============================================================================

CREATE TABLE Salary (
    SalaryID                NUMBER(8)           CONSTRAINT pk_salary PRIMARY KEY,
    StaffType               VARCHAR2(10)        NOT NULL CONSTRAINT chk_sal_type CHECK (StaffType IN ('Doctor', 'Nurse')),
    DoctorID                NUMBER(8),
    NurseID                 NUMBER(8),
    BaseSalary              NUMBER(10,2)        NOT NULL CONSTRAINT chk_sal_base CHECK (BaseSalary > 0),
    Allowance               NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_sal_allow CHECK (Allowance >= 0),
    Deductions              NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_sal_deduct CHECK (Deductions >= 0),
    NetSalary               NUMBER(10,2)        GENERATED ALWAYS AS (BaseSalary + Allowance - Deductions) VIRTUAL,
    PaymentFrequency        VARCHAR2(20)        DEFAULT 'Monthly' NOT NULL CONSTRAINT chk_sal_freq CHECK (PaymentFrequency IN ('Monthly', 'Bi-Weekly', 'Annual')),
    EffectiveDate           DATE                DEFAULT SYSDATE NOT NULL,
    SalaryStatus            VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_sal_status CHECK (SalaryStatus IN ('Active', 'Superseded', 'Suspended')),
    CONSTRAINT fk_sal_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_sal_nurse FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
    CONSTRAINT chk_sal_staff CHECK (
        (StaffType = 'Doctor' AND DoctorID IS NOT NULL AND NurseID IS NULL) OR
        (StaffType = 'Nurse'  AND NurseID IS NOT NULL AND DoctorID IS NULL)
    ),
    CONSTRAINT chk_sal_net_nonneg CHECK (BaseSalary + Allowance >= Deductions)
);
