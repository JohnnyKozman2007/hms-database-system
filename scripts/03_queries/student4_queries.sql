-- ============================================================================
-- STUDENT 4: Pharmacy and Laboratory Management Queries
-- Assigned Entities: Medication, Prescription, LaboratoryTest
-- ============================================================================

-- Easy 1: Display all medications.
SELECT MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate
FROM Medication
ORDER BY MedicationName;

-- Easy 2: Display all laboratory tests with their status.
SELECT TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestCost
FROM LaboratoryTest
ORDER BY RequestedDate DESC;

-- Medium 3: Display prescriptions with patient, doctor, and medication names.
SELECT pr.PrescriptionID, pr.PrescriptionDate, pr.Dosage, pr.Frequency, pr.Duration,
       p.FirstName || ' ' || p.LastName AS PatientName,
       d.FirstName || ' ' || d.LastName AS DoctorName,
       m.MedicationName, m.DosageForm
FROM Prescription pr
JOIN Patient p ON pr.PatientID = p.PatientID
JOIN Doctor d ON pr.DoctorID = d.DoctorID
JOIN Medication m ON pr.MedicationID = m.MedicationID
ORDER BY pr.PrescriptionDate DESC;

-- Medium 4: Display laboratory tests with patient and doctor information.
SELECT lt.TestID, lt.TestType, lt.RequestedDate, lt.CompletedDate, lt.TestStatus, lt.TestResult, lt.TestCost,
       p.FirstName || ' ' || p.LastName AS PatientName,
       d.FirstName || ' ' || d.LastName AS DoctorName, d.Specialty
FROM LaboratoryTest lt
JOIN Patient p ON lt.PatientID = p.PatientID
JOIN Doctor d ON lt.DoctorID = d.DoctorID
ORDER BY lt.RequestedDate DESC;

-- Medium 5: Count prescriptions for each medication.
SELECT m.MedicationID, m.MedicationName, m.Category, COUNT(pr.PrescriptionID) AS TimesPrescribed
FROM Medication m
LEFT JOIN Prescription pr ON m.MedicationID = pr.MedicationID
GROUP BY m.MedicationID, m.MedicationName, m.Category
ORDER BY TimesPrescribed DESC;

-- Hard 6: Find the most frequently prescribed medication.
SELECT m.MedicationID, m.MedicationName, m.Manufacturer, COUNT(pr.PrescriptionID) AS TotalPrescriptions
FROM Medication m
JOIN Prescription pr ON m.MedicationID = pr.MedicationID
GROUP BY m.MedicationID, m.MedicationName, m.Manufacturer
HAVING COUNT(pr.PrescriptionID) = (
    SELECT MAX(COUNT(PrescriptionID))
    FROM Prescription
    GROUP BY MedicationID
);

-- Hard 7: Find patients who have received more than five prescriptions.
SELECT p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName, p.Phone, COUNT(pr.PrescriptionID) AS PrescriptionCount
FROM Patient p
JOIN Prescription pr ON p.PatientID = pr.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName, p.Phone
HAVING COUNT(pr.PrescriptionID) > 5
ORDER BY PrescriptionCount DESC;
