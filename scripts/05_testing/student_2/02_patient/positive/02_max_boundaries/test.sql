-- [POSITIVE - Max Boundaries] DateOfBirth = TRUNC(SYSDATE), 11-digit Mobile, O'Connor apostrophe
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('PAT_MAX_01', 'O''Connor', 'El-Masry', TRUNC(SYSDATE), 'Female', 'AB-', '01099112202', 'Mobile', 'pat.max@mail.eg', '999', 'El-Horreya Avenue', 'Alexandria', '21500', '01199112203');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
