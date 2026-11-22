CREATE OR REPLACE VIEW vw_doctor_dept_workload AS
SELECT
    d.DoctorID,
    d.FullName                                          AS DoctorName,
    d.Specialty,
    d.YearsOfExperience,
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location                                       AS DepartmentLocation,
    sup.FullName                                        AS SupervisorName,
    (SELECT COUNT(*) FROM Appointment a
      WHERE a.DoctorID = d.DoctorID)                    AS TotalAppointments,
    (SELECT COUNT(*) FROM Appointment a
      WHERE a.DoctorID = d.DoctorID
        AND a.Status IN ('Scheduled', 'In-Progress'))   AS ActiveAppointments,
    (SELECT COUNT(*) FROM MedicalRecord mr
      WHERE mr.DoctorID = d.DoctorID)                   AS TotalMedicalRecords,
    (SELECT COUNT(*) FROM MedicalProcedure mp
      WHERE mp.DoctorID = d.DoctorID)                   AS TotalProcedures,
    (SELECT COUNT(*) FROM Prescription rx
      WHERE rx.DoctorID = d.DoctorID)                   AS TotalPrescriptions,
    (SELECT COUNT(*) FROM LaboratoryTest lt
      WHERE lt.DoctorID = d.DoctorID)                   AS TotalLabTests
FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN Doctor sup ON d.SupervisorID = sup.DoctorID;

CREATE OR REPLACE VIEW vw_department_staff_summary AS
SELECT
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location,
    dept.Phone                                          AS DepartmentPhone,
    COUNT(DISTINCT d.DoctorID)                          AS DoctorCount,
    COUNT(DISTINCT n.NurseID)                           AS NurseCount,
    COUNT(DISTINCT d.DoctorID) + COUNT(DISTINCT n.NurseID) AS TotalClinicalStaff,
    ROUND(NVL(AVG(d.YearsOfExperience), 0), 1)          AS AvgDoctorExperience,
    ROUND(NVL(AVG(n.YearsOfExperience), 0), 1)          AS AvgNurseExperience
FROM Department dept
LEFT JOIN Doctor d ON dept.DepartmentID = d.DepartmentID
LEFT JOIN Nurse n  ON dept.DepartmentID = n.DepartmentID
GROUP BY
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location,
    dept.Phone;
