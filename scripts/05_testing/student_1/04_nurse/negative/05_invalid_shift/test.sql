-- [NEGATIVE] Invalid Shift (chk_nurse_shift)
UPDATE Nurse SET Shift = 'Midnight' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_SHIFT) violated.
