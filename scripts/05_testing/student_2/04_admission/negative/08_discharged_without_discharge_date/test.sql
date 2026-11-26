-- [NEGATIVE - Mohamed] Status = 'Discharged' with NULL DischargeDate (chk_adm_status_sync)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM996', 'PAT020', 'RM010', DATE '2023-03-01', NULL, 'Test reason that is long enough', 'Discharged');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_STATUS_SYNC) violated.
