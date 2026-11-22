-- STUDENT 4: Pharmacy and Laboratory Management Queries
-- Assigned Entities: Medication, Prescription, LaboratoryTest

-- Easy 1. Display all medications.
SELECT
    MedicationID,
    MedicationName,
    Manufacturer,
    Category,
    DosageForm,
    UnitPrice,
    QuantityInStock,
    ImportDate,
    ExpirationDate,
    SupplierID
FROM Medication
ORDER BY MedicationID;

-- Easy 2. Display all laboratory tests with their status.
SELECT
    TestID,
    PatientID,
    DoctorID,
    TestType,
    RequestedDate,
    CompletedDate,
    TestStatus,
    TestResult,
    TestCost
FROM LaboratoryTest
ORDER BY RequestedDate DESC, TestID;

-- Medium 3. Display prescriptions with patient, doctor, and medication names.
SELECT
    rx.PrescriptionID,
    rx.PrescriptionDate,
    rx.PrescriptionTime,
    rx.EndDate,
    p.PatientID,
    p.FullName AS PatientName,
    d.DoctorID,
    d.FullName AS DoctorName,
    m.MedicationID,
    m.MedicationName,
    rx.Dosage,
    rx.Frequency,
    rx.Duration,
    rx.QuantityPrescribed,
    rx.DispenseStatus,
    (rx.QuantityPrescribed * m.UnitPrice) AS TotalMedicationCost
FROM Prescription rx
JOIN Patient p
    ON rx.PatientID = p.PatientID
JOIN Doctor d
    ON rx.DoctorID = d.DoctorID
JOIN Medication m
    ON rx.MedicationID = m.MedicationID
ORDER BY rx.PrescriptionDate DESC, rx.PrescriptionID;

-- Medium 4. Display laboratory tests with patient and doctor information.
SELECT
    lt.TestID,
    lt.TestType,
    lt.RequestedDate,
    lt.CompletedDate,
    lt.TestStatus,
    lt.TestResult,
    lt.TestCost,
    p.PatientID,
    p.FullName AS PatientName,
    p.BloodType,
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty
FROM LaboratoryTest lt
JOIN Patient p
    ON lt.PatientID = p.PatientID
JOIN Doctor d
    ON lt.DoctorID = d.DoctorID
ORDER BY lt.RequestedDate DESC, lt.TestID;

-- Medium 5. Count prescriptions for each medication.
SELECT
    m.MedicationID,
    m.MedicationName,
    m.Category,
    m.DosageForm,
    COUNT(rx.PrescriptionID) AS PrescriptionCount,
    NVL(SUM(rx.QuantityPrescribed), 0) AS TotalUnitsPrescribed
FROM Medication m
LEFT JOIN Prescription rx
    ON m.MedicationID = rx.MedicationID
GROUP BY m.MedicationID, m.MedicationName, m.Category, m.DosageForm
ORDER BY PrescriptionCount DESC, m.MedicationID;

-- Hard 6. Find the most frequently prescribed medication.
SELECT
    m.MedicationID,
    m.MedicationName,
    m.Category,
    COUNT(rx.PrescriptionID) AS PrescriptionCount
FROM Medication m
JOIN Prescription rx
    ON m.MedicationID = rx.MedicationID
GROUP BY m.MedicationID, m.MedicationName, m.Category
HAVING COUNT(rx.PrescriptionID) = (
    SELECT MAX(COUNT(PrescriptionID))
    FROM Prescription
    GROUP BY MedicationID
);

-- Hard 7. Find patients who have received more than five prescriptions.
SELECT
    p.PatientID,
    p.FullName AS PatientName,
    p.Phone,
    COUNT(rx.PrescriptionID) AS PrescriptionCount
FROM Patient p
JOIN Prescription rx
    ON p.PatientID = rx.PatientID
GROUP BY p.PatientID, p.FullName, p.Phone
HAVING COUNT(rx.PrescriptionID) > 5
ORDER BY PrescriptionCount DESC, p.PatientID;
