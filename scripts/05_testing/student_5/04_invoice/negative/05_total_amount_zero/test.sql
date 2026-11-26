-- [NEGATIVE] TotalAmount <= 0 (chk_inv_total)
UPDATE Invoice SET TotalAmount = 0 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_TOTAL) violated.
