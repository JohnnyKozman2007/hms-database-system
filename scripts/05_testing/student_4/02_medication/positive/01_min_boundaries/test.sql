-- [POSITIVE - Min Boundaries] UnitPrice = 0.01, QuantityInStock = 0, ImportDate = 2020-01-01, 5-char strings
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('M1', 'MedA1', 'MfgA1', 'Other', 'Drops', 0.01, 0, DATE '2020-01-01', DATE '2020-01-02', 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
