-- ============================================================================
-- SEED DATA: Prescription (Student 4)
-- Target: Minimum 300 prescriptions
-- ID Range: 1 to 300
-- Foreign Keys: PatientID (1..100), DoctorID (1..20), MedicationID (1..50)
-- ============================================================================

INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, PrescriptionDate, Notes)
VALUES (1, 1, 1, 2, '10mg', 'Once daily with water', '30 days', DATE '2026-02-10', 'Monitor blood pressure weekly');

-- Add remaining prescriptions (2 to 300) following this exact pattern.
COMMIT;
