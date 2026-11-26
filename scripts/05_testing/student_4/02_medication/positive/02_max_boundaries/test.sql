-- [POSITIVE - Max Boundaries] UnitPrice = 50000.00, QuantityInStock = 100000, ImportDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('MED_MAX_01', 'Monoclonal Antibody Infusion', 'Roche Diagnostics', 'Cardiovascular', 'Injection', 50000.00, 100000, TRUNC(SYSDATE), TRUNC(SYSDATE) + 730, 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
