-- [NEGATIVE] trg_rx_manage_medication_stock: Insufficient stock (ORA-20030)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
VALUES ('RX_TRG2', 'PAT002', 'DOC001', 'MED002', '500mg', 'Once daily', 30, 999, 'Dispensed', TRUNC(SYSDATE));
-- Expected: ORA-20030: Insufficient stock for Medication MED002.
