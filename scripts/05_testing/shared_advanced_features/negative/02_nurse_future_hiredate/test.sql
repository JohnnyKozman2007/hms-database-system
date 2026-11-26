-- [NEGATIVE] Future Nurse.HireDate (trg_nurse_date_max)
UPDATE Nurse SET HireDate = SYSDATE + 2 WHERE NurseID = 'NRS001';
-- Expected: ORA-20001: Nurse.HireDate cannot be in the future (exceeds SYSDATE).
