-- [POSITIVE - Max Boundaries] ProcedureDate = TRUNC(SYSDATE) + 365, Duration = 1440, ProcedureCost = 1000000.00
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome)
    VALUES ('PROC_MAX_1', 'PAT002', 'DOC002', 'Complex Cardiothoracic Reconstruction', TRUNC(SYSDATE) + 365, 1440, 'Cath Lab', 1000000.00, 'Successful');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
