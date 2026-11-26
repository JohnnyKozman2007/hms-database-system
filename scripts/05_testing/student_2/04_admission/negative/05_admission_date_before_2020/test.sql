-- [NEGATIVE - Mohamed] AdmissionDate before 2020-01-01 (chk_adm_date_lower)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, AdmissionReason)
VALUES ('ADM999', 'PAT020', 'RM010', DATE '2019-12-31', 'Test reason that is long enough');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_DATE_LOWER) violated.
