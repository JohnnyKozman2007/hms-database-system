-- [NEGATIVE] Discount < 0 (chk_inv_disc)
UPDATE Invoice SET Discount = -10 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_DISC) violated.
