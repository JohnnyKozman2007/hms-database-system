-- [NEGATIVE] DueDate < InvoiceDate (chk_inv_dates)
UPDATE Invoice SET DueDate = InvoiceDate - 1 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_DATES) violated.
