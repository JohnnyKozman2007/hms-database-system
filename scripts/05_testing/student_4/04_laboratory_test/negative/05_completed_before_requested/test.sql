-- [NEGATIVE] CompletedDate earlier than RequestedDate (chk_lab_dates)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = DATE '2020-01-01', TestResult = 'Normal result' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_DATES) violated.
