-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Landline') & ContractStatus ('Active'); BuildingNumber = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, BuildingNumber, Street, City, PostalCode)
    VALUES ('SUP_DEF_01', 'Delta Pharma Supplies', 'Hossam Adel', '0224189002', 'delta@pharma.eg', NULL, 'Corniche El-Nil', 'Cairo', '11511');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with PhoneType = 'Landline' and ContractStatus = 'Active'.
