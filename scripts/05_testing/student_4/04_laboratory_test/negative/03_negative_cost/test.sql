-- [NEGATIVE] Negative TestCost on UPDATE (chk_lab_cost)
UPDATE LaboratoryTest SET TestCost = -50 WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_COST) violated.
