-- [NEGATIVE] City with digits or < 2 chars (chk_supp_city_fmt)
UPDATE Supplier SET City = 'Cairo1' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_CITY_FMT) violated.
