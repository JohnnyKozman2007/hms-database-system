-- [NEGATIVE] Digits in LastName (chk_nurse_lname)
UPDATE Nurse SET LastName = 'Samir2' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_LNAME) violated.
