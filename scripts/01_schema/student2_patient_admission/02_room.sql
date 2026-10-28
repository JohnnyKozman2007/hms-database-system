-- Entity: Room (Student 2)
-- Minimum Data Target: 50 rooms
CREATE TABLE Room (
    RoomID                  NUMBER(5)           CONSTRAINT pk_room PRIMARY KEY,
    RoomNumber              VARCHAR2(10)        NOT NULL CONSTRAINT uq_room_num UNIQUE,
    Floor                   NUMBER(2)           NOT NULL CONSTRAINT chk_room_floor CHECK (Floor >= 0),
    RoomType                VARCHAR2(30)        NOT NULL CONSTRAINT chk_room_type CHECK (RoomType IN ('General Ward', 'Semi-Private', 'Private', 'ICU', 'Operation Theater')),
    Capacity                NUMBER(3)           NOT NULL CONSTRAINT chk_room_cap CHECK (Capacity > 0),
    DailyCharge             NUMBER(10,2)        NOT NULL CONSTRAINT chk_room_charge CHECK (DailyCharge >= 0),
    AvailabilityStatus      VARCHAR2(20)        DEFAULT 'Available' NOT NULL CONSTRAINT chk_room_avail CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance'))
);
