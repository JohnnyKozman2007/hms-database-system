-- [NEGATIVE] Invalid Building on UPDATE (chk_dept_bldg)
UPDATE Department SET Building = 'Building X' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_BLDG) violated.
