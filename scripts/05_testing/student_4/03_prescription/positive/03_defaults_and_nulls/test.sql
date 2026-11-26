-- [POSITIVE - Defaults & NULLs] Omit QuantityPrescribed (1), DispenseStatus ('Pending'), PrescriptionDate (SYSDATE); Notes = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, Notes)
    VALUES ('RX_DEF_01', 'PAT003', 'DOC003', 'MED002', '500mg', 'Twice daily', 7, NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with defaults applied.
