-- [NEGATIVE] CompanyName < 2 chars (chk_supp_company_len)
UPDATE Supplier SET CompanyName = 'A' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_COMPANY_LEN) violated.
