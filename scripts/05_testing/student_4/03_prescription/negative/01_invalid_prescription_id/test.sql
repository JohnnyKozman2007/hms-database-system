-- [NEGATIVE] Invalid PrescriptionID (chk_rx_id)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX#1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Once daily', 5);
-- Expected: ORA-02290: check constraint (CHK_RX_ID) violated.
