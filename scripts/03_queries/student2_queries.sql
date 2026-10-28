-- ============================================================================
-- STUDENT 2: Patient and Admission Management Queries
-- Assigned Entities: Patient, Room, Admission
-- ============================================================================

-- Easy 1: Display all patients.
SELECT PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email
FROM Patient
ORDER BY PatientID;

-- Easy 2: Display all currently available rooms.
SELECT RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus
FROM Room
WHERE AvailabilityStatus = 'Available'
ORDER BY Floor, RoomNumber;

-- Medium 3: Display patients together with their admission information.
SELECT p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName,
       a.AdmissionID, a.AdmissionDate, a.DischargeDate, a.AdmissionReason, a.AdmissionStatus,
       r.RoomNumber, r.RoomType
FROM Patient p
JOIN Admission a ON p.PatientID = a.PatientID
JOIN Room r ON a.RoomID = r.RoomID
ORDER BY a.AdmissionDate DESC;

-- Medium 4: Display the number of patients admitted to each room.
SELECT r.RoomID, r.RoomNumber, r.RoomType, COUNT(a.AdmissionID) AS TotalAdmissions
FROM Room r
LEFT JOIN Admission a ON r.RoomID = a.RoomID
GROUP BY r.RoomID, r.RoomNumber, r.RoomType
ORDER BY TotalAdmissions DESC;

-- Medium 5: Display rooms with their daily charges and availability.
SELECT RoomID, RoomNumber, RoomType, DailyCharge, AvailabilityStatus
FROM Room
ORDER BY DailyCharge DESC, RoomNumber;

-- Hard 6: Find patients who have been admitted more than once.
SELECT p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName, p.Phone, COUNT(a.AdmissionID) AS AdmissionCount
FROM Patient p
JOIN Admission a ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName, p.Phone
HAVING COUNT(a.AdmissionID) > 1
ORDER BY AdmissionCount DESC;

-- Hard 7: Find rooms that have never been used for an admission.
SELECT r.RoomID, r.RoomNumber, r.RoomType, r.Floor, r.DailyCharge
FROM Room r
WHERE NOT EXISTS (
    SELECT 1
    FROM Admission a
    WHERE a.RoomID = r.RoomID
)
ORDER BY r.RoomNumber;
