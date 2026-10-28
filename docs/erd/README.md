# ERDPlus Diagrams & Relational Schemas

This folder contains all ERDPlus source files and exported diagrams for the Hospital Management System (HMS).

## Tools
- **Tool Used:** [ERDPlus](https://erdplus.com/)
- **Target Output:** Integrated Conceptual ERD + Relational Schema (3NF)

---

## 📁 File Structure in this Folder
- `individual/`: Place each student's separate entity ERD exports here.
  - `student1_dept_staff.png` / `.erdplus`
  - `student2_patient_admission.png` / `.erdplus`
  - `student3_appointments_records.png` / `.erdplus`
  - `student4_pharmacy_lab.png` / `.erdplus`
  - `student5_finance_insurance.png` / `.erdplus`
- `master/`: The final unified ERD showing all 16 entities and relationships.
  - `hms_master_erd.png`
  - `hms_master_relational_schema.png`
  - `hms_master_erd.erdplus` (Raw export for ERDPlus import/edit)

---

## 📝 How to Use ERDPlus for Each Student

1. Go to [https://erdplus.com](https://erdplus.com) and create a free account.
2. Click **New Diagram** $\rightarrow$ select **ER Diagram**.
3. Create your assigned entities:
   - Mark Primary Keys as **[PK]**.
   - Add attributes with proper single/multivalued/composite representations.
4. Draw relationships with proper cardinalities (1:1, 1:N, M:N).
5. Click **Documents $\rightarrow$ Export Image (PNG)** and save it in `docs/erd/individual/`.
6. Click **Documents $\rightarrow$ Export to File** (JSON format) and save the `.erdplus` file so the Team Lead can merge them.

---

## 🔄 Merging into the Master ERD (Lead Role)
1. In ERDPlus, create a new diagram called `HMS_Master_ERD`.
2. Place the core hubs in the center:
   - `Patient`, `Doctor`, `Department`
3. Branch clinical management to the left:
   - `Appointment`, `Admission`, `Room`, `MedicalRecord`, `MedicalProcedure`
4. Branch operational & financial management to the right:
   - `Medication`, `Prescription`, `LaboratoryTest`, `Supplier`, `Insurance`, `Invoice`, `Payment`
5. Verify all 16 cardinalities match Section 5 of the briefing sheet.
6. Export the final high-resolution PNG for the report and presentation slides.
