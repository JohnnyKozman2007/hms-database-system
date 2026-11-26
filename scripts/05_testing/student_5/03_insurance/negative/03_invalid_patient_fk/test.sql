-- [NEGATIVE] Non-existent PatientID (fk_ins_patient)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS_FK1', 'PAT999', 'AXA Egypt', 'POL-FK-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-02291: integrity constraint (FK_INS_PATIENT) violated.
