-- [NEGATIVE] QuantityPrescribed = 0 on UPDATE (chk_rx_qty)
UPDATE Prescription SET QuantityPrescribed = 0 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_QTY) violated.
