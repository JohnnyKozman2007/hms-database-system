-- [POSITIVE - Valid UPDATE]
BEGIN
    SAVEPOINT sp_test;
    UPDATE Supplier SET ContractStatus = 'Inactive' WHERE SupplierID = 'SUP001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
