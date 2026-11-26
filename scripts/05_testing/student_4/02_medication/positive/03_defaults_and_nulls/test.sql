-- [POSITIVE - Defaults] Omit QuantityInStock (DEFAULT 0) & ImportDate (DEFAULT SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, ExpirationDate, SupplierID)
    VALUES ('MED_DEF_01', 'Cefuroxime 500mg', 'Pharco Pharma', 'Antibiotic', 'Tablet', 48.00, TRUNC(SYSDATE) + 365, 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with QuantityInStock = 0 and ImportDate = SYSDATE.
