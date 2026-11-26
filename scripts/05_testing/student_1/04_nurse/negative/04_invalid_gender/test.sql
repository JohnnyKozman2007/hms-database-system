-- [NEGATIVE] Invalid Gender (chk_nurse_gender)
UPDATE Nurse SET Gender = 'N/A' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_GENDER) violated.
