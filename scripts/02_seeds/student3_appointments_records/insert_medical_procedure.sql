-- ============================================================================
-- SEED DATA: MedicalProcedure (Student 3)
-- Target: Minimum 100 procedures
-- ID Range: 1 to 100
-- Foreign Keys: PatientID (1..100), DoctorID (1..20)
-- ============================================================================

INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, OperatingRoom, Duration, ProcedureCost, Outcome)
VALUES (1, 1, 1, 'Coronary Angiography', DATE '2026-01-12', 'OR-3', 45, 1250.00, 'Successful');

-- Add remaining procedures (2 to 100) following this exact pattern.
COMMIT;
