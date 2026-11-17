# Database Normalization Report — Rog-Rakshak (CP1)

⁠UNF — the original unnormalized production record
Imagine the hospital portal receives a submission and stores the entire submission as one nested record.

The application may initially receive JSON, but if we try to store all of it as one relational row, we get the following structure.
2.1 HospitalSurveillance_UNF
One row = one hospital submission.
Column	Example value
report_id	REP-2026-11016
submitted_at	2026-11-16 10:30:00
hospital_id	H-001
hospital_name	Patna City Hospital
hospital_registration_no	BR-PAT-001
hospital_address	12 Fraser Road, Patna
submitter_id	U-014
submitter_name	Ananya Singh
submitter_email	ananya@hospital.example
submitter_role	HOSPITAL_REPORTER
report_status	SUBMITTED
report_lines	Multiple disease records packed into one field
attachments	Multiple files packed into one field

The two complex columns contain these values:

report_lines

[
  {
    "line_no": 1,
    "disease_id": "DIS-01",
    "disease_name": "Dengue",
    "area_id": "A-012",
    "area_name": "Ward 12",
    "report_date": "2026-11-15",
    "age_group": "ADULT",
    "case_classification": "SUSPECTED",
    "case_count": 18
  },
  {
    "line_no": 2,
    "disease_id": "DIS-01",
    "disease_name": "Dengue",
    "area_id": "A-012",
    "area_name": "Ward 12",
    "report_date": "2026-11-15",
    "age_group": "CHILD",
    "case_classification": "CONFIRMED",
    "case_count": 6
  },
  {
    "line_no": 3,
    "disease_id": "DIS-02",
    "disease_name": "Malaria",
    "area_id": "A-015",
    "area_name": "Ward 15",
    "report_date": "2026-11-15",
    "age_group": "ADULT",
    "case_classification": "CONFIRMED",
    "case_count": 4
  },
  {
    "line_no": 4,
    "disease_id": "DIS-03",
    "disease_name": "Chikungunya",
    "area_id": "A-018",
    "area_name": "Ward 18",
    "report_date": "2026-11-15",
    "age_group": "ADULT",
    "case_classification": "SUSPECTED",
    "case_count": 3
  }
]



attachments

[
  {
    "attachment_id": "ATT-001",
    "file_name": "week46_surveillance.csv",
    "storage_key": "reports/REP-2026-11016/week46.csv",
    "content_type": "text/csv"
  },
  {
    "attachment_id": "ATT-002",
    "file_name": "lab_summary.pdf",
    "storage_key": "reports/REP-2026-11016/lab-summary.pdf",
    "content_type": "application/pdf"
  }
]



2.2 More UNF records
A second hospital submission might look like this:
Field	Report REP-2026-11017
submitted_at	2026-11-16 11:05
hospital_id	H-002
hospital_name	Gandhi Memorial Hospital
hospital_registration_no	BR-PAT-002
hospital_address	45 Gandhi Maidan Road, Patna
submitter_id	U-022
submitter_name	Rahul Kumar
submitter_email	rahul@hospital.example
submitter_role	HOSPITAL_REPORTER
report_status	SUBMITTED
report_lines	Dengue: 11, Ward 12; Chikungunya: 3, Ward 18
attachments	week46_hospital2.csv

And a third submission:
Field	Report REP-2026-11018
submitted_at	2026-11-16 12:15
hospital_id	H-001
hospital_name	Patna City Hospital
hospital_registration_no	BR-PAT-001
hospital_address	12 Fraser Road, Patna
submitter_id	U-014
submitter_name	Ananya Singh
submitter_email	ananya@hospital.example
submitter_role	HOSPITAL_REPORTER
report_status	SUBMITTED
report_lines	Dengue: 5, Ward 12; Malaria: 2, Ward 15
attachments	week46_update.csv

2.3 Why this UNF structure fails in production
Consider the actual operations VectorWatch needs.
Operation	Problem with UNF
Count all Dengue cases in Ward 12	Must inspect nested lists
Find all reports submitted by U-014	Submitter information is duplicated
Find all hospitals in Patna	Hospital data is buried in submissions
Find all confirmed cases	Classification is inside nested records
Find reports with missing attachments	Attachment arrays need special handling
Change a hospital address	Multiple report records may need updates
Assign an area to a medical office	No independent area relationship
Compare weekly case counts	Nested records are awkward to aggregate

There are three classic anomalies:
•⁠  ⁠Update anomaly: Changing Ananya's email requires changing many submissions.
•⁠  ⁠Insertion anomaly: A newly registered hospital cannot be stored cleanly until it submits a report.
•⁠  ⁠Deletion anomaly: Deleting a hospital's only report could remove the only stored copy of its address.
UNF conclusion: The submission is a useful input format, but not a suitable relational storage structure.


1NF — First Normal Form with actual records
We now remove the repeating groups.

The important transformation is:
•⁠  ⁠Each disease observation becomes one row.
•⁠  ⁠Each attachment becomes one row in a separate attachment relation.
•⁠  ⁠Each field contains one value.
•⁠  ⁠Report-level details remain repeated temporarily; we have not yet removed all redundancy.
3.1 SurveillanceLine_1NF
One row = one disease observation inside one report.

For this example, the unique row identifier is (report_id, line_no).

Here is the complete 1NF table.
report_id	line_no	submitted_at	hospital_id	hospital_name	registration_no	hospital_address	submitter_id	submitter_name	submitter_email	role	disease_id	disease_name	area_id	area_name	report_date	age_group	classification	cases	status
REP-11016	1	16 Nov 10:30	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-01	Dengue	A-012	Ward 12	15 Nov	ADULT	SUSPECTED	18	SUBMITTED
REP-11016	2	16 Nov 10:30	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-01	Dengue	A-012	Ward 12	15 Nov	CHILD	CONFIRMED	6	SUBMITTED
REP-11016	3	16 Nov 10:30	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-02	Malaria	A-015	Ward 15	15 Nov	ADULT	CONFIRMED	4	SUBMITTED
REP-11016	4	16 Nov 10:30	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-03	Chikungunya	A-018	Ward 18	15 Nov	ADULT	SUSPECTED	3	SUBMITTED
REP-11017	1	16 Nov 11:05	H-002	Gandhi Memorial Hospital	BR-PAT-002	45 Gandhi Maidan	U-022	Rahul Kumar	rahul@hospital.example	REPORTER	DIS-01	Dengue	A-012	Ward 12	15 Nov	ADULT	CONFIRMED	11	SUBMITTED
REP-11017	2	16 Nov 11:05	H-002	Gandhi Memorial Hospital	BR-PAT-002	45 Gandhi Maidan	U-022	Rahul Kumar	rahul@hospital.example	REPORTER	DIS-03	Chikungunya	A-018	Ward 18	15 Nov	ADULT	SUSPECTED	3	SUBMITTED
REP-11018	1	16 Nov 12:15	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-01	Dengue	A-012	Ward 12	16 Nov	ADULT	SUSPECTED	5	SUBMITTED
REP-11018	2	16 Nov 12:15	H-001	Patna City Hospital	BR-PAT-001	12 Fraser Road	U-014	Ananya Singh	ananya@hospital.example	REPORTER	DIS-02	Malaria	A-015	Ward 15	16 Nov	ADULT	CONFIRMED	2	SUBMITTED

The report IDs are abbreviated in this display for readability; the canonical IDs are REP-2026-11016, REP-2026-11017 and REP-2026-11018.
3.2 What happened to attachments?
Attachments are a separate repeating group, so we create another 1NF relation.
ReportAttachment_1NF
report_id	attachment_id	file_name	storage_key	content_type
REP-11016	ATT-001	week46_surveillance.csv	reports/REP-11016/week46.csv	text/csv
REP-11016	ATT-002	lab_summary.pdf	reports/REP-11016/lab-summary.pdf	application/pdf
REP-11017	ATT-003	week46_hospital2.csv	reports/REP-11017/week46.csv	text/csv
REP-11018	ATT-004	week46_update.csv	reports/REP-11018/update.csv	text/csv

Now we have no comma-separated disease lists and no attachment arrays inside cells.
3.3 1NF functional dependencies
For the main line relation:
\[
(report\_id,line\_no) \rightarrow
\text{all attributes of that line}
\]

But additional dependencies also exist:
Determinant	Attributes determined
report_id	submitted_at, hospital_id, submitter_id, status
hospital_id	hospital_name, registration_no, hospital_address
submitter_id	submitter_name, submitter_email, role
disease_id	disease_name
area_id	area_name
(report_id, line_no)	disease_id, area_id, report_date, age_group, classification, cases

This is the key observation: the table is atomic, but many attributes are still repeated and do not depend on the entire composite key.# Database Normalization – VectorWatch

## 1. Unnormalized Form (UNF)

In UNF, one row represents one hospital submission. Disease records and attachments are stored as repeating groups inside the report.

### 1.1 HospitalSurveillance_UNF

| report_id | submitted_at | hospital_id | hospital_name | hospital_registration_no | hospital_address | submitter_id | submitter_name | submitter_email | submitter_role | report_status |
|---|---|---|---|---|---|---|---|---|---|---|
| REP-2026-11016 | 2026-11-16 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road, Patna | U-014 | Ananya Singh | ananya@hospital.example | HOSPITAL_REPORTER | SUBMITTED |
| REP-2026-11017 | 2026-11-16 11:05 | H-002 | Gandhi Memorial Hospital | BR-PAT-002 | 45 Gandhi Maidan Road, Patna | U-022 | Rahul Kumar | rahul@hospital.example | HOSPITAL_REPORTER | SUBMITTED |
| REP-2026-11018 | 2026-11-16 12:15 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road, Patna | U-014 | Ananya Singh | ananya@hospital.example | HOSPITAL_REPORTER | SUBMITTED |

### 1.2 Repeating Group: report_lines

| report_id | line_no | disease_id | disease_name | area_id | area_name | report_date | age_group | case_classification | case_count |
|---|---:|---|---|---|---|---|---|---|---:|
| REP-2026-11016 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | ADULT | SUSPECTED | 18 |
| REP-2026-11016 | 2 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | CHILD | CONFIRMED | 6 |
| REP-2026-11016 | 3 | DIS-02 | Malaria | A-015 | Ward 15 | 2026-11-15 | ADULT | CONFIRMED | 4 |
| REP-2026-11016 | 4 | DIS-03 | Chikungunya | A-018 | Ward 18 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-2026-11017 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | ADULT | CONFIRMED | 11 |
| REP-2026-11017 | 2 | DIS-03 | Chikungunya | A-018 | Ward 18 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-2026-11018 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-16 | ADULT | SUSPECTED | 5 |
| REP-2026-11018 | 2 | DIS-02 | Malaria | A-015 | Ward 15 | 2026-11-16 | ADULT | CONFIRMED | 2 |

### 1.3 Repeating Group: attachments

| report_id | attachment_id | file_name | storage_key | content_type |
|---|---|---|---|---|
| REP-2026-11016 | ATT-001 | week46_surveillance.csv | reports/REP-2026-11016/week46.csv | text/csv |
| REP-2026-11016 | ATT-002 | lab_summary.pdf | reports/REP-2026-11016/lab-summary.pdf | application/pdf |
| REP-2026-11017 | ATT-003 | week46_hospital2.csv | reports/REP-2026-11017/week46.csv | text/csv |
| REP-2026-11018 | ATT-004 | week46_update.csv | reports/REP-2026-11018/update.csv | text/csv |

*UNF issue:* The report contains multiple disease lines and attachments as repeating groups. These are not stored as independent relational records.

---

## 2. First Normal Form (1NF)

In 1NF, repeating groups are removed. Each disease observation and each attachment is stored as an individual row.

### 2.1 SurveillanceLine_1NF

*Primary Key:* ⁠ (report_id, line_no) ⁠

| report_id | line_no | submitted_at | hospital_id | hospital_name | registration_no | hospital_address | submitter_id | submitter_name | submitter_email | role | disease_id | disease_name | area_id | area_name | report_date | age_group | classification | cases | status |
|---|---:|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---:|---|
| REP-11016 | 1 | 16 Nov 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-01 | Dengue | A-012 | Ward 12 | 15 Nov | ADULT | SUSPECTED | 18 | SUBMITTED |
| REP-11016 | 2 | 16 Nov 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-01 | Dengue | A-012 | Ward 12 | 15 Nov | CHILD | CONFIRMED | 6 | SUBMITTED |
| REP-11016 | 3 | 16 Nov 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-02 | Malaria | A-015 | Ward 15 | 15 Nov | ADULT | CONFIRMED | 4 | SUBMITTED |
| REP-11016 | 4 | 16 Nov 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-03 | Chikungunya | A-018 | Ward 18 | 15 Nov | ADULT | SUSPECTED | 3 | SUBMITTED |
| REP-11017 | 1 | 16 Nov 11:05 | H-002 | Gandhi Memorial Hospital | BR-PAT-002 | 45 Gandhi Maidan | U-022 | Rahul Kumar | rahul@hospital.example | REPORTER | DIS-01 | Dengue | A-012 | Ward 12 | 15 Nov | ADULT | CONFIRMED | 11 | SUBMITTED |
| REP-11017 | 2 | 16 Nov 11:05 | H-002 | Gandhi Memorial Hospital | BR-PAT-002 | 45 Gandhi Maidan | U-022 | Rahul Kumar | rahul@hospital.example | REPORTER | DIS-03 | Chikungunya | A-018 | Ward 18 | 15 Nov | ADULT | SUSPECTED | 3 | SUBMITTED |
| REP-11018 | 1 | 16 Nov 12:15 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-01 | Dengue | A-012 | Ward 12 | 16 Nov | ADULT | SUSPECTED | 5 | SUBMITTED |
| REP-11018 | 2 | 16 Nov 12:15 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | DIS-02 | Malaria | A-015 | Ward 15 | 16 Nov | ADULT | CONFIRMED | 2 | SUBMITTED |

### 2.2 ReportAttachment_1NF

| report_id | attachment_id | file_name | storage_key | content_type |
|---|---|---|---|---|
| REP-11016 | ATT-001 | week46_surveillance.csv | reports/REP-11016/week46.csv | text/csv |
| REP-11016 | ATT-002 | lab_summary.pdf | reports/REP-11016/lab-summary.pdf | application/pdf |
| REP-11017 | ATT-003 | week46_hospital2.csv | reports/REP-11017/week46.csv | text/csv |
| REP-11018 | ATT-004 | week46_update.csv | reports/REP-11018/update.csv | text/csv |

### 2.3 Functional Dependencies in 1NF

| Determinant | Dependent Attributes |
|---|---|
| report_id | submitted_at, hospital_id, submitter_id, status |
| hospital_id | hospital_name, registration_no, hospital_address |
| submitter_id | submitter_name, submitter_email, role |
| disease_id | disease_name |
| area_id | area_name |
| (report_id, line_no) | disease_id, area_id, report_date, age_group, classification, cases |

*1NF issue:* All values are atomic, but report, hospital, submitter, disease and area information is still repeated.

---

