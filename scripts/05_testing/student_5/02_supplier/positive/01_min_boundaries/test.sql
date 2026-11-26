-- [POSITIVE - Min Boundaries] 2-char CompanyName, 3-char ContactPerson/Street, 2-char City, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus)
    VALUES ('S1', 'Co', 'Ali', '022418901', 'Landline', 's@co.eg', '1', 'St1', 'Al', '1', 'Active');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
