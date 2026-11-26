-- [NEGATIVE] Invalid TestStatus (chk_lab_status / chk_lab_status_sync)
UPDATE LaboratoryTest SET TestStatus = 'Archived' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_STATUS / CHK_LAB_STATUS_SYNC) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.
