-- [NEGATIVE] Negative YearsOfExperience (chk_nurse_exp)
UPDATE Nurse SET YearsOfExperience = -1 WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_EXP) violated.
