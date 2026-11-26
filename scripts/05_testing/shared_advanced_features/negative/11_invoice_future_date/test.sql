-- [NEGATIVE] Future Invoice.InvoiceDate (trg_inv_date_max)
UPDATE Invoice SET InvoiceDate = SYSDATE + 1 WHERE InvoiceID = 'INV001';
-- Expected: ORA-20001: Invoice.InvoiceDate cannot be in the future (exceeds SYSDATE).
