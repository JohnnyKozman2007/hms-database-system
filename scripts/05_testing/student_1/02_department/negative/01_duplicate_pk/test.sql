-- [NEGATIVE] Duplicate DepartmentID (pk_department)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT01', 'Duplicate Dept', 'Building A', '1st Floor', '0227959002', 'Landline');
-- Expected: ORA-00001: unique constraint (PK_DEPARTMENT) violated.
