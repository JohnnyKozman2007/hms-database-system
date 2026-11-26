-- [NEGATIVE] Duplicate Phone (uq_dept_phone)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT_T5', 'Dup Phone Dept', 'Building A', '1st Floor', '0227951001', 'Landline');
-- Expected: ORA-00001: unique constraint (UQ_DEPT_PHONE) violated.
