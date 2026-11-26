-- [NEGATIVE] Non-existent DepartmentID (fk_nurse_dept)
UPDATE Nurse SET DepartmentID = 'DEPT999' WHERE NurseID = 'NRS001';
-- Expected: ORA-02291: integrity constraint (FK_NURSE_DEPT) violated.
