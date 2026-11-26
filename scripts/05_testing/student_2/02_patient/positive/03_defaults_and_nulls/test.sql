-- [POSITIVE - Defaults & NULLs] Omit PhoneType (DEFAULT 'Mobile'); BuildingNumber = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('PAT_DEF_01', 'Nour', 'Samy', DATE '1995-03-20', 'Female', 'O-', '01299112204', 'nour.def@mail.eg', NULL, 'Pyramids Road', 'Giza', '12511', '01599112205');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with PhoneType = 'Mobile'.
