-- ============================================================================
-- ADVANCED FEATURE: Student 1 (VIEW)
-- View: v_doctor_department_summary
-- Purpose: Provides an executive view of staff distribution and experience per department
-- ============================================================================

CREATE OR REPLACE VIEW v_doctor_department_summary AS
SELECT dept.DepartmentID,
       dept.DepartmentName,
       dept.Location,
       COUNT(DISTINCT d.DoctorID) AS TotalDoctors,
       COUNT(DISTINCT n.NurseID) AS TotalNurses,
       NVL(ROUND(AVG(d.YearsOfExperience), 1), 0) AS AvgDoctorExperienceYears
FROM Department dept
LEFT JOIN Doctor d ON dept.DepartmentID = d.DepartmentID
LEFT JOIN Nurse n ON dept.DepartmentID = n.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName, dept.Location;

-- How to test:
-- SELECT * FROM v_doctor_department_summary;
