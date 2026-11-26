-- [POSITIVE - Defaults & NULLs] Omit AdmissionDate (SYSDATE), AdmissionStatus ('Admitted'); DischargeDate = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, DischargeDate, AdmissionReason)
    VALUES ('ADM_DEF_01', 'PAT022', 'RM029', NULL, 'Post-surgical recovery');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with AdmissionDate = SYSDATE and AdmissionStatus = 'Admitted'.
