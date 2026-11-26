-- [POSITIVE - Max Boundaries] CoveragePercentage = 100, StartDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_MAX_01', 'PAT002', 'Delta Insurance', 'DEL-MAX-2026-01', 100.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Active');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
