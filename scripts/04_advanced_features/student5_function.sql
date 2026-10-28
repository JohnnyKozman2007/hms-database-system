-- ============================================================================
-- ADVANCED FEATURE: Student 5 (FUNCTION)
-- Function: fn_get_patient_outstanding_balance
-- Purpose: Calculates the net unpaid balance for a given patient across all invoices
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_get_patient_outstanding_balance (
    p_patient_id IN NUMBER
) RETURN NUMBER IS
    v_total_invoiced NUMBER(10,2) := 0;
    v_total_paid     NUMBER(10,2) := 0;
BEGIN
    -- Sum of all invoices for patient
    SELECT NVL(SUM(TotalAmount), 0)
    INTO v_total_invoiced
    FROM Invoice
    WHERE PatientID = p_patient_id;

    -- Sum of all payments linked to patient's invoices
    SELECT NVL(SUM(p.AmountPaid), 0)
    INTO v_total_paid
    FROM Payment p
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    WHERE i.PatientID = p_patient_id
      AND p.PaymentStatus = 'Completed';

    RETURN (v_total_invoiced - v_total_paid);
END;
/
