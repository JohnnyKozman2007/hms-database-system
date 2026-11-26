-- [NEGATIVE] Non-existent PatientID (fk_inv_patient)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV_FK1', 'PAT999', 500.00);
-- Expected: ORA-02291: integrity constraint (FK_INV_PATIENT) violated.
