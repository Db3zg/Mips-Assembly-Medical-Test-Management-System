# Mips-Assembly-Medical-Test-Management-System
Objective: 

Develop a system in MIPS assembly to efficiently store, manage, and retrieve medical test data for 
individual patients. This system acts as a basic patient record management system focusing on test 
results.

File Format:

The medical test will be stored in text file. Each line in the text file represents a single medical test. The 
representation will include fields for:

• Patient ID (integer: 7 digits)

• Test name (string - consider a fixed length)

• Test date (string - fixed format like YYYY-MM)

• Result (floating-point value)

For example, the following file has two medical tests:

1300500: RBC, 2024-03, 13.5

1300511: LDL, 2024-03, 110

Medical Tests:

Below is the list of medical tests with their normal range:

1. Hemoglobin (Hgb): 13.8 to 17.2 grams per deciliter
2. Blood Glucose Test (BGT): Normal Range Between 70 to 99 milligrams per deciliter (mg/dL)
3. LDL Cholesterol Low-Density Lipoprotein (LDL): Normal Range Less than 100 mg/dL
4. Blood Pressure Test (BPT): Normal Range: Systolic Blood Pressure: Less than 120 millimeters of 
mercury (mm Hg). Diastolic Blood Pressure: Less than 80 mm Hg

System Functionality:

Develop a text-based menu that allows users to:

• Add a new medical test: the system will allow the user to store a new medical test with the 
required data. The system will check the validity of the input data. 

• Search for a test by patient ID: the system will have the following functionality based on user 
selection:

• Retrieve all patient tests

• Retrieve all up normal patient tests

• Retrieve all patient tests in a given specific period 

• Searching for unnormal tests: the system will retrieve all up normal patients’ tests based on the 
input medical test.

• Average test value: the system will retrieve the average value of each medical test

• Update an existing test result

• Delete a test

In addition to the above functionality, the system has capability for: 

• Error Handling: Implement error handling for invalid file name, searching for non-existent tests, 
searching for non-existent patient, ….

• Data Validation: Validate user input to ensure proper data types (e.g., integers for ID, valid 
dates) and handle potential errors.

