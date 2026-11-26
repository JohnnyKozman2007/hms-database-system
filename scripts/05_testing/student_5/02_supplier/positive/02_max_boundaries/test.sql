-- [POSITIVE - Max Boundaries] 11-digit Mobile, Under Review status
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus)
    VALUES ('SUP_MAX_01', 'International Medical Logistics Corp', 'O''Connor', '01061899999', 'Mobile', 'sup.max@medcorp.eg', '99B', 'Tenth of Ramadan Industrial Zone', 'Alexandria', '21500', 'Under Review');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
