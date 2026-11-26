-- [NEGATIVE] trg_ins_status_date_guard: Expired status with future ExpirationDate
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES ('INS_NEG2', 'PAT001', 'Bupa Egypt', 'BUPA-NEG-002', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Expired');
-- Expected: ORA-20006: Cannot set InsuranceStatus to Expired when ExpirationDate has not passed yet.
