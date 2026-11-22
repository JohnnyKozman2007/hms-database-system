CREATE OR REPLACE TRIGGER trg_adm_sync_room_status
FOR INSERT OR UPDATE OR DELETE ON Admission
COMPOUND TRIGGER
    TYPE t_room_map IS TABLE OF BOOLEAN INDEX BY VARCHAR2(10);
    g_affected_rooms t_room_map;

    BEFORE EACH ROW IS
        v_room_status VARCHAR2(20);
    BEGIN
        IF (INSERTING OR UPDATING) AND :NEW.AdmissionStatus = 'Admitted' THEN
            BEGIN
                SELECT AvailabilityStatus
                INTO v_room_status
                FROM Room
                WHERE RoomID = :NEW.RoomID;

                IF v_room_status = 'Maintenance' THEN
                    RAISE_APPLICATION_ERROR(-20011, 'Cannot admit patient to Room ' || :NEW.RoomID || ': Room is currently under Maintenance.');
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
            END;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_affected_rooms(:NEW.RoomID) := TRUE;
        END IF;
        IF UPDATING OR DELETING THEN
            g_affected_rooms(:OLD.RoomID) := TRUE;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_room_id      VARCHAR2(10);
        v_capacity     NUMBER(3);
        v_curr_status  VARCHAR2(20);
        v_active_count NUMBER;
    BEGIN
        v_room_id := g_affected_rooms.FIRST;
        WHILE v_room_id IS NOT NULL LOOP
            SELECT Capacity, AvailabilityStatus
            INTO v_capacity, v_curr_status
            FROM Room
            WHERE RoomID = v_room_id;

            SELECT COUNT(*)
            INTO v_active_count
            FROM Admission
            WHERE RoomID = v_room_id
              AND AdmissionStatus = 'Admitted';

            IF v_active_count > v_capacity THEN
                RAISE_APPLICATION_ERROR(-20010, 'Room capacity exceeded for Room ' || v_room_id || ' (Capacity: ' || v_capacity || ').');
            END IF;

            IF v_curr_status <> 'Maintenance' THEN
                IF v_active_count = v_capacity THEN
                    UPDATE Room
                    SET AvailabilityStatus = 'Occupied'
                    WHERE RoomID = v_room_id;
                ELSIF v_curr_status = 'Occupied' AND v_active_count < v_capacity THEN
                    UPDATE Room
                    SET AvailabilityStatus = 'Available'
                    WHERE RoomID = v_room_id;
                END IF;
            END IF;

            v_room_id := g_affected_rooms.NEXT(v_room_id);
        END LOOP;
        g_affected_rooms.DELETE;
    END AFTER STATEMENT;
END trg_adm_sync_room_status;
/
