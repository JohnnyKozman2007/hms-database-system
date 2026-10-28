-- ============================================================================
-- STUDENT 5: Finance and Insurance Management Queries
-- Assigned Entities: Invoice, Payment, Supplier, Insurance
-- ============================================================================

-- Easy 1: Display all invoices.
SELECT InvoiceID, PatientID, InvoiceDate, TotalAmount, TaxAmount, Discount, DueDate, PaymentStatus
FROM Invoice
ORDER BY InvoiceDate DESC;

-- Easy 2: Display all suppliers.
SELECT SupplierID, CompanyName, ContactPerson, Phone, Email, Address, ContractStatus
FROM Supplier
ORDER BY CompanyName;

-- Medium 3: Display invoices together with patient information.
SELECT inv.InvoiceID, inv.InvoiceDate, inv.TotalAmount, inv.TaxAmount, inv.Discount, inv.DueDate, inv.PaymentStatus,
       p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName, p.Phone, p.Email
FROM Invoice inv
JOIN Patient p ON inv.PatientID = p.PatientID
ORDER BY inv.InvoiceDate DESC;

-- Medium 4: Display invoices together with their payments.
SELECT inv.InvoiceID, inv.InvoiceDate, inv.TotalAmount, inv.PaymentStatus AS InvoiceStatus,
       pay.PaymentID, pay.PaymentDate, pay.AmountPaid, pay.PaymentMethod, pay.TransactionReference
FROM Invoice inv
JOIN Payment pay ON inv.InvoiceID = pay.InvoiceID
ORDER BY inv.InvoiceID, pay.PaymentDate;

-- Medium 5: Calculate the total amount paid for each invoice.
SELECT inv.InvoiceID, inv.TotalAmount, NVL(SUM(pay.AmountPaid), 0) AS TotalAmountPaid,
       (inv.TotalAmount - NVL(SUM(pay.AmountPaid), 0)) AS RemainingBalance
FROM Invoice inv
LEFT JOIN Payment pay ON inv.InvoiceID = pay.InvoiceID
GROUP BY inv.InvoiceID, inv.TotalAmount
ORDER BY inv.InvoiceID;

-- Hard 6: Find patients who have outstanding invoice balances.
SELECT p.PatientID, p.FirstName || ' ' || p.LastName AS PatientName, p.Phone,
       inv.InvoiceID, inv.TotalAmount, NVL(SUM(pay.AmountPaid), 0) AS AmountPaid,
       (inv.TotalAmount - NVL(SUM(pay.AmountPaid), 0)) AS OutstandingBalance
FROM Patient p
JOIN Invoice inv ON p.PatientID = inv.PatientID
LEFT JOIN Payment pay ON inv.InvoiceID = pay.InvoiceID
GROUP BY p.PatientID, p.FirstName, p.LastName, p.Phone, inv.InvoiceID, inv.TotalAmount
HAVING (inv.TotalAmount - NVL(SUM(pay.AmountPaid), 0)) > 0
ORDER BY OutstandingBalance DESC;

-- Hard 7: Find the supplier that provides the highest number of medications.
SELECT s.SupplierID, s.CompanyName, s.ContactPerson, s.Phone, COUNT(m.MedicationID) AS MedicationCount
FROM Supplier s
JOIN Medication m ON s.SupplierID = m.SupplierID
GROUP BY s.SupplierID, s.CompanyName, s.ContactPerson, s.Phone
HAVING COUNT(m.MedicationID) = (
    SELECT MAX(COUNT(MedicationID))
    FROM Medication
    GROUP BY SupplierID
);
