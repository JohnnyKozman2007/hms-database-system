-- [POSITIVE - Defaults] Omit InsuranceStatus (DEFAULT 'Active')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
    VALUES ('INS_DEF_01', 'PAT003', 'GIG Egypt', 'GIG-DEF-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with InsuranceStatus = 'Active'.
