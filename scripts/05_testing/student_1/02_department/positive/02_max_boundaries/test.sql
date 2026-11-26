-- [POSITIVE - Max Boundaries] Building D, 5th Floor, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription)
    VALUES ('DEPT_MAX_1', 'Max Boundary Clinical Department Name', 'Building D', '5th Floor', '01099998888', 'Mobile', 'Maximum boundary department test description.');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
