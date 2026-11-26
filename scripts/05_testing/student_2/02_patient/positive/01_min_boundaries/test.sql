-- [POSITIVE - Min Boundaries] DateOfBirth = 1900-01-01, 9-digit Landline, 3-char Street, 2-char City
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('P1', 'A', 'B', DATE '1900-01-01', 'Male', 'A+', '022795931', 'Landline', 'p@ab.eg', '1', 'St1', 'Al', '1', '01099112201');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
