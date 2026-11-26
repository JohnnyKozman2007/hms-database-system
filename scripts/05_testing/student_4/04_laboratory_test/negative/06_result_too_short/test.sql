-- [NEGATIVE] TestResult < 5 chars (chk_lab_result_len)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = TRUNC(SYSDATE), TestResult = 'Ok' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_RESULT_LEN) violated.
