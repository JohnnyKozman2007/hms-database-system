CREATE OR REPLACE TRIGGER trg_rx_manage_medication_stock
BEFORE INSERT OR UPDATE OF DispenseStatus, QuantityPrescribed, MedicationID ON Prescription
FOR EACH ROW
DECLARE
    v_stock    NUMBER(6);
    v_exp_date DATE;
BEGIN
    IF INSERTING THEN
        IF :NEW.DispenseStatus = 'Dispensed' THEN
            SELECT QuantityInStock, ExpirationDate
            INTO v_stock, v_exp_date
            FROM Medication
            WHERE MedicationID = :NEW.MedicationID
            FOR UPDATE;

            IF v_exp_date < SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
            END IF;

            IF v_stock < :NEW.QuantityPrescribed THEN
                RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
            END IF;

            UPDATE Medication
            SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
            WHERE MedicationID = :NEW.MedicationID;
        END IF;

    ELSIF UPDATING THEN
        IF :OLD.DispenseStatus = 'Dispensed' AND :NEW.DispenseStatus <> 'Dispensed' THEN
            UPDATE Medication
            SET QuantityInStock = QuantityInStock + :OLD.QuantityPrescribed
            WHERE MedicationID = :OLD.MedicationID;

        ELSIF :OLD.DispenseStatus <> 'Dispensed' AND :NEW.DispenseStatus = 'Dispensed' THEN
            SELECT QuantityInStock, ExpirationDate
            INTO v_stock, v_exp_date
            FROM Medication
            WHERE MedicationID = :NEW.MedicationID
            FOR UPDATE;

            IF v_exp_date < SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
            END IF;

            IF v_stock < :NEW.QuantityPrescribed THEN
                RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
            END IF;

            UPDATE Medication
            SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
            WHERE MedicationID = :NEW.MedicationID;

        ELSIF :OLD.DispenseStatus = 'Dispensed' AND :NEW.DispenseStatus = 'Dispensed' THEN
            IF :OLD.MedicationID <> :NEW.MedicationID OR :OLD.QuantityPrescribed <> :NEW.QuantityPrescribed THEN
                UPDATE Medication
                SET QuantityInStock = QuantityInStock + :OLD.QuantityPrescribed
                WHERE MedicationID = :OLD.MedicationID;

                SELECT QuantityInStock, ExpirationDate
                INTO v_stock, v_exp_date
                FROM Medication
                WHERE MedicationID = :NEW.MedicationID
                FOR UPDATE;

                IF v_exp_date < SYSDATE THEN
                    RAISE_APPLICATION_ERROR(-20031, 'Cannot dispense Medication ' || :NEW.MedicationID || ': Batch is expired.');
                END IF;

                IF v_stock < :NEW.QuantityPrescribed THEN
                    RAISE_APPLICATION_ERROR(-20030, 'Insufficient stock for Medication ' || :NEW.MedicationID || ' (Available: ' || v_stock || ', Requested: ' || :NEW.QuantityPrescribed || ').');
                END IF;

                UPDATE Medication
                SET QuantityInStock = QuantityInStock - :NEW.QuantityPrescribed
                WHERE MedicationID = :NEW.MedicationID;
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- Let Oracle's declarative FK constraint raise ORA-02291
END trg_rx_manage_medication_stock;
/
