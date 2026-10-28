-- ============================================================================
-- TESTING SUITE: Student 1 (Department, Doctor, Nurse)
-- ============================================================================

-- POSITIVE TEST 1: Insert valid department
INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (99, 'Radiology', 'Building E, Ground Floor', '+44-1707-284099', 'Imaging and diagnostic scans');
-- Expected: 1 row inserted.

-- NEGATIVE TEST 1: Attempt duplicate DepartmentName (Unique constraint violation)
-- Expected Oracle Error: ORA-00001 (unique constraint violated)
INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (100, 'Cardiology', 'Building F', '+44-1707-284100', 'Duplicate department test');

-- NEGATIVE TEST 2: Attempt doctor with invalid DepartmentID (FK constraint violation)
-- Expected Oracle Error: ORA-02291 (integrity constraint violated - parent key not found)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (999, 'Test', 'Doctor', 'Male', '+44-7700-999999', 'test.doc@hospital.org', 'General', SYSDATE, 5, 9999);

-- NEGATIVE TEST 3: Attempt doctor with negative experience (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (998, 'Invalid', 'Exp', 'Male', '+44-7700-999998', 'inv.exp@hospital.org', 'General', SYSDATE, -3, 1);
ROLLBACK;
