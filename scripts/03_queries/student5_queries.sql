-- STUDENT 5: Finance and Insurance Management Queries
-- Assigned Entities: Invoice, Payment, Supplier, Insurance

-- Easy 1. Display all invoices.
SELECT
    InvoiceID,
    PatientID,
    InvoiceDate,
    TotalAmount,
    TaxAmount,
    Discount,
    NetAmount,
    DueDate,
    PaymentStatus
FROM Invoice
ORDER BY InvoiceDate DESC, InvoiceID;

-- Easy 2. Display all suppliers.
SELECT
    SupplierID,
    CompanyName,
    ContactPerson,
    Phone,
    PhoneType,
    Email,
    Address,
    ContractStatus
FROM Supplier
ORDER BY SupplierID;

-- Medium:
-- 3. Display invoices together with patient information.
-- TODO: Write Query 3 here

-- 4. Display invoices together with their payments.
-- TODO: Write Query 4 here

-- 5. Calculate the total amount paid for each invoice.
-- TODO: Write Query 5 here

-- Hard:
-- 6. Find patients who have outstanding invoice balances.
-- TODO: Write Query 6 here

-- 7. Find the supplier that provides the highest number of medications.
-- TODO: Write Query 7 here
