-- [NEGATIVE - Mohamed] Status = 'Admitted' with non-null DischargeDate (chk_adm_status_sync)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM997', 'PAT020', 'RM010', DATE '2023-02-01', DATE '2023-02-10', 'Test reason that is long enough', 'Admitted');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_STATUS_SYNC) violated.
