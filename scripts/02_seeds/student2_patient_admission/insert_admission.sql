-- ============================================================================
-- SEED DATA: Admission (Student 2)
-- Target: Minimum 150 admissions
-- ID Range: 1 to 150
-- Foreign Keys: PatientID (1..100), RoomID (1..50)
-- ============================================================================

INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES (1, 1, 1, DATE '2026-01-10', DATE '2026-01-15', 'Severe respiratory infection requiring IV therapy', 'Discharged');

INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES (2, 2, 2, DATE '2026-02-01', NULL, 'Post-cardiac catheterization monitoring', 'Admitted');

-- Add remaining admissions (3 to 150) following this exact pattern.
COMMIT;
