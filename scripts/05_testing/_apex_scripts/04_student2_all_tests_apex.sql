-- ============================================================================
-- ORACLE APEX SQL SCRIPT: STUDENT_2
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] student_2\01_advanced_features\negative\01_admit_maintenance_room
-- [NEGATIVE - Mohamed] Admit into a Maintenance room (RM041)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM993', 'PAT020', 'RM041', 'Should be blocked by the trigger');
-- Expected / Actual (Screenshot): ORA-20011: Cannot admit patient to Room RM041: Room is currently under Maintenance.

-- [02] student_2\01_advanced_features\negative\02_exceed_room_capacity
-- [NEGATIVE - Mohamed] Exceed room capacity (RM002 is already full with 2 patients)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM992', 'PAT020', 'RM002', 'This should exceed the room capacity');
-- Expected / Actual (Screenshot): ORA-20010: Room capacity exceeded for Room RM002 (Capacity: 2).

-- [03] student_2\01_advanced_features\positive\01_admit_flips_room_to_occupied_and_discharge_restores
-- Expected: Status flips Available -> Occupied -> Available.
-- [POSITIVE] Showcase trg_adm_sync_room_status (Admit -> Occupied, Discharge -> Available)
DECLARE
    v_status1 Room.AvailabilityStatus%TYPE;
    v_status2 Room.AvailabilityStatus%TYPE;
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
    VALUES ('RM_TRG1', '901', 'Building A', '1st Floor', 'Private', 1, 1500.00, 'Available');

    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, Street, City, PostalCode, EmergencyContact)
    VALUES ('PAT_TRG1', 'Karim', 'Adel', DATE '1990-05-10', 'Male', 'O+', '01099110001', 'Mobile', 'karim.trg1@mail.eg', 'Nile St', 'Cairo', '11511', '01099110002');

    INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
    VALUES ('ADM_TRG1', 'PAT_TRG1', 'RM_TRG1', TRUNC(SYSDATE), NULL, 'Post-operative monitoring', 'Admitted');

    SELECT AvailabilityStatus INTO v_status1 FROM Room WHERE RoomID = 'RM_TRG1';
    DBMS_OUTPUT.PUT_LINE('After Admit -> RM_TRG1 Status: ' || v_status1);

    UPDATE Admission SET AdmissionStatus = 'Discharged', DischargeDate = TRUNC(SYSDATE) WHERE AdmissionID = 'ADM_TRG1';

    SELECT AvailabilityStatus INTO v_status2 FROM Room WHERE RoomID = 'RM_TRG1';
    DBMS_OUTPUT.PUT_LINE('After Discharge -> RM_TRG1 Status: ' || v_status2);

    ROLLBACK TO sp_test;
END;
/

-- [04] student_2\02_patient\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate PatientID (pk_patient)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT001', 'Dup', 'Pat', DATE '1990-01-01', 'Male', 'A+', '01099112206', 'dup.pat@mail.eg', 'Test St', 'Cairo', '11511', '01099112207');
-- Expected: ORA-00001: unique constraint (PK_PATIENT) violated.

-- [05] student_2\02_patient\negative\02_invalid_patient_id
-- [NEGATIVE] Invalid PatientID format (chk_pat_id)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT@1', 'Bad', 'ID', DATE '1990-01-01', 'Male', 'A+', '01099112208', 'bad.id@mail.eg', 'Test St', 'Cairo', '11511', '01099112209');
-- Expected: ORA-02290: check constraint (CHK_PAT_ID) violated.

-- [06] student_2\02_patient\negative\03_invalid_first_name
-- [NEGATIVE - Mohamed] FirstName contains digits (chk_pat_fname)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT993', 'Ahmed123', 'Test', DATE '1990-01-01', 'Male', 'A+', '01099999993', 'name.test993@mail.eg', 'Test Street', 'Cairo', '11511', '01299999993');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_FNAME) violated.

-- [07] student_2\02_patient\negative\04_dob_before_1900
-- [NEGATIVE - Mohamed] DateOfBirth before 1900-01-01 (chk_pat_dob)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT998', 'Old', 'Person', DATE '1899-12-31', 'Male', 'O+', '01099999998', 'old.person998@mail.eg', 'Test Street', 'Cairo', '11511', '01299999998');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_DOB) violated.

-- [08] student_2\02_patient\negative\05_invalid_blood_type
-- [NEGATIVE - Mohamed] Invalid BloodType (chk_pat_blood)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT997', 'Bad', 'Blood', DATE '1990-01-01', 'Female', 'C+', '01099999997', 'bad.blood997@mail.eg', 'Test Street', 'Cairo', '11511', '01299999997');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_BLOOD) violated.

-- [09] student_2\02_patient\negative\06_invalid_gender
-- [NEGATIVE] Invalid Gender on UPDATE (chk_pat_gender)
UPDATE Patient SET Gender = 'Other' WHERE PatientID = 'PAT001';
-- Expected: ORA-02290: check constraint (CHK_PAT_GENDER) violated.

-- [10] student_2\02_patient\negative\07_invalid_mobile_phone
-- [NEGATIVE - Mohamed] Invalid Mobile Phone prefix (chk_pat_phone)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT996', 'Bad', 'Phone', DATE '1990-01-01', 'Male', 'A+', '02012345678', 'Mobile', 'bad.phone996@mail.eg', 'Test Street', 'Cairo', '11511', '01299999996');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_PHONE) violated.

-- [11] student_2\02_patient\negative\08_invalid_emergency_contact
-- [NEGATIVE - Mohamed] EmergencyContact not a valid 11-digit mobile (chk_pat_emg_num)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT994', 'Bad', 'Emg', DATE '1990-01-01', 'Male', 'A+', '01099999994', 'bad.emg994@mail.eg', 'Test Street', 'Cairo', '11511', '0235559999');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_EMG_NUM) violated.

-- [12] student_2\02_patient\negative\09_emergency_same_as_phone
-- [NEGATIVE - Mohamed] EmergencyContact same as Phone (chk_pat_emg)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT995', 'Same', 'Contact', DATE '1990-01-01', 'Female', 'B+', '01099999995', 'same.contact995@mail.eg', 'Test Street', 'Cairo', '11511', '01099999995');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_EMG) violated.

-- [13] student_2\02_patient\negative\10_street_too_short
-- [NEGATIVE - Mohamed] Street shorter than 3 chars (chk_pat_street_len)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT992', 'Short', 'Street', DATE '1990-01-01', 'Female', 'O+', '01099999992', 'short.street992@mail.eg', 'AB', 'Cairo', '11511', '01299999992');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_STREET_LEN) violated.

-- [14] student_2\02_patient\negative\11_duplicate_email
-- [NEGATIVE] Duplicate Email on UPDATE (uq_pat_email)
UPDATE Patient SET Email = 'fatma.zaki.002@mail.eg' WHERE PatientID = 'PAT001';
-- Expected: ORA-00001: unique constraint (UQ_PAT_EMAIL) violated.

-- [15] student_2\02_patient\negative\12_duplicate_phone
-- [NEGATIVE] Duplicate Phone on UPDATE (uq_pat_phone)
UPDATE Patient SET Phone = '01155550002' WHERE PatientID = 'PAT001';
-- Expected: ORA-00001: unique constraint (UQ_PAT_PHONE) violated.

-- [16] student_2\02_patient\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] DateOfBirth = 1900-01-01, 9-digit Landline, 3-char Street, 2-char City
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('P1', 'A', 'B', DATE '1900-01-01', 'Male', 'A+', '022795931', 'Landline', 'p@ab.eg', '1', 'St1', 'Al', '1', '01099112201');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [17] student_2\02_patient\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] DateOfBirth = TRUNC(SYSDATE), 11-digit Mobile, O'Connor apostrophe
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('PAT_MAX_01', 'O''Connor', 'El-Masry', TRUNC(SYSDATE), 'Female', 'AB-', '01099112202', 'Mobile', 'pat.max@mail.eg', '999', 'El-Horreya Avenue', 'Alexandria', '21500', '01199112203');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [18] student_2\02_patient\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with PhoneType = 'Mobile'.
-- [POSITIVE - Defaults & NULLs] Omit PhoneType (DEFAULT 'Mobile'); BuildingNumber = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, BuildingNumber, Street, City, PostalCode, EmergencyContact)
    VALUES ('PAT_DEF_01', 'Nour', 'Samy', DATE '1995-03-20', 'Female', 'O-', '01299112204', 'nour.def@mail.eg', NULL, 'Pyramids Road', 'Giza', '12511', '01599112205');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [19] student_2\02_patient\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update City & Street
BEGIN
    SAVEPOINT sp_test;
    UPDATE Patient SET City = 'Giza', Street = 'Pyramids Avenue' WHERE PatientID = 'PAT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [20] student_2\03_room\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate RoomID (pk_room)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
VALUES ('RM001', '991', 'Building A', '1st Floor', 'Private', 1000.00);
-- Expected: ORA-00001: unique constraint (PK_ROOM) violated.

-- [21] student_2\03_room\negative\02_invalid_room_id
-- [NEGATIVE] Invalid RoomID (chk_room_id)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
VALUES ('RM@1', '992', 'Building A', '1st Floor', 'Private', 1000.00);
-- Expected: ORA-02290: check constraint (CHK_ROOM_ID) violated.

-- [22] student_2\03_room\negative\03_invalid_building
-- [NEGATIVE - Mohamed] Invalid Building (chk_room_bldg)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM995', '995', 'Building E', 'Ground Floor', 'Private', 1, 1800.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_BLDG) violated.

-- [23] student_2\03_room\negative\04_invalid_floor
-- [NEGATIVE - Mohamed] Invalid Floor (chk_room_floor)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM994', '994', 'Building A', '6th Floor', 'Private', 1, 1800.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_FLOOR) violated.

-- [24] student_2\03_room\negative\05_invalid_room_type
-- [NEGATIVE - Mohamed] Invalid RoomType (chk_room_type_cap / chk_room_type)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM999', '999', 'Building A', 'Ground Floor', 'VIP Suite', 1, 3000.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_TYPE_CAP) violated.

-- [25] student_2\03_room\negative\06_private_room_capacity_2
-- [NEGATIVE - Mohamed] Private room with Capacity = 2 (chk_room_type_cap)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM998', '998', 'Building A', '1st Floor', 'Private', 2, 2000.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_TYPE_CAP) violated.

-- [26] student_2\03_room\negative\07_capacity_zero
-- [NEGATIVE - Mohamed] Capacity = 0 (chk_room_capacity)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM997', '997', 'Building B', '2nd Floor', 'General Ward', 0, 500.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_CAPACITY) violated.

-- [27] student_2\03_room\negative\08_daily_charge_zero
-- [NEGATIVE - Mohamed] DailyCharge = 0 (chk_room_charge)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM996', '996', 'Building C', '3rd Floor', 'ICU', 1, 0);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_CHARGE) violated.

-- [28] student_2\03_room\negative\09_invalid_availability_status
-- [NEGATIVE] Invalid AvailabilityStatus on UPDATE (chk_room_status)
UPDATE Room SET AvailabilityStatus = 'Cleaning' WHERE RoomID = 'RM029';
-- Expected: ORA-02290: check constraint (CHK_ROOM_STATUS) violated.

-- [29] student_2\03_room\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] Capacity = 1, DailyCharge = 0.01
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
    VALUES ('R1', '1', 'Building A', 'Ground Floor', 'Private', 1, 0.01, 'Available');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [30] student_2\03_room\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] Capacity = 20 (General Ward), DailyCharge = 10000.00
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
    VALUES ('RM_MAX_01', '599-A', 'Building D', '5th Floor', 'General Ward', 20, 10000.00, 'Reserved');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [31] student_2\03_room\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with Capacity = 1 and AvailabilityStatus = 'Available'.
-- [POSITIVE - Defaults] Omit Capacity (DEFAULT 1) & AvailabilityStatus (DEFAULT 'Available')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
    VALUES ('RM_DEF_01', '299', 'Building B', '2nd Floor', 'ICU', 3500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [32] student_2\03_room\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update DailyCharge & AvailabilityStatus
BEGIN
    SAVEPOINT sp_test;
    UPDATE Room SET DailyCharge = 3750.00, AvailabilityStatus = 'Maintenance' WHERE RoomID = 'RM029';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [33] student_2\04_admission\negative\01_second_active_stay
-- [NEGATIVE - Mohamed] Second active admission for same patient (uq_adm_one_active_stay)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM994', 'PAT001', 'RM010', 'Second active stay should be rejected');
-- Expected / Actual (Screenshot): ORA-00001: unique constraint (UQ_ADM_ONE_ACTIVE_STAY) violated.

-- [34] student_2\04_admission\negative\02_invalid_admission_id
-- [NEGATIVE] Invalid AdmissionID (chk_adm_id)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM@1', 'PAT020', 'RM029', 'Invalid ID test');
-- Expected: ORA-02290: check constraint (CHK_ADM_ID) violated.

-- [35] student_2\04_admission\negative\03_invalid_patient_fk
-- [NEGATIVE] Non-existent PatientID (fk_adm_patient)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM_FK1', 'PAT999', 'RM029', 'Invalid patient FK test');
-- Expected: ORA-02291: integrity constraint (FK_ADM_PATIENT) violated.

-- [36] student_2\04_admission\negative\04_invalid_room_fk
-- [NEGATIVE] Non-existent RoomID (fk_adm_room)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM_FK2', 'PAT020', 'RM999', 'Invalid room FK test');
-- Expected: ORA-02291: integrity constraint (FK_ADM_ROOM) violated.

-- [37] student_2\04_admission\negative\05_admission_date_before_2020
-- [NEGATIVE - Mohamed] AdmissionDate before 2020-01-01 (chk_adm_date_lower)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, AdmissionReason)
VALUES ('ADM999', 'PAT020', 'RM010', DATE '2019-12-31', 'Test reason that is long enough');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_DATE_LOWER) violated.

-- [38] student_2\04_admission\negative\06_discharge_before_admission
-- [NEGATIVE - Mohamed] DischargeDate earlier than AdmissionDate (chk_adm_dates)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM998', 'PAT020', 'RM010', DATE '2023-01-10', DATE '2023-01-05', 'Test reason that is long enough', 'Discharged');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_DATES) violated.

-- [39] student_2\04_admission\negative\07_admitted_with_discharge_date
-- [NEGATIVE - Mohamed] Status = 'Admitted' with non-null DischargeDate (chk_adm_status_sync)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM997', 'PAT020', 'RM010', DATE '2023-02-01', DATE '2023-02-10', 'Test reason that is long enough', 'Admitted');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_STATUS_SYNC) violated.

-- [40] student_2\04_admission\negative\08_discharged_without_discharge_date
-- [NEGATIVE - Mohamed] Status = 'Discharged' with NULL DischargeDate (chk_adm_status_sync)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES ('ADM996', 'PAT020', 'RM010', DATE '2023-03-01', NULL, 'Test reason that is long enough', 'Discharged');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_STATUS_SYNC) violated.

-- [41] student_2\04_admission\negative\09_admission_reason_too_short
-- [NEGATIVE - Mohamed] AdmissionReason shorter than 5 chars (chk_adm_reason_len)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM995', 'PAT020', 'RM010', 'Bad');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ADM_REASON_LEN) violated.

-- [42] student_2\04_admission\negative\10_invalid_admission_status
-- [NEGATIVE] Invalid AdmissionStatus on UPDATE (chk_adm_status)
UPDATE Admission SET AdmissionStatus = 'Pending' WHERE AdmissionID = 'ADM001';
-- Expected: ORA-02290: check constraint (CHK_ADM_STATUS) violated.

-- [43] student_2\04_admission\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] AdmissionDate = 2020-01-01, DischargeDate = AdmissionDate, 5-char Reason
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
    VALUES ('A1', 'PAT020', 'RM029', DATE '2020-01-01', DATE '2020-01-01', 'Fever', 'Discharged');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [44] student_2\04_admission\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] AdmissionDate = TRUNC(SYSDATE), Admitted
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
    VALUES ('ADM_MAX_01', 'PAT021', 'RM029', TRUNC(SYSDATE), NULL, 'Comprehensive inpatient cardiac observation', 'Admitted');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [45] student_2\04_admission\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with AdmissionDate = SYSDATE and AdmissionStatus = 'Admitted'.
-- [POSITIVE - Defaults & NULLs] Omit AdmissionDate (SYSDATE), AdmissionStatus ('Admitted'); DischargeDate = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Admission (AdmissionID, PatientID, RoomID, DischargeDate, AdmissionReason)
    VALUES ('ADM_DEF_01', 'PAT022', 'RM029', NULL, 'Post-surgical recovery');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [46] student_2\04_admission\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Discharge an admitted patient
BEGIN
    SAVEPOINT sp_test;
    UPDATE Admission SET AdmissionStatus = 'Discharged', DischargeDate = TRUNC(SYSDATE) WHERE AdmissionID = 'ADM001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
