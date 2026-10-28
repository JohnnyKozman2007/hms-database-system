# Course Work 2 Briefing Sheet (2026/27 Academic Year)

## Section A: Assignment title, important dates and weighting

 

| Assignment title: | Course Work2 (Project) | Group or individual: | Group |
| :---- | :---- | :---- | :---- |

 

| Module title: | Data Modeling for DB | Module code: | 4FTC2063 |
| :---- | :---- | :---- | :---- |

 

| Module leader: | Mohammed Abd AlAleem | Moderator’s initials: | HA |
| :---- | :---- | :---- | :---- |

 

| Submission deadline: |   | Target date for return of marked assignment: |   |
| :---- | :---- | :---- | :---- |

 

 

| This assignment is worth | 35% | of the overall assessment for this module.   |
| :---- | :---- | :---- |

 

## Section B: Student(s) to complete.

| Student ID number: |
| :---- |
|   |
| **Student Name:** |
|   |

 

 

| Notes for students ·     	For undergraduate modules: o	a score of 40% or above represents a pass performance at honours level. o	No late submission is allowed. ·     	Regulations governing assessment offences including Plagiarism and Collusion are available from [https\://www\.herts.ac.uk/\_\_data/assets/pdf\_file/0007/237625/AS14-Apx3-Academic-Misconduct.pdf](https://www.herts.ac.uk/__data/assets/pdf_file/0007/237625/AS14-Apx3-Academic-Misconduct.pdf) (UPR AS14). ·     	Guidance on avoiding plagiarism can be found here: [https\://herts.instructure.com/courses/61421/pages/referencing-avoiding-plagiarism?module\_item\_id=779436](https://herts.instructure.com/courses/61421/pages/referencing-avoiding-plagiarism?module_item_id=779436) ·     	Modules may have several components of assessment and may require a pass in all elements. For further details, please consult the Module Specific Requirements (DMD) or ask the Module Leader. |
| :---- |

 

 

Hospital Management System (HMS) Database Project

Complete Assignment Specification

# 1\. Project Overview

The aim of this project is to design and implement a relational database for a Hospital Management System. The database should help a hospital manage its main activities, including hospital departments, doctors, nurses, patients, appointments, admissions, rooms, medical records, medications, prescriptions, laboratory tests, invoices, payments, suppliers, insurance information, and medical procedures.

The project demonstrates database concepts including ER modeling, relational schema design, normalization up to 3NF, primary and foreign keys, integrity constraints, SQL DDL/DML, queries at different difficulty levels, views, functions, stored procedures, triggers, testing, documentation, and presentation.

The project is completed by a team of five students. The workload is divided so that every student works with several entities and performs Easy, Medium, and Hard SQL tasks. Each student is also responsible for one advanced database feature.

# 2\. Project Objectives

By completing this project, students should be able to:

1. Analyze a real-world hospital information system.  
2. Identify entities, attributes, and relationships.  
3. Design an Entity Relationship Diagram (ERD).  
4. Identify primary keys and foreign keys.  
5. Convert an ERD into relational tables.  
6. Apply normalization up to Third Normal Form (3NF).  
7. Create tables and constraints using SQL.  
8. Insert realistic sample data.  
9. Write SQL queries using different levels of complexity.  
10. Create views, functions, triggers, and stored procedures.  
11. Test database operations and relationships.  
12. Work as a team on an integrated relational database.

# 3\. Database Entities

The system contains 16 entities:

1. Department  
2. Doctor  
3. Nurse  
4. Patient  
5. Appointment  
6. Admission  
7. Room  
8. MedicalRecord  
9. Medication  
10. Prescription  
11. LaboratoryTest  
12. Invoice  
13. Payment  
14. Supplier  
15. Insurance  
16. MedicalProcedure

# 4\. Entity Attributes and Purpose

Department: DepartmentID (PK), DepartmentName, Location, Phone, DepartmentDescription. A department has many doctors and nurses.

Doctor: DoctorID (PK), FirstName, LastName, Gender, Phone, Email, Specialty, HireDate, YearsOfExperience, DepartmentID (FK). A doctor belongs to one department and can have many appointments, records, prescriptions, and procedures.

Nurse: NurseID (PK), FirstName, LastName, Gender, Phone, Email, Shift, YearsOfExperience, DepartmentID (FK). A nurse belongs to one department.

Patient: PatientID (PK), FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Address, EmergencyContact, Email. A patient can have many appointments, admissions, records, prescriptions, tests, invoices, and procedures.

Appointment: AppointmentID (PK), PatientID (FK), DoctorID (FK), AppointmentDate, AppointmentTime, Status, Reason, Notes.

Admission: AdmissionID (PK), PatientID (FK), RoomID (FK), AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus.

Room: RoomID (PK), RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus.

MedicalRecord: RecordID (PK), PatientID (FK), DoctorID (FK), Diagnosis, Treatment, Notes, RecordDate, FollowUpDate.

Medication: MedicationID (PK), MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID (FK).

Prescription: PrescriptionID (PK), PatientID (FK), DoctorID (FK), MedicationID (FK), Dosage, Frequency, Duration, PrescriptionDate, Notes.

LaboratoryTest: TestID (PK), PatientID (FK), DoctorID (FK), TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost.

Invoice: InvoiceID (PK), PatientID (FK), InvoiceDate, TotalAmount, TaxAmount, Discount, DueDate, PaymentStatus.

Payment: PaymentID (PK), InvoiceID (FK), PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus.

Supplier: SupplierID (PK), CompanyName, ContactPerson, Phone, Email, Address, ContractStatus.

Insurance: InsuranceID (PK), PatientID (FK), InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus.

MedicalProcedure: ProcedureID (PK), PatientID (FK), DoctorID (FK), ProcedureName, ProcedureDate, OperatingRoom, Duration, ProcedureCost, Outcome.

# 5\. Main Relationships

Department 1:M Doctor

Department 1:M Nurse

Patient 1:M Appointment

Doctor 1:M Appointment

Patient 1:M Admission

Room 1:M Admission

Patient 1:M MedicalRecord

Doctor 1:M MedicalRecord

Patient 1:M Prescription

Doctor 1:M Prescription

Medication 1:M Prescription

Patient 1:M LaboratoryTest

Doctor 1:M LaboratoryTest

Patient 1:M Invoice

Invoice 1:M Payment

Supplier 1:M Medication

Patient 1:M Insurance

Patient 1:M MedicalProcedure

Doctor 1:M MedicalProcedure

# 6\. Database Constraints

The database must use PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, and DEFAULT constraints where appropriate. Examples include: payment amount greater than zero; room capacity greater than zero; medication stock cannot be negative; doctor and supplier email addresses should be unique; appointment and invoice statuses must use valid values; and insurance coverage must be between 0 and 100 percent.

# 7\. Minimum Sample Data

Department: 8  
Doctor: 20  
Nurse: 30  
Patient: 100  
Appointment: 300  
Admission: 150  
Room: 50  
MedicalRecord: 250  
Medication: 50  
Prescription: 300  
LaboratoryTest: 200  
Invoice: 200  
Payment: 250  
Supplier: 15  
Insurance: 100  
MedicalProcedure: 100

# 8\. Equal Student Distribution

Because 16 entities cannot be divided equally among five students, four students receive three entities and one student receives four entities. To keep the workload fair, every student completes the same number and type of SQL tasks: 2 Easy queries, 3 Medium queries, 2 Hard queries, table creation, data insertion, constraints, testing, ERD contribution, documentation, and presentation.

# 9\. Student 1 – Department and Staff Management

Assigned entities: Department, Doctor, Nurse.

Minimum data: 8 departments, 20 doctors, 30 nurses.

Easy:

1. Display all doctors.  
2. Display all departments located in a specified location.

Medium:

3. Display doctors together with their department names.  
4. Count the number of doctors in each department.  
5. Display departments together with the number of nurses.

Hard:

6. Find the department with the highest number of doctors.  
7. Find doctors whose experience is above the average experience.

# 10\. Student 2 – Patient and Admission Management

Assigned entities: Patient, Room, Admission.

Minimum data: 100 patients, 50 rooms, 150 admissions.

Easy:

1. Display all patients.  
2. Display all currently available rooms.

Medium:

3. Display patients together with their admission information.  
4. Display the number of patients admitted to each room.  
5. Display rooms with their daily charges and availability.

Hard:

6. Find patients who have been admitted more than once.  
7. Find rooms that have never been used for an admission.

# 11\. Student 3 – Appointments and Medical Records

Assigned entities: Appointment, MedicalRecord, MedicalProcedure.

Minimum data: 300 appointments, 250 medical records, 100 medical procedures.

Easy:

1. Display all appointments.  
2. Display all medical procedures.

Medium:

3. Display appointments with patient and doctor names.  
4. Display medical records with patient and doctor information.  
5. Count the appointments for each doctor.

Hard:

6. Find the doctor with the highest number of appointments.  
7. Find patients treated by more than one doctor.

# 12\. Student 4 – Pharmacy and Laboratory Management

Assigned entities: Medication, Prescription, LaboratoryTest.

Minimum data: 50 medications, 300 prescriptions, 200 laboratory tests.

Easy:

1. Display all medications.  
2. Display all laboratory tests with their status.

Medium:

3. Display prescriptions with patient, doctor, and medication names.  
4. Display laboratory tests with patient and doctor information.  
5. Count prescriptions for each medication.

Hard:

6. Find the most frequently prescribed medication.  
7. Find patients who have received more than five prescriptions.

# 13\. Student 5 – Finance and Insurance Management

Assigned entities: Invoice, Payment, Supplier, Insurance.

Minimum data: 200 invoices, 250 payments, 15 suppliers, 100 insurance records.

Easy:

1. Display all invoices.  
2. Display all suppliers.

Medium:

3. Display invoices together with patient information.  
4. Display invoices together with their payments.  
5. Calculate the total amount paid for each invoice.

Hard:

6. Find patients who have outstanding invoice balances.  
7. Find the supplier that provides the highest number of medications.

# 14\. Group Integration

The project is one integrated Hospital Management System, not five separate databases. The group must combine all 16 entities, produce one complete ERD, verify all PK/FK relationships, check normalization, combine CREATE TABLE and INSERT scripts, test all queries and advanced objects, resolve conflicts and SQL errors, and prepare one final working database.

# 15\. Normalization

The database must be normalized to Third Normal Form (3NF). Students must demonstrate 1NF by using atomic values and avoiding repeating groups; 2NF by ensuring non-key attributes depend on the complete key; and 3NF by removing inappropriate transitive dependencies between non-key attributes.

# 16\. ERD Requirements

The final ERD must show all 16 entities, important attributes, primary keys, foreign keys, relationships, and cardinalities. The final submission must contain one complete integrated ERD.

# 17\. Testing Requirements

Each student must test their component using positive and negative test cases. Examples include inserting valid data, testing valid relationships, attempting invalid foreign keys, negative payment values, negative medication stock, duplicate unique values, and invalid status values. Expected and actual results should be documented.

# 18\. Final Deliverables

The group must submit:

1. Complete ERD.  
2. Relational schema.  
3. SQL database creation script.  
4. CREATE TABLE statements and constraints.  
5. Sample data and INSERT statements.  
6. All assigned SQL queries.  
7. Testing report with outputs/screenshots.  
8. Final project report.  
9. Final presentation and database demonstration.

# 19\. Final Report Structure

The report should contain:

1. Introduction  
2. System Description  
3. Project Objectives  
4. Requirements  
5. Entity Descriptions  
6. ERD  
7. Relational Schema  
8. Normalization  
9. Database Implementation  
10. SQL Queries  
11. Testing  
12. Results  
13. Conclusion

# 20\. Presentation Requirements

The team presentation should explain the problem, objectives, ERD, database design, relationships, normalization, SQL queries, advanced features, testing, and final results. Any student may be asked questions about the complete database, so all students should understand how the integrated system works.

# 21\. Suggested Individual Marking

ERD: 15%

Relational Schema:15%

Table Creation and Constraints: 15%

Data Insertion: 10%

Easy/Medium/Hard Queries: 25%

Testing: 10%

Individual Explanation: 10%

Total: 100%

# 22\. Final Expected Result

The final result should be a fully functioning relational Hospital Management System containing 16 related entities. The system should support hospital staff, patient, appointment, admission, room, medical record, pharmacy, laboratory, procedure, billing, payment, supplier, and insurance management. Each student must make a meaningful contribution with a similar level of difficulty and workload.

