-- [NEGATIVE] Non-existent MedicationID (fk_rx_medication)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX_T3', 'PAT001', 'DOC001', 'MED999', '500mg', 'Once daily', 5);
-- Expected: ORA-02291: integrity constraint (FK_RX_MEDICATION) violated.
