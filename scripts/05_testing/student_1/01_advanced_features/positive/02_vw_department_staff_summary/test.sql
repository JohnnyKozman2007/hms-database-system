-- [POSITIVE] Showcase vw_department_staff_summary
SELECT DepartmentID, DepartmentName, Location,
       DoctorCount, NurseCount, TotalClinicalStaff,
       AvgDoctorExperience, AvgNurseExperience
FROM vw_department_staff_summary
ORDER BY DepartmentID;
-- Expected: 8 rows summarizing clinical staff counts and experience per department.
