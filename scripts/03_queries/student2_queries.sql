-- STUDENT 2: Patient and Admission Management Queries
-- Assigned Entities: Patient, Room, Admission

-- Easy 1. Display all patients.
SELECT
    PatientID,
    FullName,
    DateOfBirth,
    Gender,
    BloodType,
    Phone,
    PhoneType,
    Email,
    Address,
    EmergencyContact
FROM Patient
ORDER BY PatientID;

-- Easy 2. Display all currently available rooms.
SELECT
    RoomID,
    RoomNumber,
    Building,
    Floor,
    RoomType,
    Capacity,
    DailyCharge,
    AvailabilityStatus
FROM Room
WHERE AvailabilityStatus = 'Available'
ORDER BY Building, Floor, RoomNumber;

-- Medium 3. Display patients together with their admission information.
SELECT
    p.PatientID,
    p.FullName AS PatientName,
    p.BloodType,
    a.AdmissionID,
    a.RoomID,
    a.AdmissionDate,
    a.DischargeDate,
    a.AdmissionStatus,
    a.AdmissionReason
FROM Patient p
JOIN Admission a
    ON p.PatientID = a.PatientID
ORDER BY a.AdmissionDate DESC, p.PatientID;

-- Medium 4. Display the number of patients admitted to each room.
SELECT
    r.RoomID,
    r.RoomNumber,
    r.Building,
    r.Floor,
    r.RoomType,
    COUNT(a.AdmissionID) AS TotalAdmissions,
    COUNT(DISTINCT a.PatientID) AS DistinctPatientsAdmitted
FROM Room r
LEFT JOIN Admission a
    ON r.RoomID = a.RoomID
GROUP BY r.RoomID, r.RoomNumber, r.Building, r.Floor, r.RoomType
ORDER BY TotalAdmissions DESC, r.RoomID;

-- Medium 5. Display rooms with their daily charges and availability.
SELECT
    RoomID,
    RoomNumber,
    Building,
    Floor,
    RoomType,
    Capacity,
    DailyCharge,
    AvailabilityStatus
FROM Room
ORDER BY DailyCharge DESC, RoomID;

-- Hard 6. Find patients who have been admitted more than once.
SELECT
    p.PatientID,
    p.FullName AS PatientName,
    p.Phone,
    COUNT(a.AdmissionID) AS AdmissionCount
FROM Patient p
JOIN Admission a
    ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.FullName, p.Phone
HAVING COUNT(a.AdmissionID) > 1
ORDER BY AdmissionCount DESC, p.PatientID;

-- Hard 7. Find rooms that have never been used for an admission.
SELECT
    r.RoomID,
    r.RoomNumber,
    r.Building,
    r.Floor,
    r.RoomType,
    r.Capacity,
    r.DailyCharge,
    r.AvailabilityStatus
FROM Room r
WHERE NOT EXISTS (
    SELECT 1
    FROM Admission a
    WHERE a.RoomID = r.RoomID
)
ORDER BY r.RoomID;
