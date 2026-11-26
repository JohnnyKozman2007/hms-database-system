-- [POSITIVE - Min Boundaries] Shortest valid ID, name, 9-digit landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription)
    VALUES ('D1', 'MinDept', 'Building A', 'Ground Floor', '022795901', 'Landline', 'A');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
