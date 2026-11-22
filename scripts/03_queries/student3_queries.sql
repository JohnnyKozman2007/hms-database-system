-- STUDENT 3: Appointments and Medical Records Queries
-- Assigned Entities: Appointment, MedicalRecord, MedicalProcedure

-- Easy 1. Display all appointments.
SELECT
    AppointmentID,
    PatientID,
    DoctorID,
    AppointmentDate,
    AppointmentTime,
    Status,
    Reason,
    Notes
FROM Appointment
ORDER BY AppointmentDate DESC, AppointmentID;

-- Easy 2. Display all medical procedures.
SELECT
    ProcedureID,
    PatientID,
    DoctorID,
    ProcedureName,
    ProcedureDate,
    Duration,
    EndTime,
    OperatingRoom,
    ProcedureCost,
    Outcome
FROM MedicalProcedure
ORDER BY ProcedureDate DESC, ProcedureID;

-- Medium 3. Display appointments with patient and doctor names.
SELECT
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status,
    p.PatientID,
    p.FullName AS PatientName,
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty,
    a.Reason
FROM Appointment a
JOIN Patient p
    ON a.PatientID = p.PatientID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
ORDER BY a.AppointmentDate DESC, a.AppointmentID;

-- Medium 4. Display medical records with patient and doctor information.
SELECT
    mr.RecordID,
    mr.RecordDate,
    mr.FollowUpDate,
    p.PatientID,
    p.FullName AS PatientName,
    p.BloodType,
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty,
    mr.Diagnosis,
    mr.Treatment
FROM MedicalRecord mr
JOIN Patient p
    ON mr.PatientID = p.PatientID
JOIN Doctor d
    ON mr.DoctorID = d.DoctorID
ORDER BY mr.RecordDate DESC, mr.RecordID;

-- Medium 5. Count the appointments for each doctor.
SELECT
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty,
    COUNT(a.AppointmentID) AS AppointmentCount
FROM Doctor d
LEFT JOIN Appointment a
    ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FullName, d.Specialty
ORDER BY AppointmentCount DESC, d.DoctorID;

-- Hard 6. Find the doctor with the highest number of appointments.
SELECT
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty,
    COUNT(a.AppointmentID) AS AppointmentCount
FROM Doctor d
JOIN Appointment a
    ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FullName, d.Specialty
HAVING COUNT(a.AppointmentID) = (
    SELECT MAX(COUNT(AppointmentID))
    FROM Appointment
    GROUP BY DoctorID
);

-- Hard 7. Find patients treated by more than one doctor.
SELECT
    p.PatientID,
    p.FullName AS PatientName,
    COUNT(DISTINCT mr.DoctorID) AS DistinctDoctorCount,
    COUNT(mr.RecordID) AS TotalMedicalRecords
FROM Patient p
JOIN MedicalRecord mr
    ON p.PatientID = mr.PatientID
GROUP BY p.PatientID, p.FullName
HAVING COUNT(DISTINCT mr.DoctorID) > 1
ORDER BY DistinctDoctorCount DESC, TotalMedicalRecords DESC, p.PatientID;
