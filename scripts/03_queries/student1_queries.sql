-- ============================================================================
-- STUDENT 1: Department and Staff Management Queries
-- Assigned Entities: Department, Doctor, Nurse
-- ============================================================================

-- Easy 1: Display all doctors.
SELECT DoctorID, FirstName, LastName, Specialty, Phone, Email, HireDate, YearsOfExperience, DepartmentID
FROM Doctor
ORDER BY DoctorID;

-- Easy 2: Display all departments located in a specified location.
SELECT DepartmentID, DepartmentName, Location, Phone, DepartmentDescription
FROM Department
WHERE Location LIKE '%Building A%'
ORDER BY DepartmentID;

-- Medium 3: Display doctors together with their department names.
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty, dept.DepartmentName, dept.Location
FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID
ORDER BY dept.DepartmentName, d.LastName;

-- Medium 4: Count the number of doctors in each department.
SELECT dept.DepartmentID, dept.DepartmentName, COUNT(d.DoctorID) AS TotalDoctors
FROM Department dept
LEFT JOIN Doctor d ON dept.DepartmentID = d.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName
ORDER BY TotalDoctors DESC;

-- Medium 5: Display departments together with the number of nurses.
SELECT dept.DepartmentID, dept.DepartmentName, COUNT(n.NurseID) AS TotalNurses
FROM Department dept
LEFT JOIN Nurse n ON dept.DepartmentID = n.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName
ORDER BY TotalNurses DESC;

-- Hard 6: Find the department with the highest number of doctors.
SELECT dept.DepartmentID, dept.DepartmentName, COUNT(d.DoctorID) AS DoctorCount
FROM Department dept
JOIN Doctor d ON dept.DepartmentID = d.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName
HAVING COUNT(d.DoctorID) = (
    SELECT MAX(COUNT(DoctorID))
    FROM Doctor
    GROUP BY DepartmentID
);

-- Hard 7: Find doctors whose experience is above the average experience.
SELECT DoctorID, FirstName || ' ' || LastName AS DoctorName, Specialty, YearsOfExperience
FROM Doctor
WHERE YearsOfExperience > (
    SELECT AVG(YearsOfExperience)
    FROM Doctor
)
ORDER BY YearsOfExperience DESC;
