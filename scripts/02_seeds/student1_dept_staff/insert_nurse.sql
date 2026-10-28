-- ============================================================================
-- SEED DATA: Nurse (Student 1)
-- Target: Minimum 30 nurses
-- ID Range: 1 to 30
-- Foreign Keys: DepartmentID must be between 1 and 8
-- ============================================================================

INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, Shift, YearsOfExperience, DepartmentID)
VALUES (1, 'Emily', 'Clark', 'Female', '+44-7700-910001', 'e.clark@hospital.org', 'Day', 6, 1);

INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, Shift, YearsOfExperience, DepartmentID)
VALUES (2, 'Oliver', 'Brown', 'Male', '+44-7700-910002', 'o.brown@hospital.org', 'Night', 4, 1);

INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, Shift, YearsOfExperience, DepartmentID)
VALUES (3, 'Chloe', 'Davies', 'Female', '+44-7700-910003', 'c.davies@hospital.org', 'Rotational', 8, 2);

-- Add remaining nurses (4 to 30) following this exact pattern.
COMMIT;
