-- [POSITIVE] Boundary: Doctor.HireDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    UPDATE Doctor SET HireDate = TRUNC(SYSDATE) WHERE DoctorID = 'DOC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
