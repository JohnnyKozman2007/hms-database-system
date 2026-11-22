CREATE OR REPLACE TRIGGER trg_ins_status_date_guard
BEFORE INSERT OR UPDATE OF ExpirationDate, InsuranceStatus ON Insurance
FOR EACH ROW
BEGIN
    IF :NEW.ExpirationDate < SYSDATE AND :NEW.InsuranceStatus = 'Active' THEN
        RAISE_APPLICATION_ERROR(-20005, 'Cannot set InsuranceStatus to Active when ExpirationDate is in the past; must be Expired.');
    ELSIF :NEW.ExpirationDate >= SYSDATE AND :NEW.InsuranceStatus = 'Expired' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Cannot set InsuranceStatus to Expired when ExpirationDate has not passed yet.');
    END IF;
END trg_ins_status_date_guard;
/

CREATE OR REPLACE TRIGGER trg_inv_status_guard
BEFORE INSERT OR UPDATE ON Invoice
FOR EACH ROW
DECLARE
    v_total_paid      NUMBER(12, 2) := 0;
    v_expected_status VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        IF :NEW.PaymentStatus IN ('Paid', 'Partially Paid') THEN
            RAISE_APPLICATION_ERROR(-20007, 'New invoices cannot be inserted directly as Paid or Partially Paid; insert as Unpaid/Overdue and add rows to Payment.');
        ELSIF :NEW.DueDate < SYSDATE AND :NEW.PaymentStatus = 'Unpaid' THEN
            RAISE_APPLICATION_ERROR(-20008, 'Cannot insert Invoice as Unpaid when DueDate is already in the past; must be Overdue.');
        ELSIF :NEW.DueDate >= SYSDATE AND :NEW.PaymentStatus = 'Overdue' THEN
            RAISE_APPLICATION_ERROR(-20009, 'Cannot insert Invoice as Overdue when DueDate has not passed yet; must be Unpaid.');
        END IF;
    ELSIF UPDATING THEN
        SELECT NVL(SUM(AmountPaid), 0)
        INTO v_total_paid
        FROM Payment
        WHERE InvoiceID = :NEW.InvoiceID
          AND PaymentStatus = 'Completed';

        IF v_total_paid > :NEW.NetAmount THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invoice NetAmount cannot be reduced below already-completed payments (' || v_total_paid || ').');
        END IF;

        IF v_total_paid >= :NEW.NetAmount THEN
            v_expected_status := 'Paid';
        ELSIF v_total_paid > 0 THEN
            v_expected_status := 'Partially Paid';
        ELSIF :NEW.DueDate < SYSDATE THEN
            v_expected_status := 'Overdue';
        ELSE
            v_expected_status := 'Unpaid';
        END IF;

        IF UPDATING('PaymentStatus')
           AND NOT UPDATING('TotalAmount')
           AND NOT UPDATING('Discount')
           AND NOT UPDATING('DueDate') THEN
            IF :NEW.PaymentStatus <> v_expected_status THEN
                RAISE_APPLICATION_ERROR(-20007, 'Cannot manually set Invoice.PaymentStatus to ' || :NEW.PaymentStatus || '; expected status from Payment is ' || v_expected_status || '.');
            END IF;
        ELSE
            :NEW.PaymentStatus := v_expected_status;
        END IF;
    END IF;
END trg_inv_status_guard;
/

CREATE OR REPLACE TRIGGER trg_pay_check_insurance
BEFORE INSERT OR UPDATE OF PaymentMethod, InvoiceID ON Payment
FOR EACH ROW
WHEN (NEW.PaymentMethod = 'Insurance Claim')
DECLARE
    v_active_ins NUMBER := 0;
BEGIN
    UPDATE Insurance
    SET InsuranceStatus = 'Expired'
    WHERE InsuranceStatus = 'Active'
      AND ExpirationDate < SYSDATE;

    SELECT COUNT(*)
    INTO v_active_ins
    FROM Invoice inv
    JOIN Insurance ins ON inv.PatientID = ins.PatientID
    WHERE inv.InvoiceID = :NEW.InvoiceID
      AND ins.InsuranceStatus = 'Active'
      AND ins.ExpirationDate >= SYSDATE;

    IF v_active_ins = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Insurance Claim payment rejected: Patient has no active, unexpired insurance policy.');
    END IF;
END trg_pay_check_insurance;
/

CREATE OR REPLACE TRIGGER trg_pay_balance_and_status
FOR INSERT OR UPDATE OR DELETE ON Payment
COMPOUND TRIGGER
    TYPE t_inv_map IS TABLE OF BOOLEAN INDEX BY VARCHAR2(10);
    g_affected_invoices t_inv_map;

    BEFORE EACH ROW IS
        v_inv_date DATE;
    BEGIN
        IF INSERTING OR UPDATING THEN
            BEGIN
                SELECT InvoiceDate
                INTO v_inv_date
                FROM Invoice
                WHERE InvoiceID = :NEW.InvoiceID;

                IF :NEW.PaymentDate < v_inv_date THEN
                    RAISE_APPLICATION_ERROR(-20004, 'PaymentDate cannot be earlier than Invoice.InvoiceDate for Invoice ' || :NEW.InvoiceID || '.');
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
            END;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            g_affected_invoices(:NEW.InvoiceID) := TRUE;
        END IF;
        IF UPDATING OR DELETING THEN
            g_affected_invoices(:OLD.InvoiceID) := TRUE;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_inv_id     VARCHAR2(10);
        v_net_amount NUMBER(12, 2);
        v_due_date   DATE;
        v_total_paid NUMBER(12, 2);
        v_new_status VARCHAR2(20);
    BEGIN
        UPDATE Insurance
        SET InsuranceStatus = 'Expired'
        WHERE InsuranceStatus = 'Active'
          AND ExpirationDate < SYSDATE;

        UPDATE Invoice
        SET PaymentStatus = 'Overdue'
        WHERE PaymentStatus = 'Unpaid'
          AND DueDate < SYSDATE;

        v_inv_id := g_affected_invoices.FIRST;
        WHILE v_inv_id IS NOT NULL LOOP
            SELECT NetAmount, DueDate
            INTO v_net_amount, v_due_date
            FROM Invoice
            WHERE InvoiceID = v_inv_id;

            SELECT NVL(SUM(AmountPaid), 0)
            INTO v_total_paid
            FROM Payment
            WHERE InvoiceID = v_inv_id
              AND PaymentStatus = 'Completed';

            IF v_total_paid > v_net_amount THEN
                RAISE_APPLICATION_ERROR(-20002, 'Payment exceeds remaining invoice balance for Invoice ' || v_inv_id || '.');
            END IF;

            IF v_total_paid >= v_net_amount THEN
                v_new_status := 'Paid';
            ELSIF v_total_paid > 0 THEN
                v_new_status := 'Partially Paid';
            ELSIF v_due_date < SYSDATE THEN
                v_new_status := 'Overdue';
            ELSE
                v_new_status := 'Unpaid';
            END IF;

            UPDATE Invoice
            SET PaymentStatus = v_new_status
            WHERE InvoiceID = v_inv_id;

            v_inv_id := g_affected_invoices.NEXT(v_inv_id);
        END LOOP;
        g_affected_invoices.DELETE;
    END AFTER STATEMENT;
END trg_pay_balance_and_status;
/
