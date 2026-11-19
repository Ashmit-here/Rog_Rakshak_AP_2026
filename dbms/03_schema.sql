
CREATE TABLE roles (
    role_id text PRIMARY KEY,
    role_name text NOT NULL,
    description text
);

CREATE TABLE users (
    user_id text PRIMARY KEY,
    role_id text REFERENCES roles(role_id),
    full_name text NOT NULL,
    email text NOT NULL,
    password_hash text,
    account_status text
);

CREATE TABLE states (
    state_id text PRIMARY KEY,
    state_name text NOT NULL
);

CREATE TABLE districts (
    district_id text PRIMARY KEY,
    district_name text NOT NULL,
    state_id text NOT NULL REFERENCES states(state_id)
);

CREATE TABLE areas (
    area_id text PRIMARY KEY,
    area_name text NOT NULL,
    district_id text NOT NULL REFERENCES districts(district_id),
    area_type text,
    boundary text
);

-- Hospitals (created after areas because of the foreign key).
CREATE TABLE hospitals (
    hospital_id text PRIMARY KEY,
    registration_no text UNIQUE,
    hospital_name text NOT NULL,
    address text,
    area_id text REFERENCES areas(area_id),
    contact_email text,
    hospital_status text
);

CREATE TABLE diseases (
    disease_id text PRIMARY KEY,
    disease_name text NOT NULL,
    pathogen_type text,
    vector_type text
);

CREATE TABLE disease_reports (
    report_id text PRIMARY KEY,
    hospital_id text NOT NULL REFERENCES hospitals(hospital_id),
    submitted_by text NOT NULL REFERENCES users(user_id),
    submitted_at timestamptz NOT NULL,
    report_status text NOT NULL
);

CREATE TABLE disease_report_lines (
    report_id text NOT NULL REFERENCES disease_reports(report_id),
    line_no integer NOT NULL,
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    area_id text NOT NULL REFERENCES areas(area_id),
    report_date date NOT NULL,
    age_group text NOT NULL,
    case_classification text NOT NULL,
    case_count integer NOT NULL,
    PRIMARY KEY (report_id, line_no)
);

CREATE TABLE report_attachments (
    attachment_id text PRIMARY KEY,
    report_id text NOT NULL REFERENCES disease_reports(report_id),
    file_name text NOT NULL,
    storage_key text NOT NULL,
    content_type text NOT NULL,
    uploaded_at timestamptz
);

-- Hospital access.
CREATE TABLE hospital_users (
    hospital_id text NOT NULL REFERENCES hospitals(hospital_id),
    user_id text NOT NULL REFERENCES users(user_id),
    membership_status text,
    joined_at timestamptz,
    PRIMARY KEY (hospital_id, user_id)
);

-- Medical offices and time-bounded area jurisdiction.
CREATE TABLE medical_offices (
    medical_office_id text PRIMARY KEY,
    office_name text NOT NULL,
    district_id text NOT NULL REFERENCES districts(district_id),
    office_contact text,
    office_status text
);

CREATE TABLE medical_office_areas (
    medical_office_id text NOT NULL REFERENCES medical_offices(medical_office_id),
    area_id text NOT NULL REFERENCES areas(area_id),
    valid_from date NOT NULL,
    valid_to date,
    PRIMARY KEY (medical_office_id, area_id, valid_from)
);

-- Environmental and vector observations.
CREATE TABLE weather_observations (
    weather_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    observed_at timestamptz NOT NULL,
    temperature_c numeric,
    humidity_percent numeric,
    rainfall_mm numeric,
    source text
);

CREATE TABLE vector_observations (
    vector_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    observed_at timestamptz NOT NULL,
    species text NOT NULL,
    adult_count integer,
    larvae_count integer,
    sampling_method text
);

CREATE TABLE breeding_sites (
    breeding_site_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    site_type text,
    location text,
    site_status text,
    last_inspected_at timestamptz
);

CREATE TABLE population_estimates (
    population_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    reference_year integer NOT NULL,
    population_count bigint NOT NULL,
    source text
);

-- Models, predictions, and related risk signals.
CREATE TABLE ml_models (
    model_id text PRIMARY KEY,
    model_name text NOT NULL,
    version text NOT NULL,
    algorithm text,
    trained_at timestamptz,
    artifact_uri text
);

CREATE TABLE risk_predictions (
    prediction_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    model_id text NOT NULL REFERENCES ml_models(model_id),
    generated_at timestamptz NOT NULL,
    forecast_start date NOT NULL,
    forecast_end date NOT NULL,
    risk_score numeric NOT NULL,
    risk_level text NOT NULL
);

CREATE TABLE prediction_features (
    prediction_id text NOT NULL REFERENCES risk_predictions(prediction_id),
    feature_name text NOT NULL,
    feature_value numeric,
    contribution_value numeric,
    PRIMARY KEY (prediction_id, feature_name)
);

CREATE TABLE hotspots (
    hotspot_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    detected_at timestamptz NOT NULL,
    detection_method text,
    intensity numeric
);

CREATE TABLE alerts (
    alert_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    prediction_id text REFERENCES risk_predictions(prediction_id),
    created_at timestamptz NOT NULL,
    severity text,
    status text
);

-- Field response and public guidance.
CREATE TABLE interventions (
    intervention_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    medical_office_id text NOT NULL REFERENCES medical_offices(medical_office_id),
    intervention_type text,
    priority text,
    status text,
    created_at timestamptz
);

CREATE TABLE field_teams (
    team_id text PRIMARY KEY,
    medical_office_id text NOT NULL REFERENCES medical_offices(medical_office_id),
    team_name text NOT NULL,
    members_count integer
);

CREATE TABLE intervention_assignments (
    intervention_id text NOT NULL REFERENCES interventions(intervention_id),
    team_id text NOT NULL REFERENCES field_teams(team_id),
    assigned_at timestamptz,
    PRIMARY KEY (intervention_id, team_id)
);

CREATE TABLE intervention_reports (
    intervention_report_id text PRIMARY KEY,
    intervention_id text NOT NULL REFERENCES interventions(intervention_id),
    submitted_by text NOT NULL REFERENCES users(user_id),
    outcome text,
    notes text,
    completed_at timestamptz
);

CREATE TABLE public_notifications (
    notification_id text PRIMARY KEY,
    area_id text NOT NULL REFERENCES areas(area_id),
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    title text NOT NULL,
    published_at timestamptz,
    expires_at timestamptz
);

CREATE TABLE prevention_guidelines (
    guideline_id text PRIMARY KEY,
    disease_id text NOT NULL REFERENCES diseases(disease_id),
    title text NOT NULL,
    source_name text,
    updated_at timestamptz
);
