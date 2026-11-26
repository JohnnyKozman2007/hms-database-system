-- [NEGATIVE] Duplicate SupplierID (pk_supplier)
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Street, City, PostalCode)
VALUES ('SUP001', 'Dup Supplier', 'Ali Hassan', '0224189901', 'dup.sup@hms.eg', 'Street 1', 'Cairo', '11511');
-- Expected: ORA-00001: unique constraint (PK_SUPPLIER) violated.
