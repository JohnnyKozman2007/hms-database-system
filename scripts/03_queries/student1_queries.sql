-- STUDENT 1: Department and Staff Management Queries
-- Assigned Entities: Department, Doctor, Nurse

-- Easy 1. Display all doctors.
SELECT
    DoctorID,
    FullName,
    Gender,
    Specialty,
    Phone,
    PhoneType,
    Email,
    HireDate,
    YearsOfExperience,
    DepartmentID,
    SupervisorID
FROM Doctor
ORDER BY DoctorID;

-- Easy 2. Display all departments located in a specified location.
SELECT
    DepartmentID,
    DepartmentName,
    Building,
    FloorLevel,
    Location,
    Phone,
    DepartmentDescription
FROM Department
WHERE Building = 'Building A'
ORDER BY FloorLevel, DepartmentName;

-- Medium 3. Display doctors together with their department names.
SELECT
    doc.DoctorID,
    doc.FullName AS DoctorName,
    doc.Specialty,
    doc.YearsOfExperience,
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location
FROM Doctor doc
JOIN Department dept
    ON doc.DepartmentID = dept.DepartmentID
ORDER BY dept.DepartmentName, doc.FullName;

-- Medium 4. Count the number of doctors in each department.
SELECT
    dept.DepartmentID,
    dept.DepartmentName,
    COUNT(doc.DoctorID) AS DoctorCount
FROM Department dept
LEFT JOIN Doctor doc
    ON dept.DepartmentID = doc.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName
ORDER BY DoctorCount DESC, dept.DepartmentName;

-- Medium 5. Display departments together with the number of nurses.
SELECT
    dept.DepartmentID,
    dept.DepartmentName,
    dept.Location,
    COUNT(n.NurseID) AS NurseCount
FROM Department dept
LEFT JOIN Nurse n
    ON dept.DepartmentID = n.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName, dept.Location
ORDER BY NurseCount DESC, dept.DepartmentName;

-- Hard 6. Find the department with the highest number of doctors.
SELECT
    dept.DepartmentID,
    dept.DepartmentName,
    COUNT(doc.DoctorID) AS DoctorCount
FROM Department dept
JOIN Doctor doc
    ON dept.DepartmentID = doc.DepartmentID
GROUP BY dept.DepartmentID, dept.DepartmentName
HAVING COUNT(doc.DoctorID) = (
    SELECT MAX(COUNT(DoctorID))
    FROM Doctor
    GROUP BY DepartmentID
);

-- Hard 7. Find doctors whose experience is above the average experience.
SELECT
    doc.DoctorID,
    doc.FullName AS DoctorName,
    doc.Specialty,
    doc.YearsOfExperience,
    (SELECT ROUND(AVG(YearsOfExperience), 2) FROM Doctor) AS AvgExperience
FROM Doctor doc
WHERE doc.YearsOfExperience > (
    SELECT AVG(YearsOfExperience)
    FROM Doctor
)
ORDER BY doc.YearsOfExperience DESC, doc.DoctorID;
