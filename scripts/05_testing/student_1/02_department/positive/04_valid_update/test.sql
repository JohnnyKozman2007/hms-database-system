-- [POSITIVE - Valid UPDATE] Update Building & FloorLevel
BEGIN
    SAVEPOINT sp_test;
    UPDATE Department SET Building = 'Building C', FloorLevel = '3rd Floor' WHERE DepartmentID = 'DEPT01';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
