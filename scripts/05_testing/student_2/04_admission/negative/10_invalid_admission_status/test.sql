-- [NEGATIVE] Invalid AdmissionStatus on UPDATE (chk_adm_status / chk_adm_status_sync)
UPDATE Admission SET AdmissionStatus = 'Pending' WHERE AdmissionID = 'ADM001';
-- Expected: ORA-02290: check constraint (CHK_ADM_STATUS / CHK_ADM_STATUS_SYNC) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.
