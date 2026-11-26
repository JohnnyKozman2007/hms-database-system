-- [NEGATIVE] NULL DepartmentName on UPDATE
UPDATE Department SET DepartmentName = NULL WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-01407: cannot update (DEPARTMENT.DEPARTMENTNAME) to NULL.
