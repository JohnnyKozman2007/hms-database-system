-- [NEGATIVE] Invalid AvailabilityStatus on UPDATE (chk_room_status)
UPDATE Room SET AvailabilityStatus = 'Cleaning' WHERE RoomID = 'RM029';
-- Expected: ORA-02290: check constraint (CHK_ROOM_STATUS) violated.
