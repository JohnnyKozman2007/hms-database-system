-- [NEGATIVE] Future Prescription.PrescriptionDate (trg_rx_date_max)
UPDATE Prescription SET PrescriptionDate = SYSDATE + 1 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-20001: Prescription.PrescriptionDate cannot be in the future (exceeds SYSDATE).
