CREATE TABLE Room (
    RoomID                  VARCHAR2(10)        CONSTRAINT pk_room PRIMARY KEY,
    RoomNumber              VARCHAR2(10)        NOT NULL,
    Building                VARCHAR2(50)        NOT NULL,
    Floor                   VARCHAR2(20)        NOT NULL,
    RoomType                VARCHAR2(30)        NOT NULL CONSTRAINT chk_room_type CHECK (RoomType IN ('General Ward', 'Semi-Private', 'Private', 'ICU', 'Isolation', 'Emergency', 'Maternity', 'Pediatric', 'Operating Room')),
    Capacity                NUMBER(3)           DEFAULT 1 NOT NULL CONSTRAINT chk_room_capacity CHECK (Capacity > 0 AND Capacity <= 20),
    DailyCharge             NUMBER(10, 2)       NOT NULL CONSTRAINT chk_room_charge CHECK (DailyCharge > 0 AND DailyCharge <= 10000.00),
    AvailabilityStatus      VARCHAR2(20)        DEFAULT 'Available' NOT NULL CONSTRAINT chk_room_status CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance', 'Reserved')),
    CONSTRAINT uq_room_bldg_floor_num UNIQUE (Building, Floor, RoomNumber),
    CONSTRAINT chk_room_type_cap CHECK (
        (RoomType IN ('Private', 'ICU', 'Isolation') AND Capacity = 1) OR
        (RoomType = 'Semi-Private' AND Capacity = 2) OR
        (RoomType IN ('General Ward', 'Emergency', 'Maternity', 'Pediatric', 'Operating Room'))
    )
);

ALTER TABLE Room ADD CONSTRAINT chk_room_id 
    CHECK (REGEXP_LIKE(RoomID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Room ADD CONSTRAINT chk_room_number_fmt 
    CHECK (REGEXP_LIKE(RoomNumber, '^[A-Za-z0-9-]+$'));

ALTER TABLE Room ADD CONSTRAINT chk_room_bldg 
    CHECK (Building IN ('Building A', 'Building B', 'Building C', 'Building D'));

ALTER TABLE Room ADD CONSTRAINT chk_room_floor 
    CHECK (Floor IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'));
