-- [NEGATIVE] Invalid PostalCode characters (chk_supp_postal)
UPDATE Supplier SET PostalCode = '115@1' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_POSTAL) violated.
