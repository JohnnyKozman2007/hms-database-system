-- [NEGATIVE] Invalid DispenseStatus on UPDATE (chk_rx_dispense)
UPDATE Prescription SET DispenseStatus = 'Shipped' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DISPENSE) violated.
