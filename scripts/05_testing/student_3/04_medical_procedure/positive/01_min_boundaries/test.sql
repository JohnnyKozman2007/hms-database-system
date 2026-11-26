-- [POSITIVE - Min Boundaries] ProcedureDate = 2020-01-01, Duration = 1, ProcedureCost = 0.01, 5-char name
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome)
    VALUES ('P1', 'PAT001', 'DOC001', 'Biops', DATE '2020-01-01', 1, 'OR-1', 0.01, 'Pending');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
