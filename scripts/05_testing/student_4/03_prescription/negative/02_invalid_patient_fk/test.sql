-- [NEGATIVE] Non-existent PatientID (fk_rx_patient)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX_T2', 'PAT999', 'DOC001', 'MED002', '500mg', 'Once daily', 5);
-- Expected: ORA-02291: integrity constraint (FK_RX_PATIENT) violated.
