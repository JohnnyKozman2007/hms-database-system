-- [NEGATIVE] Invalid DepartmentID characters (chk_dept_id)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT@01', 'Invalid ID Dept', 'Building A', '1st Floor', '0227959003', 'Landline');
-- Expected: ORA-02290: check constraint (CHK_DEPT_ID) violated.
