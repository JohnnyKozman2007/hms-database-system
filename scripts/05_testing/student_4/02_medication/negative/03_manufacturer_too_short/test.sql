-- [NEGATIVE] Manufacturer < 5 chars on UPDATE (chk_med_mfg_len)
UPDATE Medication SET Manufacturer = 'ABC' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_MFG_LEN) violated.
