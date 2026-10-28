-- ============================================================================
-- STUDENT 3: Appointments and Medical Records Queries
-- Assigned Entities: Appointment, MedicalRecord, MedicalProcedure
-- ============================================================================

-- Easy 1: Display all appointments.
SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason
FROM Appointment
ORDER BY AppointmentDate DESC, AppointmentTime;

-- Easy 2: Display all medical procedures.
SELECT ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, OperatingRoom, Duration, ProcedureCost, Outcome
FROM MedicalProcedure
ORDER BY ProcedureDate DESC;

-- Medium 3: Display appointments with patient and doctor names.
SELECT apt.AppointmentID, apt.AppointmentDate, apt.AppointmentTime, apt.Status,
       p.FirstName || ' ' || p.LastName AS PatientName,
       d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty
FROM Appointment apt
JOIN Patient p ON apt.PatientID = p.PatientID
JOIN Doctor d ON apt.DoctorID = d.DoctorID
ORDER BY apt.AppointmentDate DESC;

-- Medium 4: Display medical records with patient and doctor information.
SELECT mr.RecordID, mr.RecordDate, mr.Diagnosis, mr.Treatment, mr.FollowUpDate,
       p.FirstName || ' ' || p.LastName AS PatientName,
       d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty
FROM MedicalRecord mr
JOIN Patient p ON mr.PatientID = p.PatientID
JOIN Doctor d ON mr.DoctorID = d.DoctorID
ORDER BY mr.RecordDate DESC;

-- Medium 5: Count the appointments for each doctor.
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty, COUNT(apt.AppointmentID) AS TotalAppointments
FROM Doctor d
LEFT JOIN Appointment apt ON d.DoctorID = apt.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty
ORDER BY TotalAppointments DESC;

-- Hard 6: Find the doctor with the highest number of appointments.
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty, COUNT(apt.AppointmentID) AS AppointmentCount
FROM Doctor d
JOIN Appointment apt ON d.DoctorID = apt.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty
HAVING COUNT(apt.AppointmentID) = (
    SELECT MAX(COUNT(AppointmentID))
    FROM Appointment
    GROUP BY DoctorID
);

-- Hard 7: Find patients treated by more than one doctor.
SELECT p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName, COUNT(DISTINCT apt.DoctorID) AS DistinctDoctorsSeen
FROM Patient p
JOIN Appointment apt ON p.PatientID = apt.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT apt.DoctorID) > 1
ORDER BY DistinctDoctorsSeen DESC;
