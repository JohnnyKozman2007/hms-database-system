-- [NEGATIVE] Invalid DosageForm on UPDATE (chk_med_dosage_form)
UPDATE Medication SET DosageForm = 'Powder' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_DOSAGE_FORM) violated.
