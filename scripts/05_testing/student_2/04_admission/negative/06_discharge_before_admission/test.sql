-- [NEGATIVE - Mohamed] DischargeDate earlier than AdmissionDate (chk_adm_dates)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM998', 'PAT020', 'RM010', DATE '2023-01-10', DATE '2023-01-05', 'Test reason that is long enough', 'Discharged');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_DATES) violated.
