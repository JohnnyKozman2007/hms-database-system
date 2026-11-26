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
-- Expected: Status flips Available -> Occupied -> Available.
