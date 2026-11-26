-- [NEGATIVE] MedicationName < 5 chars on UPDATE (chk_med_name_len)
UPDATE Medication SET MedicationName = 'Med' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_NAME_LEN) violated.
