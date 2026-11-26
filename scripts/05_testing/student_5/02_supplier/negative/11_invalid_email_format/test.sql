-- [NEGATIVE] Invalid Email format (chk_supp_email_fmt)
UPDATE Supplier SET Email = 'bad-email' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_EMAIL_FMT) violated.
