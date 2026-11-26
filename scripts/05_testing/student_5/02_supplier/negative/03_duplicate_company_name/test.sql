-- [NEGATIVE] Duplicate CompanyName (uq_supp_name)
UPDATE Supplier SET CompanyName = 'EIPICO Medical Supplies' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_NAME) violated.
