-- [NEGATIVE] Invalid Frequency on UPDATE (chk_rx_frequency)
UPDATE Prescription SET Frequency = 'Hourly' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_FREQUENCY) violated.
