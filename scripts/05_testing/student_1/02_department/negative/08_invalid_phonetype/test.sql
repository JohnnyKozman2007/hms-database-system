-- [NEGATIVE] Invalid PhoneType on UPDATE (chk_dept_phone_type)
UPDATE Department SET PhoneType = 'Fax' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_PHONE_TYPE) violated.
