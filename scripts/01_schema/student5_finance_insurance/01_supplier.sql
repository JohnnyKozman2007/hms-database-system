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
