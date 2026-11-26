-- [NEGATIVE] NULL CompanyName
UPDATE Supplier SET CompanyName = NULL WHERE SupplierID = 'SUP001';
-- Expected: ORA-01407: cannot update (SUPPLIER.COMPANYNAME) to NULL.
