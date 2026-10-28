-- ============================================================================
-- SEED DATA: LaboratoryTest (Student 4)
-- Target: Minimum 200 tests
-- ID Range: 1 to 200
-- Foreign Keys: PatientID (1..100), DoctorID (1..20)
-- ============================================================================

INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost)
VALUES (1, 1, 1, 'Lipid Panel', DATE '2026-02-08', DATE '2026-02-09', 'Completed', 'Total cholesterol: 195 mg/dL, HDL: 48, LDL: 120', 45.00);

-- Add remaining tests (2 to 200) following this exact pattern.
COMMIT;
