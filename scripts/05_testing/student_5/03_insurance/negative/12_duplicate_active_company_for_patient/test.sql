-- [NEGATIVE] Second Active policy for same Patient + InsuranceCompany (uq_ins_one_active_comp)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_ACT1', 'PAT060', 'AXA Egypt', 'AXA-ACT-001', 70.00, TRUNC(SYSDATE) - 5, TRUNC(SYSDATE) + 180, 'Active');

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_ACT2', 'PAT060', 'AXA Egypt', 'AXA-ACT-002', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Active');
    -- Expected: ORA-00001: unique constraint (UQ_INS_ONE_ACTIVE_COMP) violated.

    ROLLBACK TO sp_test;
END;
