-- Entity: Supplier (Student 5)
-- Minimum Data Target: 15 suppliers
-- Egyptian National Telecom Plan (Landline = 9-10 digits, Mobile = 11 digits)
CREATE TABLE Supplier (
    SupplierID              NUMBER(5)           CONSTRAINT pk_supplier PRIMARY KEY,
    CompanyName             VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_name UNIQUE,
    ContactPerson           VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL CONSTRAINT chk_supp_phone_type CHECK (PhoneType IN ('Landline', 'Mobile', 'Phone')),
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_email UNIQUE,
    BuildingNumber          VARCHAR2(20),
    Street                  VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (BuildingNumber || ' ' || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
    ContractStatus          VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_supp_status CHECK (ContractStatus IN ('Active', 'Inactive', 'Terminated', 'Under Review')),
    CONSTRAINT chk_supp_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType IN ('Mobile', 'Phone') AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);
