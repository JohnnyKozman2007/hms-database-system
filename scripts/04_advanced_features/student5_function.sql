CREATE OR REPLACE FUNCTION fn_get_patient_net_balance (
    p_patient_id IN VARCHAR2
) RETURN NUMBER IS
    v_patient_exists NUMBER := 0;
    v_total_billed   NUMBER(12, 2) := 0;
    v_total_paid     NUMBER(12, 2) := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20040, 'Patient ID ' || p_patient_id || ' does not exist.');
    END IF;

    SELECT NVL(SUM(NetAmount), 0)
    INTO v_total_billed
    FROM Invoice
    WHERE PatientID = p_patient_id;

    SELECT NVL(SUM(p.AmountPaid), 0)
    INTO v_total_paid
    FROM Payment p
    JOIN Invoice i ON p.InvoiceID = i.InvoiceID
    WHERE i.PatientID = p_patient_id
      AND p.PaymentStatus = 'Completed';

    RETURN ROUND(v_total_billed - v_total_paid, 2);
END fn_get_patient_net_balance;
/

CREATE OR REPLACE FUNCTION fn_get_invoice_patient_copay (
    p_invoice_id IN VARCHAR2
) RETURN NUMBER IS
    v_patient_id   VARCHAR2(10);
    v_net_amount   NUMBER(12, 2);
    v_coverage_pct NUMBER(5, 2) := 0;
BEGIN
    SELECT PatientID, NetAmount
    INTO v_patient_id, v_net_amount
    FROM Invoice
    WHERE InvoiceID = p_invoice_id;

    SELECT NVL(MAX(CoveragePercentage), 0)
    INTO v_coverage_pct
    FROM Insurance
    WHERE PatientID = v_patient_id
      AND InsuranceStatus = 'Active'
      AND ExpirationDate >= SYSDATE;

    RETURN ROUND(v_net_amount * (1 - (v_coverage_pct / 100)), 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20041, 'Invoice ID ' || p_invoice_id || ' does not exist.');
END fn_get_invoice_patient_copay;
/

CREATE OR REPLACE FUNCTION fn_get_patient_financial_status (
    p_patient_id IN VARCHAR2
) RETURN VARCHAR2 IS
    v_base_balance  NUMBER(12, 2) := 0;
    v_late_Penalty  NUMBER(12, 2) := 0;
    v_total_owed    NUMBER(12, 2) := 0;
    v_overdue_count NUMBER := 0;
    v_max_weeks     NUMBER := 0;
BEGIN
    v_base_balance := fn_get_patient_net_balance(p_patient_id);

    SELECT
        COUNT(*),
        NVL(MAX(FLOOR((SYSDATE - i.DueDate) / 7)), 0),
        NVL(SUM(
            (i.NetAmount - NVL((
                SELECT SUM(p.AmountPaid)
                FROM Payment p
                WHERE p.InvoiceID = i.InvoiceID
                  AND p.PaymentStatus = 'Completed'
            ), 0)) * (0.10 * GREATEST(FLOOR((SYSDATE - i.DueDate) / 7), 0))
        ), 0)
    INTO v_overdue_count, v_max_weeks, v_late_penalty
    FROM Invoice i
    WHERE i.PatientID = p_patient_id
      AND i.PaymentStatus <> 'Paid'
      AND i.DueDate < SYSDATE;

    v_total_owed := ROUND(v_base_balance + v_late_penalty, 2);

    IF v_total_owed <= 0 THEN
        RETURN 'CLEAR (Balance: 0.00)';
    ELSIF v_overdue_count > 0 AND v_max_weeks >= 1 THEN
        RETURN 'BANNED - OVERDUE ' || v_max_weeks || ' WEEK(S) (Base: ' || v_base_balance ||
               ', +10%/wk Penalty: ' || ROUND(v_late_penalty, 2) || ', Total Owed: ' || v_total_owed || ')';
    ELSIF v_overdue_count > 0 THEN
        RETURN 'WARNING - PAST DUE <1 WEEK (Total Owed: ' || v_total_owed || ')';
    ELSE
        RETURN 'ACTIVE TAB - NOT YET DUE (Total Owed: ' || v_total_owed || ')';
    END IF;
END fn_get_patient_financial_status;
/
