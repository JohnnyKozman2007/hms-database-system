-- ============================================================================
-- ADVANCED FEATURE: Student 2 (TRIGGER)
-- Trigger: trg_sync_room_availability
-- Purpose: Automatically updates Room AvailabilityStatus when admission status changes
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_sync_room_availability
AFTER INSERT OR UPDATE OF AdmissionStatus ON Admission
FOR EACH ROW
BEGIN
    IF :NEW.AdmissionStatus = 'Discharged' THEN
        UPDATE Room
        SET AvailabilityStatus = 'Available'
        WHERE RoomID = :NEW.RoomID;
    ELSIF :NEW.AdmissionStatus = 'Admitted' THEN
        UPDATE Room
        SET AvailabilityStatus = 'Occupied'
        WHERE RoomID = :NEW.RoomID;
    END IF;
END;
/
