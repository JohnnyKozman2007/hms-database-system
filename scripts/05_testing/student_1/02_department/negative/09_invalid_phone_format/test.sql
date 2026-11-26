-- [NEGATIVE] Invalid Phone format on UPDATE (chk_dept_phone)
UPDATE Department SET Phone = '12345' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_PHONE) violated.
