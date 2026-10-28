# Hospital Management System (HMS) — Database Project

**Module:** Data Modeling for DB (`4FTC2063`) — University of Hertfordshire (2026/27)  
**Weighting:** 35% of overall grade  
**Database Platform:** Oracle Database / Oracle APEX  
**Architecture:** 16 Relational Entities, 3NF Normalization, Integrated Schema

---

## 📂 Repository Structure

```text
project/
├── .gitignore
├── README.md                          <-- Project master guide & instructions
├── docs/                              <-- Documentation, diagrams & reports
│   ├── erd/                           <-- ERDPlus individual and master diagram exports
│   │   ├── README.md
│   │   ├── individual/                (Exports from each student)
│   │   └── master/                    (Combined master ERD + relational schema)
│   ├── report/                        <-- Section drafts for final report
│   │   └── README.md
│   └── presentation/                  <-- Slides and demo notes
│       └── README.md
├── scripts/
│   ├── 00_master_schema.sql           <-- Master DDL for all 16 tables in FK order
│   ├── 00_master_drop.sql             <-- Complete clean drop script
│   ├── 00_master_run_all.sql          <-- Unified build & execution script
│   ├── 01_schema/                     <-- Table DDL split by student & entity
│   │   ├── student1_dept_staff/       (01_department.sql, 02_doctor.sql, 03_nurse.sql)
│   │   ├── student2_patient_admission/(01_patient.sql, 02_room.sql, 03_admission.sql)
│   │   ├── student3_appointments_records/ (01_appointment.sql, 02_medical_record.sql, 03_medical_procedure.sql)
│   │   ├── student4_pharmacy_lab/     (01_medication.sql, 02_prescription.sql, 03_laboratory_test.sql)
│   │   └── student5_finance_insurance/(01_supplier.sql, 02_insurance.sql, 03_invoice.sql, 04_payment.sql)
│   ├── 02_seeds/                      <-- Sample data INSERT scripts per entity
│   │   ├── student1_dept_staff/
│   │   ├── student2_patient_admission/
│   │   ├── student3_appointments_records/
│   │   ├── student4_pharmacy_lab/
│   │   └── student5_finance_insurance/
│   ├── 03_queries/                    <-- 7 queries per student (2 Easy, 3 Med, 2 Hard)
│   │   ├── student1_queries.sql
│   │   ├── student2_queries.sql
│   │   ├── student3_queries.sql
│   │   ├── student4_queries.sql
│   │   └── student5_queries.sql
│   ├── 04_advanced_features/          <-- 1 advanced object per student
│   │   ├── student1_view.sql          (View: Doctor & Dept workload)
│   │   ├── student2_trigger.sql       (Trigger: Sync room availability)
│   │   ├── student3_stored_proc.sql   (Stored Proc: Conflict-free appointment booking)
│   │   ├── student4_trigger.sql       (Trigger: Auto-deduct medicine stock)
│   │   └── student5_function.sql      (Function: Net patient balance)
│   └── 05_testing/                    <-- Positive and negative constraint tests
│       ├── student1_tests.sql
│       ├── student2_tests.sql
│       ├── student3_tests.sql
│       ├── student4_tests.sql
│       └── student5_tests.sql
```

---

## 👥 Student Role Allocation & Agreed ID Ranges

To avoid foreign key conflicts while working asynchronously, everyone sticks strictly to these pre-agreed ID ranges:

| Role | Student | Entities Assigned | Target Rows | Agreed ID Range | Foreign Key Dependencies |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Student 1** | *Beginner* | `Department`, `Doctor`, `Nurse` | 8 depts, 20 docs, 30 nurses | Dept: `1..8`<br>Doc: `1..20`<br>Nurse: `1..30` | `Doctor.DepartmentID` $\rightarrow$ Dept<br>`Nurse.DepartmentID` $\rightarrow$ Dept |
| **Student 2** | *Beginner/Mod* | `Patient`, `Room`, `Admission` | 100 patients, 50 rooms, 150 admissions | Pat: `1..100`<br>Room: `1..50`<br>Adm: `1..150` | `Admission.PatientID` $\rightarrow$ Pat<br>`Admission.RoomID` $\rightarrow$ Room |
| **Student 3** | *Average* | `Appointment`, `MedicalRecord`, `MedicalProcedure` | 300 apts, 250 records, 100 procedures | Apt: `1..300`<br>Rec: `1..250`<br>Proc: `1..100` | Links to `PatientID` (`1..100`) and `DoctorID` (`1..20`) |
| **Student 4** | *Strong* | `Medication`, `Prescription`, `LaboratoryTest` | 50 meds, 300 presc, 200 tests | Med: `1..50`<br>Presc: `1..300`<br>Test: `1..200` | `Medication.SupplierID` $\rightarrow$ Supplier (`1..15`)<br>`Prescription` $\rightarrow$ Pat, Doc, Med<br>`LaboratoryTest` $\rightarrow$ Pat, Doc |
| **Student 5** | *Lead / Merger*| `Supplier`, `Insurance`, `Invoice`, `Payment` | 15 supp, 100 ins, 200 inv, 250 pay | Supp: `1..15`<br>Ins: `1..100`<br>Inv: `1..200`<br>Pay: `1..250` | `Insurance.PatientID` $\rightarrow$ Pat<br>`Invoice.PatientID` $\rightarrow$ Pat<br>`Payment.InvoiceID` $\rightarrow$ Invoice |

---

## 🗓️ End-to-End Project Steps (4-Week Roadmap)

### **Week 1: Schema Lock-in & Environment Setup**
1. **Lead Action:** Run `scripts/00_master_schema.sql` in your APEX workspace.
2. **Distribution:** Send each member their assigned folder and the agreed ID ranges above.
3. **ERD Kickoff:** Each student designs their individual entities on [ERDPlus](https://erdplus.com) and exports `.png` to `docs/erd/individual/`.

### **Week 2: Data Seeding (Mock Data Generation)**
1. Each student completes their assigned INSERT files in `scripts/02_seeds/` to satisfy minimum row counts.
2. **Filter Layer (Lead):** 
   - Check that student foreign keys reference valid IDs.
   - Run the INSERT scripts in the master APEX workspace.
   - Run `COMMIT;`.

### **Week 3: Query Execution & Advanced Features**
1. Each student tests their 7 assigned queries from `scripts/03_queries/` (2 Easy, 3 Medium, 2 Hard).
2. Each student implements their designated **Advanced Feature** (View, Trigger, Procedure, Function) from `scripts/04_advanced_features/`.
3. **Filter Layer (Lead):** Verify queries return non-empty, expected results in APEX and log any execution time or indexing needs.

### **Week 4: Testing, Report Compilation & Presentation**
1. **Constraint Testing:** Run all positive and negative test cases from `scripts/05_testing/`. Capture screenshots of Oracle error codes (`ORA-00001`, `ORA-02290`, `ORA-02291`).
2. **Master ERD:** Merge individual ERDPlus files into `docs/erd/master/hms_master_erd.png`.
3. **Compile Report:** Combine each member's contributions according to Section 19 of the brief.
4. **Slide Deck:** Rehearse the 10-minute presentation and live APEX demo.

---

## ⚙️ How to Push this Repository to GitHub

Open PowerShell in this project folder and run:

```bash
# 1. Add all files to staging
git add .

# 2. Commit the initial architecture
git commit -m "feat: complete HMS project architecture, schemas, seeds, queries, and docs"

# 3. Link to your GitHub repository (Create a repository on github.com first)
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo-name>.git

# 4. Push
git push -u origin main
```
