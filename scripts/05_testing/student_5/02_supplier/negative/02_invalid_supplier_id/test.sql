-- [NEGATIVE] Invalid SupplierID format (chk_supp_id)
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Street, City, PostalCode)
VALUES ('SUP@1', 'Bad ID Co', 'Ali Hassan', '0224189902', 'bad.id@hms.eg', 'Street 1', 'Cairo', '11511');
-- Expected: ORA-02290: check constraint (CHK_SUPP_ID) violated.
