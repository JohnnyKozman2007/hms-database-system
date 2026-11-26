-- [NEGATIVE] Duplicate InsuranceID (pk_insurance)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS001', 'PAT050', 'AXA Egypt', 'POL-DUP-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-00001: unique constraint (PK_INSURANCE) violated.
