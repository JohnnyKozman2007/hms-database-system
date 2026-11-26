-- [NEGATIVE] Discount > TotalAmount (chk_inv_disc; INSERT hits CHECK directly)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_DSC1', 'PAT001', TRUNC(SYSDATE), 500.00, 600.00, TRUNC(SYSDATE) + 3, 'Unpaid');
-- Expected: ORA-02290: check constraint (CHK_INV_DISC) violated.
