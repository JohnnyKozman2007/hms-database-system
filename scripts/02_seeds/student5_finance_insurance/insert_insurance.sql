-- ============================================================================
-- SEED DATA: Insurance (Student 5)
-- Target: Minimum 100 insurance records
-- ID Range: 1 to 100
-- Foreign Keys: PatientID (1..100)
-- ============================================================================

INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES (1, 1, 'Bupa UK', 'POL-BUP-884910', 80.00, DATE '2025-01-01', DATE '2027-01-01', 'Active');

-- Add remaining insurance records (2 to 100) following this exact pattern.
COMMIT;
