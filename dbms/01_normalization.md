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
