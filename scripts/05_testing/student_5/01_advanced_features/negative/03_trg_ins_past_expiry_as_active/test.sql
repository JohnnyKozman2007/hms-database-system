-- [NEGATIVE] trg_ins_status_date_guard: Active status with past ExpirationDate
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES ('INS_NEG1', 'PAT001', 'AXA Egypt', 'AXA-NEG-001', 80.00, DATE '2022-01-01', DATE '2023-01-01', 'Active');
-- Expected: ORA-20005: Cannot set InsuranceStatus to Active when ExpirationDate is in the past; must be Expired.
