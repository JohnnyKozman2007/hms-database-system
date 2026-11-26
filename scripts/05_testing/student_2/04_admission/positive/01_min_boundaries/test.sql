-- [POSITIVE - Min Boundaries] AdmissionDate = 2020-01-01, DischargeDate = AdmissionDate, 5-char Reason
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
    VALUES ('A1', 'PAT020', 'RM029', DATE '2020-01-01', DATE '2020-01-01', 'Fever', 'Discharged');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
