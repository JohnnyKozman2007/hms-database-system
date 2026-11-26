-- [NEGATIVE] InvoiceDate < 2020-01-01 (chk_inv_date_lower)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, DueDate, PaymentStatus)
VALUES ('INV_DT1', 'PAT001', DATE '2019-12-31', 500.00, DATE '2020-01-01', 'Overdue');
-- Expected: ORA-02290: check constraint (CHK_INV_DATE_LOWER) violated.
