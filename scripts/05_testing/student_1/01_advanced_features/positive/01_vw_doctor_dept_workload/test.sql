-- [POSITIVE] Showcase vw_doctor_dept_workload
SELECT DoctorID, DoctorName, DepartmentName, SupervisorName,
       TotalAppointments, ActiveAppointments, TotalMedicalRecords,
       TotalProcedures, TotalPrescriptions, TotalLabTests
FROM vw_doctor_dept_workload
ORDER BY DoctorID;
-- Expected: 20 rows showing live clinical workload per doctor.
