-- [NEGATIVE] Invalid OperatingRoom on UPDATE (chk_proc_room)
UPDATE MedicalProcedure SET OperatingRoom = 'Room 101' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_ROOM) violated.
