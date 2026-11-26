-- [NEGATIVE] Duplicate Email (uq_supp_email)
UPDATE Supplier SET Email = 'supply@eipico.eg' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_EMAIL) violated.
