-- [NEGATIVE] Duplicate DepartmentName (uq_dept_name)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT_T2', 'Cardiology', 'Building A', '1st Floor', '0227959004', 'Landline');
-- Expected: ORA-00001: unique constraint (UQ_DEPT_NAME) violated.
