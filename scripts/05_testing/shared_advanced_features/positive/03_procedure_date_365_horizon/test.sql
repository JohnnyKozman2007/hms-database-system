-- [POSITIVE] Boundary: MedicalProcedure.ProcedureDate within 365-day horizon
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalProcedure SET ProcedureDate = TRUNC(SYSDATE) + 300 + (11/24) WHERE ProcedureID = 'PROC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
