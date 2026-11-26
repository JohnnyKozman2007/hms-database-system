-- [NEGATIVE] Duplicate PolicyNumber (uq_ins_policy)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS_POL1', 'PAT050', 'Bupa Egypt', (SELECT PolicyNumber FROM Insurance WHERE InsuranceID = 'INS001'), 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-00001: unique constraint (UQ_INS_POLICY) violated.
