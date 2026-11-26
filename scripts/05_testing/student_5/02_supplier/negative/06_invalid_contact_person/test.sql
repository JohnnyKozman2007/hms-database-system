-- [NEGATIVE] ContactPerson with digits or < 3 chars (chk_supp_contact_fmt)
UPDATE Supplier SET ContactPerson = 'Ali123' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_CONTACT_FMT) violated.
