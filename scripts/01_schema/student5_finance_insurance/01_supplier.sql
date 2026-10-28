-- Entity: Supplier (Student 5)
-- Minimum Data Target: 15 suppliers
CREATE TABLE Supplier (
    SupplierID              NUMBER(5)           CONSTRAINT pk_supplier PRIMARY KEY,
    CompanyName             VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_name UNIQUE,
    ContactPerson           VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_supp_email UNIQUE,
    Address                 VARCHAR2(150)       NOT NULL,
    ContractStatus          VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_supp_status CHECK (ContractStatus IN ('Active', 'Inactive', 'Terminated', 'Under Review'))
);
