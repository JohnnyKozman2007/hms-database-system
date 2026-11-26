-- [POSITIVE - Valid UPDATE] Update City & Street
BEGIN
    SAVEPOINT sp_test;
    UPDATE Patient SET City = 'Giza', Street = 'Pyramids Avenue' WHERE PatientID = 'PAT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
