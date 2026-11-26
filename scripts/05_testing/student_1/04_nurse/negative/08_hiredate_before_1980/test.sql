-- [NEGATIVE] HireDate before 1980-01-01 (chk_nurse_hire_date)
UPDATE Nurse SET HireDate = DATE '1979-12-31' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_HIRE_DATE) violated.
