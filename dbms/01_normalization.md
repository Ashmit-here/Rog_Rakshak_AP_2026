# Database Normalization – VectorWatch

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

**UNF issue:** The report contains multiple disease lines and attachments as repeating groups. These are not stored as independent relational records.

---

## 2. First Normal Form (1NF)

In 1NF, repeating groups are removed. Each disease observation and each attachment is stored as an individual row.

### 2.1 SurveillanceLine_1NF

**Primary Key:** `(report_id, line_no)`

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

**1NF issue:** All values are atomic, but report, hospital, submitter, disease and area information is still repeated.

---

