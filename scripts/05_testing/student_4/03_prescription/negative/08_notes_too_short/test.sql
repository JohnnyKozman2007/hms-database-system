-- [NEGATIVE] Notes < 5 chars on UPDATE (chk_rx_notes_len)
UPDATE Prescription SET Notes = 'Hi' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_NOTES_LEN) violated.
