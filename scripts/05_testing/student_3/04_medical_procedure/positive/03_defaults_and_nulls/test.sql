-- [POSITIVE - Defaults] Omit ProcedureDate (SYSDATE) & Outcome ('Pending')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, Duration, OperatingRoom, ProcedureCost)
    VALUES ('PROC_DEF_1', 'PAT003', 'DOC003', 'Diagnostic Endoscopy', 30, 'Endoscopy Suite', 2500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with ProcedureDate = SYSDATE and Outcome = 'Pending'.
