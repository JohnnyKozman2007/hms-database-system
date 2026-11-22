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

-- Medium 3. Display invoices together with patient information.
SELECT
    i.InvoiceID,
    i.InvoiceDate,
    i.DueDate,
    i.TotalAmount,
    i.TaxAmount,
    i.Discount,
    i.NetAmount,
    i.PaymentStatus,
    p.PatientID,
    p.FullName AS PatientName,
    p.Phone,
    p.Email
FROM Invoice i
JOIN Patient p
    ON i.PatientID = p.PatientID
ORDER BY i.InvoiceDate DESC, i.InvoiceID;

-- Medium 4. Display invoices together with their payments.
SELECT
    i.InvoiceID,
    i.PatientID,
    i.InvoiceDate,
    i.NetAmount,
    i.PaymentStatus AS InvoiceStatus,
    p.PaymentID,
    p.PaymentDate,
    p.AmountPaid,
    p.PaymentMethod,
    p.TransactionReference,
    p.PaymentStatus AS PaymentStatus
FROM Invoice i
LEFT JOIN Payment p
    ON i.InvoiceID = p.InvoiceID
ORDER BY i.InvoiceID, p.PaymentDate;

-- Medium 5. Calculate the total amount paid for each invoice.
SELECT
    i.InvoiceID,
    i.PatientID,
    i.InvoiceDate,
    i.NetAmount,
    NVL(SUM(p.AmountPaid), 0) AS TotalPaid,
    i.NetAmount - NVL(SUM(p.AmountPaid), 0) AS RemainingBalance,
    i.PaymentStatus
FROM Invoice i
LEFT JOIN Payment p
    ON i.InvoiceID = p.InvoiceID
   AND p.PaymentStatus = 'Completed'
GROUP BY i.InvoiceID, i.PatientID, i.InvoiceDate, i.NetAmount, i.PaymentStatus
ORDER BY i.InvoiceID;

-- Hard:
-- 6. Find patients who have outstanding invoice balances.
-- TODO: Write Query 6 here

-- 7. Find the supplier that provides the highest number of medications.
-- TODO: Write Query 7 here
