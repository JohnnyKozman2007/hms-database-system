-- ============================================================================
-- SEED DATA: Department (Student 1)
-- Target: Minimum 8 departments
-- ID Range: 1 to 8
-- ============================================================================

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (1, 'Cardiology', 'Building A, Floor 2', '+44-1707-284001', 'Heart and cardiovascular care, diagnostics and interventions.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (2, 'Neurology', 'Building B, Floor 3', '+44-1707-284002', 'Brain, spinal cord, and nervous system disorders.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (3, 'Orthopedics', 'Building A, Floor 1', '+44-1707-284003', 'Musculoskeletal system, bone fractures, and joint replacements.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (4, 'Pediatrics', 'Building C, Floor 1', '+44-1707-284004', 'Infant, child, and adolescent medical care.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (5, 'Oncology', 'Building B, Floor 1', '+44-1707-284005', 'Cancer diagnosis, chemotherapy, and radiation therapy.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (6, 'Emergency', 'Building A, Ground Floor', '+44-1707-284006', '24/7 acute trauma and urgent medical emergencies.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (7, 'General Surgery', 'Building D, Floor 2', '+44-1707-284007', 'Preoperative, operative, and postoperative patient management.');

INSERT INTO Department (DepartmentID, DepartmentName, Location, Phone, DepartmentDescription)
VALUES (8, 'Dermatology', 'Building C, Floor 2', '+44-1707-284008', 'Skin, hair, and nail conditions and outpatient procedures.');

COMMIT;
