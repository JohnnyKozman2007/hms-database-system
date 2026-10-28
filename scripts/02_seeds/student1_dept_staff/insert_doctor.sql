-- ============================================================================
-- SEED DATA: Doctor (Student 1)
-- Target: Minimum 20 doctors
-- ID Range: 1 to 20
-- Foreign Keys: DepartmentID must be between 1 and 8
-- ============================================================================

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (1, 'James', 'Wilson', 'Male', '+44-7700-900001', 'j.wilson@hospital.org', 'Interventional Cardiologist', DATE '2015-03-15', 12, 1);

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (2, 'Sarah', 'Jenkins', 'Female', '+44-7700-900002', 's.jenkins@hospital.org', 'Electrophysiologist', DATE '2018-07-01', 8, 1);

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (3, 'David', 'Patel', 'Male', '+44-7700-900003', 'd.patel@hospital.org', 'Neurologist', DATE '2012-09-10', 15, 2);

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (4, 'Elena', 'Rostova', 'Female', '+44-7700-900004', 'e.rostova@hospital.org', 'Pediatric Neurologist', DATE '2020-01-15', 5, 2);

INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
VALUES (5, 'Marcus', 'Abebe', 'Male', '+44-7700-900005', 'm.abebe@hospital.org', 'Orthopedic Surgeon', DATE '2014-06-20', 13, 3);

-- Add remaining doctors (6 to 20) following this exact pattern.
COMMIT;
