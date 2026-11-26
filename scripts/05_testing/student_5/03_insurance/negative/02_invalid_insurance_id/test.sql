-- [NEGATIVE] Invalid InsuranceID format (chk_ins_id)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS@1', 'PAT050', 'AXA Egypt', 'POL-BAD-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-02290: check constraint (CHK_INS_ID) violated.
