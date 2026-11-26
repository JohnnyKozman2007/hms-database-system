-- [NEGATIVE] Invalid Category on UPDATE (chk_med_category)
UPDATE Medication SET Category = 'Vitamin' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_CATEGORY) violated.
