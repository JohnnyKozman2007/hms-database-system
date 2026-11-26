-- [NEGATIVE] Duration = 0 on UPDATE (chk_rx_duration)
UPDATE Prescription SET Duration = 0 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DURATION) violated.
