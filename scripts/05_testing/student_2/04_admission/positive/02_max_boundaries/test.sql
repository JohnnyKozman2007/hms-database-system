-- [POSITIVE - Max Boundaries] AdmissionDate = TRUNC(SYSDATE), Admitted
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
    VALUES ('ADM_MAX_01', 'PAT021', 'RM029', TRUNC(SYSDATE), NULL, 'Comprehensive inpatient cardiac observation', 'Admitted');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
