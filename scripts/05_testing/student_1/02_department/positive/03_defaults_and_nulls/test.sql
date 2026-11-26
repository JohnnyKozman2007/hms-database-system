-- [POSITIVE - Defaults & NULLs] Omit PhoneType (DEFAULT 'Landline') & DepartmentDescription = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, DepartmentDescription)
    VALUES ('DEPT_DEF1', 'Default PhoneType Dept', 'Building B', '2nd Floor', '0227959001', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with PhoneType = 'Landline'.
