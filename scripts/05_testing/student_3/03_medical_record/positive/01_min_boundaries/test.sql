-- [POSITIVE - Min Boundaries] RecordDate = 2020-01-01, FollowUpDate = RecordDate, 5-char strings
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)
    VALUES ('M1', 'PAT001', 'DOC001', 'Fever', 'Fluids', 'Notes', DATE '2020-01-01', DATE '2020-01-01');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
