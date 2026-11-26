-- [NEGATIVE - Mohamed] AdmissionReason shorter than 5 chars (chk_adm_reason_len)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM995', 'PAT020', 'RM010', 'Bad');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_REASON_LEN) violated.
