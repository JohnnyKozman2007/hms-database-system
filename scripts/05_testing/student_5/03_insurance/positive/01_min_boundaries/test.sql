-- [POSITIVE - Min Boundaries] CoveragePercentage = 0, StartDate = 2020-01-01, 4-char PolicyNumber
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('I1', 'PAT001', 'AXA Egypt', 'P001', 0.00, DATE '2020-01-01', DATE '2020-01-02', 'Expired');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
