-- ============================================================================
-- ADVANCED FEATURE: Student 4 (TRIGGER)
-- Trigger: trg_decrement_med_stock
-- Purpose: Automatically reduces medication stock when a prescription is issued
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_decrement_med_stock
BEFORE INSERT ON Prescription
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT QuantityInStock
    INTO v_stock
    FROM Medication
    WHERE MedicationID = :NEW.MedicationID;

    IF v_stock < 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient medication stock to fulfill this prescription.');
    ELSE
        UPDATE Medication
        SET QuantityInStock = QuantityInStock - 1
        WHERE MedicationID = :NEW.MedicationID;
    END IF;
END;
/
