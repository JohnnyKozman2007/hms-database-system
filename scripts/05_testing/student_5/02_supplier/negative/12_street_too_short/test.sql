-- [NEGATIVE] Street < 3 chars (chk_supp_street_len)
UPDATE Supplier SET Street = 'AB' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_STREET_LEN) violated.
