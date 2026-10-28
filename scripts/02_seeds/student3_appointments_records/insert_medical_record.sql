-- ============================================================================
-- SEED DATA: MedicalRecord (Student 3)
-- Target: Minimum 250 records
-- ID Range: 1 to 250
-- Foreign Keys: PatientID (1..100), DoctorID (1..20)
-- ============================================================================

INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)
VALUES (1, 1, 1, 'Essential Hypertension Stage 1', 'Prescribed ACE Inhibitor, lifestyle and diet modifications', 'Blood pressure recorded at 145/92 mmHg', DATE '2026-02-10', DATE '2026-05-10');

-- Add remaining medical records (2 to 250) following this exact pattern.
COMMIT;
