-- [NEGATIVE] Invalid AdmissionStatus on UPDATE (chk_adm_status)
UPDATE Admission SET AdmissionStatus = 'Pending' WHERE AdmissionID = 'ADM001';
-- Expected: ORA-02290: check constraint (CHK_ADM_STATUS) violated.
