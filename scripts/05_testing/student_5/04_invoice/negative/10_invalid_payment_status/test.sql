-- [NEGATIVE] Invalid PaymentStatus (chk_inv_status; INSERT hits CHECK directly)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_ST1', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Cancelled');
-- Expected: ORA-02290: check constraint (CHK_INV_STATUS) violated.
