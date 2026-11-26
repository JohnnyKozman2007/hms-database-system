-- [NEGATIVE] Duplicate Phone (uq_supp_phone)
UPDATE Supplier SET Phone = '0224180002' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_PHONE) violated.
