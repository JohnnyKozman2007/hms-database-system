-- [POSITIVE - Valid UPDATE] Discharge an admitted patient
BEGIN
    SAVEPOINT sp_test;
    UPDATE Admission SET AdmissionStatus = 'Discharged', DischargeDate = TRUNC(SYSDATE) WHERE AdmissionID = 'ADM001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
