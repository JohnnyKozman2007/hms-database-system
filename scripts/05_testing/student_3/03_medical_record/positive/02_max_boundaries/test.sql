-- [POSITIVE - Max Boundaries] RecordDate = TRUNC(SYSDATE), FollowUpDate = RecordDate + 365
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)
    VALUES ('MR_MAX_01', 'PAT002', 'DOC002', 'Essential Hypertension', 'Daily ACE inhibitor therapy', '1-year follow-up boundary', TRUNC(SYSDATE), TRUNC(SYSDATE) + 365);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
