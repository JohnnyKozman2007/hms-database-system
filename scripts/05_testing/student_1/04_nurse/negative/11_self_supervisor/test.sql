-- [NEGATIVE] Self-supervision (chk_nurse_no_self_sup)
UPDATE Nurse SET SupervisorID = 'NRS001' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_NO_SELF_SUP) violated.
