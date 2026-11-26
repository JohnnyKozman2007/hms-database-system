-- [NEGATIVE] Invalid PhoneType on UPDATE (chk_dept_phone_type / chk_dept_phone)
UPDATE Department SET PhoneType = 'Fax' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_PHONE_TYPE / CHK_DEPT_PHONE) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.
