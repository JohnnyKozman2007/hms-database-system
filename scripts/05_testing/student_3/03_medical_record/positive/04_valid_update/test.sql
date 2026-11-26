-- [POSITIVE - Valid UPDATE] Update Diagnosis & Treatment
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalRecord SET Diagnosis = 'Controlled Hypertension', Treatment = 'Continue low-dose ACE inhibitor' WHERE RecordID = 'MR001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
