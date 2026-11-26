-- [NEGATIVE] Invalid InvoiceID format (chk_inv_id)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV@1', 'PAT001', 500.00);
-- Expected: ORA-02290: check constraint (CHK_INV_ID) violated.
