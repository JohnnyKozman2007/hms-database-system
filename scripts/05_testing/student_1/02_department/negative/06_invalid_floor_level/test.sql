-- [NEGATIVE] Invalid FloorLevel on UPDATE (chk_dept_floor)
UPDATE Department SET FloorLevel = 'Basement' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_FLOOR) violated.
