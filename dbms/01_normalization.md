<<<<<<< HEAD

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

## 3. Second Normal Form (2NF)

In 2NF, partial dependencies are removed. Report-level attributes are separated from individual disease observations.

### 3.1 ReportHeader_2NF

**Primary Key:** `report_id`

| report_id | submitted_at | hospital_id | hospital_name | registration_no | hospital_address | submitter_id | submitter_name | submitter_email | role | report_status |
|---|---|---|---|---|---|---|---|---|---|---|
| REP-11016 | 2026-11-16 10:30 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road, Patna | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | SUBMITTED |
| REP-11017 | 2026-11-16 11:05 | H-002 | Gandhi Memorial Hospital | BR-PAT-002 | 45 Gandhi Maidan Road, Patna | U-022 | Rahul Kumar | rahul@hospital.example | REPORTER | SUBMITTED |
| REP-11018 | 2026-11-16 12:15 | H-001 | Patna City Hospital | BR-PAT-001 | 12 Fraser Road, Patna | U-014 | Ananya Singh | ananya@hospital.example | REPORTER | SUBMITTED |

### 3.2 ReportLine_2NF

**Primary Key:** `(report_id, line_no)`

**Foreign Key:** `report_id` references `ReportHeader_2NF(report_id)`.

| report_id | line_no | disease_id | disease_name | area_id | area_name | report_date | age_group | classification | case_count |
|---|---:|---|---|---|---|---|---|---|---:|
| REP-11016 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | ADULT | SUSPECTED | 18 |
| REP-11016 | 2 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | CHILD | CONFIRMED | 6 |
| REP-11016 | 3 | DIS-02 | Malaria | A-015 | Ward 15 | 2026-11-15 | ADULT | CONFIRMED | 4 |
| REP-11016 | 4 | DIS-03 | Chikungunya | A-018 | Ward 18 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-11017 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-15 | ADULT | CONFIRMED | 11 |
| REP-11017 | 2 | DIS-03 | Chikungunya | A-018 | Ward 18 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-11018 | 1 | DIS-01 | Dengue | A-012 | Ward 12 | 2026-11-16 | ADULT | SUSPECTED | 5 |
| REP-11018 | 2 | DIS-02 | Malaria | A-015 | Ward 15 | 2026-11-16 | ADULT | CONFIRMED | 2 |

### 3.3 ReportAttachment_2NF

**Primary Key:** `attachment_id`

**Foreign Key:** `report_id` references `ReportHeader_2NF(report_id)`.

| attachment_id | report_id | file_name | storage_key | content_type |
|---|---|---|---|---|
| ATT-001 | REP-11016 | week46_surveillance.csv | reports/REP-11016/week46.csv | text/csv |
| ATT-002 | REP-11016 | lab_summary.pdf | reports/REP-11016/lab-summary.pdf | application/pdf |
| ATT-003 | REP-11017 | week46_hospital2.csv | reports/REP-11017/week46.csv | text/csv |
| ATT-004 | REP-11018 | week46_update.csv | reports/REP-11018/update.csv | text/csv |

**2NF result:** Report-level information is separated from report-line information. However, hospital, submitter, disease and area descriptions are still repeated. These transitive dependencies are removed in 3NF.

---
=======
>>>>>>> 63e1c20 (added er diagram in mermaid)

## 4. Third Normal Form (3NF)

In 3NF, transitive dependencies are removed. Each independent entity is stored in its own table and related using primary keys and foreign keys.

### 4.1 Identity and Access Management

#### A. Roles

| role_id (PK) | role_name | description |
|---|---|---|
| R-001 | SYSTEM_ADMIN | Manages platform configuration |
| R-002 | HOSPITAL_REPORTER | Submits hospital surveillance reports |
| R-003 | MEDICAL_OFFICER | Reviews reports and manages local responses |
| R-004 | STATE_ANALYST | Views state-level surveillance |
| R-005 | PUBLIC_HEALTH_ADMIN | Oversees public-health operations |

#### B. Users

| user_id (PK) | role_id (FK) | full_name | email | password_hash | account_status |
|---|---|---|---|---|---|
| U-014 | R-002 | Ananya Singh | ananya@hospital.example | HASH-A14 | ACTIVE |
| U-022 | R-002 | Rahul Kumar | rahul@hospital.example | HASH-R22 | ACTIVE |
| U-031 | R-003 | Priya Verma | priya@health.example | HASH-P31 | ACTIVE |
| U-045 | R-004 | Amit Sharma | amit@health.example | HASH-A45 | ACTIVE |

#### C. Hospitals

| hospital_id (PK) | registration_no | hospital_name | address | area_id (FK) | contact_email | hospital_status |
|---|---|---|---|---|---|---|
| H-001 | BR-PAT-001 | Patna City Hospital | 12 Fraser Road, Patna | A-001 | admin1@hospital.example | ACTIVE |
| H-002 | BR-PAT-002 | Gandhi Memorial Hospital | 45 Gandhi Maidan Road, Patna | A-002 | admin2@hospital.example | ACTIVE |
| H-003 | BR-PAT-003 | North Patna Medical Centre | 8 Ashok Rajpath, Patna | A-003 | admin3@hospital.example | ACTIVE |

#### D. HospitalUsers

| hospital_id (PK, FK) | user_id (PK, FK) | membership_status | joined_at |
|---|---|---|---|
| H-001 | U-014 | ACTIVE | 2026-01-10 |
| H-002 | U-022 | ACTIVE | 2026-02-05 |

### 4.2 Geographic Tables

#### E. States

| state_id (PK) | state_name |
|---|---|
| ST-01 | Bihar |
| ST-02 | Jharkhand |

#### F. Districts

| district_id (PK) | district_name | state_id (FK) |
|---|---|---|
| D-001 | Patna | ST-01 |
| D-002 | Nalanda | ST-01 |
| D-003 | Gaya | ST-01 |

#### G. Areas

| area_id (PK) | area_name | district_id (FK) | area_type | boundary |
|---|---|---|---|---|
| A-001 | Fraser Road zone | D-001 | LOCALITY | PostGIS polygon |
| A-002 | Gandhi Maidan zone | D-001 | LOCALITY | PostGIS polygon |
| A-003 | Ashok Rajpath zone | D-001 | LOCALITY | PostGIS polygon |
| A-012 | Ward 12 | D-001 | WARD | PostGIS polygon |
| A-015 | Ward 15 | D-001 | WARD | PostGIS polygon |
| A-018 | Ward 18 | D-001 | WARD | PostGIS polygon |
| A-021 | Ward 21 | D-002 | WARD | PostGIS polygon |

#### H. MedicalOffices

| medical_office_id (PK) | office_name | district_id (FK) | office_contact | office_status |
|---|---|---|---|---|
| MO-010 | Patna Urban Health Office | D-001 | 0612-000001 | ACTIVE |
| MO-011 | Nalanda District Health Office | D-002 | 0612-000002 | ACTIVE |

#### I. MedicalOfficeAreas

| medical_office_id (PK, FK) | area_id (PK, FK) | valid_from (PK) | valid_to |
|---|---|---|---|
| MO-010 | A-012 | 2026-04-01 | NULL |
| MO-010 | A-015 | 2026-04-01 | NULL |
| MO-010 | A-018 | 2026-04-01 | NULL |
| MO-011 | A-021 | 2026-04-01 | NULL |

### 4.3 Disease and Surveillance Tables

#### J. Diseases

| disease_id (PK) | disease_name | pathogen_type | vector_type |
|---|---|---|---|
| DIS-01 | Dengue | VIRUS | Aedes mosquito |
| DIS-02 | Malaria | PARASITE | Anopheles mosquito |
| DIS-03 | Chikungunya | VIRUS | Aedes mosquito |
| DIS-04 | Japanese Encephalitis | VIRUS | Culex mosquito |

#### K. DiseaseReports

| report_id (PK) | hospital_id (FK) | submitted_by (FK) | submitted_at | report_status |
|---|---|---|---|---|
| REP-11016 | H-001 | U-014 | 2026-11-16 10:30 | SUBMITTED |
| REP-11017 | H-002 | U-022 | 2026-11-16 11:05 | SUBMITTED |
| REP-11018 | H-001 | U-014 | 2026-11-16 12:15 | SUBMITTED |

#### L. DiseaseReportLines

| report_id (PK, FK) | line_no (PK) | disease_id (FK) | area_id (FK) | report_date | age_group | case_classification | case_count |
|---|---:|---|---|---|---|---|---:|
| REP-11016 | 1 | DIS-01 | A-012 | 2026-11-15 | ADULT | SUSPECTED | 18 |
| REP-11016 | 2 | DIS-01 | A-012 | 2026-11-15 | CHILD | CONFIRMED | 6 |
| REP-11016 | 3 | DIS-02 | A-015 | 2026-11-15 | ADULT | CONFIRMED | 4 |
| REP-11016 | 4 | DIS-03 | A-018 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-11017 | 1 | DIS-01 | A-012 | 2026-11-15 | ADULT | CONFIRMED | 11 |
| REP-11017 | 2 | DIS-03 | A-018 | 2026-11-15 | ADULT | SUSPECTED | 3 |
| REP-11018 | 1 | DIS-01 | A-012 | 2026-11-16 | ADULT | SUSPECTED | 5 |
| REP-11018 | 2 | DIS-02 | A-015 | 2026-11-16 | ADULT | CONFIRMED | 2 |

#### M. ReportAttachments

| attachment_id (PK) | report_id (FK) | file_name | storage_key | content_type | uploaded_at |
|---|---|---|---|---|---|
| ATT-001 | REP-11016 | week46_surveillance.csv | reports/REP-11016/week46.csv | text/csv | 10:30 |
| ATT-002 | REP-11016 | lab_summary.pdf | reports/REP-11016/lab-summary.pdf | application/pdf | 10:31 |
| ATT-003 | REP-11017 | week46_hospital2.csv | reports/REP-11017/week46.csv | text/csv | 11:06 |
| ATT-004 | REP-11018 | week46_update.csv | reports/REP-11018/update.csv | text/csv | 12:16 |

### 4.4 Environmental and Vector Surveillance Tables

#### N. WeatherObservations

| weather_id (PK) | area_id (FK) | observed_at | temperature_c | humidity_percent | rainfall_mm | source |
|---|---|---|---:|---:|---:|---|
| W-001 | A-012 | 2026-11-15 09:00 | 29.4 | 78 | 12.5 | WEATHER_API |
| W-002 | A-015 | 2026-11-15 09:00 | 28.8 | 81 | 15.0 | WEATHER_API |
| W-003 | A-018 | 2026-11-15 09:00 | 30.1 | 75 | 8.0 | WEATHER_API |
| W-004 | A-012 | 2026-11-16 09:00 | 30.0 | 76 | 2.0 | WEATHER_API |

#### O. VectorObservations

| vector_id (PK) | area_id (FK) | observed_at | species | adult_count | larvae_count | sampling_method |
|---|---|---|---|---:|---:|---|
| V-001 | A-012 | 2026-11-15 | Aedes aegypti | 34 | 52 | TRAP_SURVEY |
| V-002 | A-015 | 2026-11-15 | Anopheles stephensi | 18 | 21 | LARVAL_SURVEY |
| V-003 | A-018 | 2026-11-15 | Aedes aegypti | 27 | 41 | TRAP_SURVEY |

#### P. BreedingSites

| breeding_site_id (PK) | area_id (FK) | site_type | location | site_status | last_inspected_at |
|---|---|---|---|---|---|
| BS-001 | A-012 | WATER_CONTAINER | PostGIS point | ACTIVE | 2026-11-14 |
| BS-002 | A-012 | OPEN_DRAIN | PostGIS point | ACTIVE | 2026-11-14 |
| BS-003 | A-018 | CONSTRUCTION_SITE | PostGIS point | TREATED | 2026-11-15 |

#### Q. PopulationEstimates

| population_id (PK) | area_id (FK) | reference_year | population_count | source |
|---|---|---:|---:|---|
| POP-001 | A-012 | 2026 | 18500 | CENSUS_ESTIMATE |
| POP-002 | A-015 | 2026 | 22100 | CENSUS_ESTIMATE |
| POP-003 | A-018 | 2026 | 17400 | CENSUS_ESTIMATE |

### 4.5 Machine Learning and Risk Prediction Tables

#### R. MLModels

| model_id (PK) | model_name | version | algorithm | trained_at | artifact_uri |
|---|---|---|---|---|---|
| ML-001 | DengueRiskModel | 1.0 | XGBOOST | 2026-11-01 | models/dengue/v1 |
| ML-002 | MalariaRiskModel | 1.0 | RANDOM_FOREST | 2026-11-01 | models/malaria/v1 |

#### S. RiskPredictions

| prediction_id (PK) | area_id (FK) | disease_id (FK) | model_id (FK) | generated_at | forecast_start | forecast_end | risk_score | risk_level |
|---|---|---|---|---|---|---|---:|---|
| RP-001 | A-012 | DIS-01 | ML-001 | 2026-11-16 | 2026-11-17 | 2026-11-23 | 0.86 | HIGH |
| RP-002 | A-015 | DIS-02 | ML-002 | 2026-11-16 | 2026-11-17 | 2026-11-23 | 0.62 | MODERATE |
| RP-003 | A-018 | DIS-01 | ML-001 | 2026-11-16 | 2026-11-17 | 2026-11-23 | 0.74 | HIGH |

#### T. PredictionFeatures

| prediction_id (PK, FK) | feature_name (PK) | feature_value | contribution_value |
|---|---|---:|---:|
| RP-001 | CASE_TREND_7D | 0.82 | 0.31 |
| RP-001 | RAINFALL | 12.5 | 0.19 |
| RP-001 | HUMIDITY | 78 | 0.14 |
| RP-001 | VECTOR_DENSITY | 34 | 0.22 |
| RP-002 | CASE_TREND_7D | 0.48 | 0.17 |
| RP-002 | RAINFALL | 15.0 | 0.21 |

#### U. Hotspots

| hotspot_id (PK) | area_id (FK) | disease_id (FK) | detected_at | detection_method | intensity |
|---|---|---|---|---|---:|
| HS-001 | A-012 | DIS-01 | 2026-11-16 | SPATIAL_CLUSTER | 0.91 |
| HS-002 | A-018 | DIS-01 | 2026-11-16 | SPATIAL_CLUSTER | 0.78 |

#### V. Alerts

| alert_id (PK) | area_id (FK) | disease_id (FK) | prediction_id (FK) | created_at | severity | status |
|---|---|---|---|---|---|---|
| AL-001 | A-012 | DIS-01 | RP-001 | 2026-11-16 | HIGH | OPEN |
| AL-002 | A-018 | DIS-01 | RP-003 | 2026-11-16 | HIGH | ACKNOWLEDGED |

### 4.6 Intervention and Public Information Tables

#### W. Interventions

| intervention_id (PK) | area_id (FK) | medical_office_id (FK) | intervention_type | priority | status | created_at |
|---|---|---|---|---|---|---|
| IN-001 | A-012 | MO-010 | SOURCE_REDUCTION | HIGH | ASSIGNED | 2026-11-16 |
| IN-002 | A-018 | MO-010 | VECTOR_INSPECTION | HIGH | PLANNED | 2026-11-16 |
| IN-003 | A-015 | MO-010 | AWARENESS_CAMPAIGN | MEDIUM | PLANNED | 2026-11-16 |

#### X. FieldTeams

| team_id (PK) | medical_office_id (FK) | team_name | members_count |
|---|---|---|---:|
| FT-001 | MO-010 | Patna Vector Control Team A | 6 |
| FT-002 | MO-010 | Patna Surveillance Team B | 4 |

#### Y. InterventionAssignments

| intervention_id (PK, FK) | team_id (PK, FK) | assigned_at |
|---|---|---|
| IN-001 | FT-001 | 2026-11-16 14:00 |
| IN-002 | FT-002 | 2026-11-16 14:30 |

#### Z. InterventionReports

| intervention_report_id (PK) | intervention_id (FK) | submitted_by (FK) | outcome | notes | completed_at |
|---|---|---|---|---|---|
| IR-001 | IN-001 | U-031 | COMPLETED | Two breeding sites inspected and treated | 2026-11-17 16:00 |

#### AA. PublicNotifications

| notification_id (PK) | area_id (FK) | disease_id (FK) | title | published_at | expires_at |
|---|---|---|---|---|---|
| PN-001 | A-012 | DIS-01 | Dengue prevention advisory for Ward 12 | 2026-11-16 | 2026-11-23 |
| PN-002 | A-018 | DIS-01 | Mosquito-control advisory for Ward 18 | 2026-11-16 | 2026-11-23 |

#### AB. PreventionGuidelines

| guideline_id (PK) | disease_id (FK) | title | source_name | updated_at |
|---|---|---|---|---|
| PG-001 | DIS-01 | Dengue prevention and control | HEALTH_DEPARTMENT | 2026-10-01 |
| PG-002 | DIS-02 | Malaria prevention guidance | HEALTH_DEPARTMENT | 2026-10-01 |
| PG-003 | DIS-03 | Chikungunya prevention guidance | HEALTH_DEPARTMENT | 2026-10-01 |

---

## 5. Summary of Normalization

| Normal Form | Transformation | Result |
|---|---|---|
| UNF | Original report contains repeating groups | Nested disease observations and attachments |
| 1NF | Repeating groups are separated into rows | Atomic values in each column |
| 2NF | Partial dependencies are removed | Report header, report lines and attachments are separated |
| 3NF | Transitive dependencies are removed | Independent entities are stored in separate related tables |

## 6. Conclusion

The VectorWatch database is transformed from an unnormalized hospital submission structure into a collection of related tables through 1NF, 2NF and 3NF.

The final 3NF design separates identity management, hospitals, geography, disease surveillance, environmental observations, machine-learning predictions, interventions and public notifications.

This reduces data redundancy, improves consistency and maintains referential integrity through primary and foreign keys.
