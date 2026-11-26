-- [NEGATIVE] Invalid TestStatus (chk_lab_status)
UPDATE LaboratoryTest SET TestStatus = 'Archived' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_STATUS) violated.
