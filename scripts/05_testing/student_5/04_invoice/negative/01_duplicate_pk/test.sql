-- [NEGATIVE] Duplicate InvoiceID (pk_invoice)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV001', 'PAT001', 500.00);
-- Expected: ORA-00001: unique constraint (PK_INVOICE) violated.
