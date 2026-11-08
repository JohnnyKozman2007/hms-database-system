# HMS Database: Data Governance, Deletion Policy & 85%+ Strategy Guide
**Module:** Data Modeling for DB (4FTC2063)  
**Academic Year:** 2026/27  
**Project:** Hospital Management System (HMS)

---

## 1. Executive Summary
This document establishes the **Data Governance and Referential Integrity Policy** for the 16 core entities of the Hospital Management System (HMS), alongside strategic guidance for achieving **Outstanding Marks (85%+)** in the coursework report, SQL implementation, and final oral presentation.

---

## 2. Strategic Roadmap for 85%+ (First Class with Distinction)

When university examiners assess relational database systems for 85%+ marks, they reward **clinical domain depth, mathematical modeling precision, and data integrity** over superficial feature additions.

### A. The "Scope Creep" Trap: Why HR & Payroll Hurt Your Grade
* **Domain Mismatch:** Adding employee attendance clocking, salary calculations, and tax deductions changes the focus from a **Clinical Hospital Management System** to an **HR/Payroll System**. Examiners penalize this as "poor requirements scoping" and "loss of clinical domain focus."
* **Workload Imbalance:** The coursework briefing sheet explicitly requires an equal workload across the 5 students. Adding 3–4 HR tables creates unassigned entities and dilutes focus from core clinical queries.
* **Failure Points:** Complex shift clock-in/out logic introduces edge-case foreign key bugs with zero bonus marks on the marking rubric.

### B. What Actually Earns 85%+ on the Grading Rubric
Examiners award top marks for:
1. **Mathematical 3NF Rigor:** Explicit functional dependencies ($X \to Y$) proven with no partial or transitive dependencies.
2. **State-Machine Synchronization Constraints:** Compound multi-column `CHECK` constraints enforcing real-world hospital workflows (e.g., `chk_lab_status_sync`, `chk_adm_status_sync`).
3. **Derived Virtual Columns:** Zero-redundancy temporal and spatial columns (e.g., `/EndTime`, `/PrescriptionTime`, `/Address`, `/FullName`).
4. **Clinical Safety & Pharmacy Automation:** Real hospital database mechanisms (Allergy guards, stock triggers, and scheduling collision prevention).

---

## 3. High-Value Clinical Extensions for 85%+

### Extension 1: Pharmacy Auto-Stock Deduction Trigger (Student 4)
* **Table:** `Prescription` $\leftrightarrow$ `Medication`
* **Trigger Action:** When a prescription's `DispenseStatus` changes to `'Dispensed'`:
  1. Verifies `Medication.QuantityInStock >= Prescription.QuantityPrescribed`.
  2. If sufficient, automatically decrements `QuantityInStock = QuantityInStock - QuantityPrescribed`.
  3. If insufficient, intercepts the transaction and throws:
     ```sql
     RAISE_APPLICATION_ERROR(-20001, 'Pharmacy Out-of-Stock: Insufficient medication units available.');
     ```
  4. If stock falls below a threshold (`ReorderLevel`), flags an inventory alert.

### Extension 2: Patient Drug Allergy & Interaction Guard (`PatientAllergy`)
* **Concept:** If the team wishes to introduce a high-impact 17th entity, **`PatientAllergy`** is the gold standard for hospital databases:
  * Schema: `PatientAllergy (PatientID*, AllergenCategory, Severity, Reaction, DiagnosedDate)`
* **Examiner Impact:** Demonstrates life-saving clinical intelligence: if a doctor prescribes *Amoxicillin* to a patient with a documented *Penicillin* allergy, a trigger blocks the prescription.

### Extension 3: Complete 3-Way Scheduling Conflict Protection (Student 3)
* **Implemented:** Both at the DDL constraint level (`uq_proc_doc_time`, `uq_proc_room_time`, `uq_proc_pat_time`) and within the transactional stored procedure engine (`sp_schedule_procedure`), closing the scheduling triangle so that **neither the doctor, the operating room, nor the patient** can be double-booked.

---

## 4. Student 4 Schema Extensions Already Implemented

In commit `5d82ccb`, the following attributes and constraints were added to `Prescription`:

1. **`QuantityPrescribed NUMBER(3) DEFAULT 1 NOT NULL` (`chk_rx_qty`):**
   * Solves the pricing calculation: $\text{Total Prescription Fee} = \text{QuantityPrescribed} \times \text{Medication.UnitPrice}$.
   * Bounded realistically between 1 and 1,000 units.
2. **`DispenseStatus VARCHAR2(20) DEFAULT 'Pending' NOT NULL` (`chk_rx_dispense`):**
   * Enforces pharmacy fulfillment lifecycle: `IN ('Pending', 'Dispensed', 'Cancelled')`.
   * Directly sets up the Student 4 Inventory Trigger.
3. **`PrescriptionDate` with Date + Time Timestamp:**
   * Holds `YYYY-MM-DD HH24:MI:SS`.
4. **`/PrescriptionTime VARCHAR2(5)` (Virtual Derived Column):**
   * Auto-extracted as `TO_CHAR(PrescriptionDate, 'HH24:MI')`.
5. **`/EndDate DATE` (Virtual Derived Column):**
   * Auto-calculated as `PrescriptionDate + Duration`.
6. **`uq_rx_order UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)`:**
   * Accommodates multiple same-day prescriptions (e.g., morning 08:00 and evening 20:00) while blocking duplicate orders at the exact same moment.

---

## 5. Enterprise Data Deletion & Retention Policy Matrix

### A. The Core Deletion Rules
1. **`ON DELETE CASCADE` is strictly prohibited on clinical and financial tables.** Wiping parent records must never erase medical records, surgeries, or invoices.
2. **`ON DELETE RESTRICT` (Oracle Default `NO ACTION`):** Prevents deletion of any entity referenced by active foreign keys.
3. **`ON DELETE SET NULL`:** Permitted **only** on recursive self-referencing relationships (`Doctor.SupervisorID`, `Nurse.SupervisorID`) so junior staff are not affected when a department chief departs.
4. **Soft Deletes (Status Flags):** In operational healthcare, entities transition through lifecycle states rather than being physically deleted.

### B. Master Policy Matrix for All 16 Entities

| # | Entity Name | Owner | Physical `DELETE` Allowed? | FK Deletion Action | Soft-Delete Mechanism / State | Legal / Regulatory Retention Period | Clinical & Business Justification |
| :-: | :--- | :-: | :-: | :-: | :--- | :--- | :--- |
| **1** | `Department` | Student 1 | ❌ NO | `RESTRICT` | Reassign staff before deactivation | Permanent organizational record | Cannot orphan active doctors, nurses, or wards. |
| **2** | `Doctor` | Student 1 | ❌ NO | `RESTRICT` (Self FK: `SET NULL`) | `Specialty/Status = 'Inactive'` | 10 years after departure | Medical-legal audit trail for past consultations. |
| **3** | `Nurse` | Student 1 | ❌ NO | `RESTRICT` (Self FK: `SET NULL`) | `Shift = 'Inactive'` | 10 years after departure | Inpatient ward care audit history. |
| **4** | `Patient` | Student 2 | ❌ NO | `RESTRICT` | Archive record (`Status = 'Inactive'`) | Lifetime + 10 years | Legal mandate: clinical records must be permanently retained. |
| **5** | `Room` | Student 2 | ❌ NO | `RESTRICT` | `AvailabilityStatus = 'Maintenance'` | Permanent physical asset | Cannot delete rooms with historical admissions. |
| **6** | `Admission` | Student 2 | ❌ NO | `RESTRICT` | `AdmissionStatus = 'Discharged'` | 10 years | Bed occupancy and inpatient billing history. |
| **7** | `Appointment` | Student 3 | ⚠️ Draft only | Terminal (No child tables) | `Status = 'Cancelled'` or `'No-Show'` | 5 years | Outpatient clinic audit; notes required for cancellations. |
| **8** | `MedicalRecord` | Student 3 | 🚫 ILLEGAL | Terminal (No child tables) | **Immutable Record** (Addendum only) | 10+ years (Permanent legal file) | Medical malpractice law: clinical diagnoses cannot be altered/deleted. |
| **9** | `MedicalProcedure` | Student 3 | ⚠️ Draft only | Terminal (No child tables) | `Outcome = 'Aborted'` or `'Unsuccessful'` | 10 years | Surgical registry and operating room safety compliance. |
| **10** | `Medication` | Student 4 | ❌ NO | `RESTRICT` | `QuantityInStock = 0` (Discontinued) | 5 years after batch expiration | Formulary audit; referenced by past prescriptions. |
| **11** | `Prescription` | Student 4 | ⚠️ Draft only | Terminal (No child tables) | `DispenseStatus = 'Cancelled'` | 7 years | Controlled substance laws and prescription logs. |
| **12** | `LaboratoryTest` | Student 4 | ⚠️ Draft only | Terminal (No child tables) | `TestStatus = 'Cancelled'` | 7 years | CAP/CLIA lab standards and diagnostic records. |
| **13** | `Supplier` | Student 5 | ❌ NO | `RESTRICT` | `ContractStatus = 'Terminated'` | 7 years | Corporate commercial contracts and procurement history. |
| **14** | `Insurance` | Student 5 | ❌ NO | Terminal (Child of Patient) | `InsuranceStatus = 'Expired'` or `'Cancelled'` | 7 years after policy expiration | Insurance claim audit and coverage verification history. |
| **15** | `Invoice` | Student 5 | 🚫 ILLEGAL | `RESTRICT` | `PaymentStatus = 'Cancelled'` | 10 years | National Tax and Corporate Accounting compliance. |
| **16** | `Payment` | Student 5 | 🚫 ILLEGAL | Terminal (Child of Invoice) | `PaymentStatus = 'Refunded'` | 10 years | Banking reconciliation and fraud prevention standards. |

---

## 6. How to Use This in the Final Report & Presentation

1. **In Section 4 (Requirements & Integrity Rules):** Embed the **Master Deletion & Retention Matrix** to prove enterprise data governance compliance.
2. **In Section 8 (Normalization):** Emphasize how `Prescription` maintains 3NF by calculating total cost on the fly via `Medication.UnitPrice * QuantityPrescribed`, rather than storing redundant calculated fields.
3. **In Section 11 (Advanced Database Features):** Highlight the **Student 4 Trigger** (Stock Deduction & Guard) and the **Student 3 Stored Procedures** (3-Way Scheduling Guard) as evidence of distinction-level software engineering.
