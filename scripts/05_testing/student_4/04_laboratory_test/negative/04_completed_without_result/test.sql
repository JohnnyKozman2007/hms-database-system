-- [NEGATIVE] Completed without CompletedDate/TestResult (chk_lab_status_sync)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = NULL, TestResult = NULL WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_STATUS_SYNC) violated.
