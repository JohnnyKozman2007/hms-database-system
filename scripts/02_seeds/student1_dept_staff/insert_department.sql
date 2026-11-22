-- SEED DATA: Department (Student 1) - 8 rows
-- Row 1 omits PhoneType to exercise DEFAULT ('Landline').

INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, DepartmentDescription) VALUES ('DEPT01', 'Cardiology', 'Building A', '1st Floor', '0227951001', 'Diagnosis and treatment of heart and cardiovascular disorders.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT02', 'Emergency Medicine', 'Building A', 'Ground Floor', '0227951002', 'Landline', '24/7 acute trauma, resuscitation, and emergency stabilization.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT03', 'Pediatrics', 'Building A', '2nd Floor', '0227951003', 'Landline', 'Comprehensive medical care for infants, children, and adolescents.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT04', 'Orthopedics', 'Building B', '1st Floor', '0227951004', 'Landline', 'Musculoskeletal surgery, fracture care, and joint rehabilitation.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT05', 'Neurology', 'Building B', '3rd Floor', '0227951005', 'Landline', 'Treatment of neurological diseases, stroke, and seizure disorders.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT06', 'Oncology', 'Building C', '2nd Floor', '01001122006', 'Mobile', 'Medical oncology, chemotherapy infusion, and cancer care coordination.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT07', 'Radiology', 'Building C', 'Ground Floor', '0227951007', 'Landline', 'Diagnostic imaging including MRI, CT, ultrasound, and X-ray.');
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription) VALUES ('DEPT08', 'General Surgery', 'Building D', '4th Floor', '01112233008', 'Mobile', 'Elective and emergency surgical procedures across inpatient wards.');

COMMIT;
