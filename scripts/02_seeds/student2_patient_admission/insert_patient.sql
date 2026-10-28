-- ============================================================================
-- SEED DATA: Patient (Student 2)
-- Target: Minimum 100 patients
-- ID Range: 1 to 100
-- ============================================================================

INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Address, EmergencyContact, Email)
VALUES (1, 'John', 'Smith', DATE '1985-04-12', 'Male', 'O+', '+44-7800-111001', '14 Hatfield Rd, St Albans', '+44-7800-999001', 'j.smith@email.com');

INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Address, EmergencyContact, Email)
VALUES (2, 'Mary', 'Johnson', DATE '1992-11-23', 'Female', 'A+', '+44-7800-111002', '28 College Lane, Hatfield', '+44-7800-999002', 'm.johnson@email.com');

-- Add remaining patients (3 to 100) following this exact pattern.
COMMIT;
