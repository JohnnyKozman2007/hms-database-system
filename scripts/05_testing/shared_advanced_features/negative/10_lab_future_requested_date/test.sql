-- [NEGATIVE] Future LaboratoryTest.RequestedDate (trg_lab_date_max)
UPDATE LaboratoryTest SET RequestedDate = SYSDATE + 1 WHERE TestID = 'LAB001';
-- Expected: ORA-20001: LaboratoryTest.RequestedDate cannot be in the future (exceeds SYSDATE).
