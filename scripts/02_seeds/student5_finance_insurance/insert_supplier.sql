-- ============================================================================
-- SEED DATA: Supplier (Student 5)
-- Target: Minimum 15 suppliers
-- ID Range: 1 to 15
-- ============================================================================

INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Address, ContractStatus)
VALUES (1, 'PharmaCare UK Ltd', 'Arthur Pendelton', '+44-2079-460010', 'orders@pharmacare.co.uk', '12 Industrial Way, London', 'Active');

INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Address, ContractStatus)
VALUES (2, 'BioMed Supplies', 'Rachel Green', '+44-2079-460020', 'sales@biomedsupplies.co.uk', '45 Logistics Park, Milton Keynes', 'Active');

-- Add remaining suppliers (3 to 15) following this exact pattern.
COMMIT;
