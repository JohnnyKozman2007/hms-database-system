-- [NEGATIVE] PrescriptionDate < 2020-01-01 on UPDATE (chk_rx_date)
UPDATE Prescription SET PrescriptionDate = DATE '2019-05-01' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DATE) violated.
