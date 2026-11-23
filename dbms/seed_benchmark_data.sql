-- Rog Rakshak CP4: Synthetic benchmark dataset
-- Target database: Rog_AP_2026
-- Run only once on a freshly created schema.
-- All generated records are synthetic.

BEGIN;

-- 1. Roles
INSERT INTO roles (role_id, role_name, description)
SELECT
    'ROLE-' || role_name,
    role_name,
    'Synthetic benchmark role'
FROM (VALUES
    ('ADMIN'), ('HOSPITAL'), ('MO'), ('PUBLIC')
) AS x(role_name);

-- 2. Users
INSERT INTO users (
    user_id, role_id, full_name, email, password_hash, account_status
)
SELECT
    'USR-' || lpad(g::text, 4, '0'),
    CASE
        WHEN g <= 5 THEN 'ROLE-ADMIN'
        WHEN g <= 130 THEN 'ROLE-HOSPITAL'
        WHEN g <= 180 THEN 'ROLE-MO'
        ELSE 'ROLE-PUBLIC'
    END,
    'Synthetic User ' || g,
    'user' || g || '@example.test',
    'synthetic_hash_' || g,
    CASE WHEN g % 20 = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END
FROM generate_series(1, 200) AS g;

-- 3. States
INSERT INTO states (state_id, state_name)
SELECT
    'ST-' || lpad(g::text, 2, '0'),
    'Synthetic State ' || g
FROM generate_series(1, 5) AS g;

-- 4. Districts
INSERT INTO districts (district_id, district_name, state_id)
SELECT
    'DIST-' || lpad(g::text, 3, '0'),
    'Synthetic District ' || g,
    'ST-' || lpad((((g - 1) % 5) + 1)::text, 2, '0')
FROM generate_series(1, 20) AS g;

-- 5. Areas
INSERT INTO areas (area_id, area_name, district_id, area_type, boundary)
SELECT
    'AREA-' || lpad(g::text, 4, '0'),
    'Synthetic Area ' || g,
    'DIST-' || lpad((((g - 1) % 20) + 1)::text, 3, '0'),
    CASE WHEN g % 3 = 0 THEN 'RURAL' ELSE 'URBAN' END,
    'Synthetic boundary ' || g
FROM generate_series(1, 100) AS g;

-- 6. Hospitals
INSERT INTO hospitals (
    hospital_id, registration_no, hospital_name, address,
    area_id, contact_email, hospital_status
)
SELECT
    'HOSP-' || lpad(g::text, 3, '0'),
    'REG-' || lpad(g::text, 4, '0'),
    'Synthetic Hospital ' || g,
    'Synthetic address ' || g,
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    'hospital' || g || '@example.test',
    CASE WHEN g % 10 = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END
FROM generate_series(1, 50) AS g;

-- 7. Diseases
INSERT INTO diseases (disease_id, disease_name, pathogen_type, vector_type)
SELECT
    'DIS-' || lpad(g::text, 2, '0'),
    'Synthetic Disease ' || g,
    CASE WHEN g % 2 = 0 THEN 'VIRAL' ELSE 'PARASITIC' END,
    CASE WHEN g % 2 = 0 THEN 'MOSQUITO' ELSE 'OTHER' END
FROM generate_series(1, 8) AS g;

-- 8. Disease reports
INSERT INTO disease_reports (
    report_id, hospital_id, submitted_by, submitted_at, report_status
)
SELECT
    'REP-' || (10000 + g),
    'HOSP-' || lpad((((g - 1) % 50) + 1)::text, 3, '0'),
    'USR-' || lpad((11 + ((g - 1) % 120))::text, 4, '0'),
    CURRENT_TIMESTAMP - ((g % 540) * INTERVAL '1 day'),
    CASE
        WHEN g % 5 = 0 THEN 'PENDING'
        WHEN g % 5 = 1 THEN 'REJECTED'
        ELSE 'VERIFIED'
    END
FROM generate_series(1, 5000) AS g;

-- 9. Disease report lines: 3 lines per report
INSERT INTO disease_report_lines (
    report_id, line_no, disease_id, area_id, report_date,
    age_group, case_classification, case_count
)
SELECT
    'REP-' || (10000 + g),
    line_no,
    'DIS-' || lpad((((g + line_no - 2) % 8) + 1)::text, 2, '0'),
    'AREA-' || lpad((((g * 3 + line_no - 2) % 100) + 1)::text, 4, '0'),
    CURRENT_DATE - ((g + line_no) % 540),
    (ARRAY['0-5', '6-17', '18-35', '36-59', '60+'])
        [((g + line_no - 2) % 5) + 1],
    CASE WHEN (g + line_no) % 2 = 0
         THEN 'CONFIRMED' ELSE 'SUSPECTED' END,
    ((g * line_no) % 40) + 1
FROM generate_series(1, 5000) AS g
CROSS JOIN generate_series(1, 3) AS line_no;

-- 10. Report attachments
INSERT INTO report_attachments (
    attachment_id, report_id, file_name, storage_key,
    content_type, uploaded_at
)
SELECT
    'ATT-' || lpad(g::text, 5, '0'),
    'REP-' || (10000 + g),
    'report_' || g || '.pdf',
    'synthetic/reports/' || g,
    'application/pdf',
    CURRENT_TIMESTAMP - ((g % 180) * INTERVAL '1 day')
FROM generate_series(1, 2500) AS g;

-- 11. Hospital users
INSERT INTO hospital_users (
    hospital_id, user_id, membership_status, joined_at
)
SELECT
    'HOSP-' || lpad((((g - 1) % 50) + 1)::text, 3, '0'),
    'USR-' || lpad((6 + ((g - 1) % 195))::text, 4, '0'),
    CASE WHEN g % 10 = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END,
    CURRENT_DATE - (g % 500)
FROM generate_series(1, 300) AS g;

-- 12. Medical offices
INSERT INTO medical_offices (
    medical_office_id, office_name, district_id, office_contact, office_status
)
SELECT
    'MO-' || lpad(g::text, 3, '0'),
    'Synthetic Medical Office ' || g,
    'DIST-' || lpad(g::text, 3, '0'),
    'office' || g || '@example.test',
    'ACTIVE'
FROM generate_series(1, 20) AS g;

-- 13. Medical office jurisdiction areas
-- Each office receives five areas from its own district.
INSERT INTO medical_office_areas (
    medical_office_id, area_id, valid_from, valid_to
)
SELECT
    'MO-' || lpad(office_no::text, 3, '0'),
    'AREA-' || lpad((office_no + area_offset * 20)::text, 4, '0'),
    CURRENT_DATE - 365,
    NULL
FROM generate_series(1, 20) AS office_no
CROSS JOIN generate_series(0, 4) AS area_offset;

-- 14. Weather observations
INSERT INTO weather_observations (
    weather_id, area_id, observed_at, temperature_c,
    humidity_percent, rainfall_mm, source
)
SELECT
    'WEA-' || lpad(g::text, 5, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    CURRENT_TIMESTAMP - ((g % 100) * INTERVAL '1 day'),
    20 + (g % 18),
    55 + (g % 41),
    CASE WHEN g % 4 = 0 THEN 12 + (g % 20) ELSE (g % 8)::numeric END,
    'Synthetic weather station'
FROM generate_series(1, 10000) AS g;

-- 15. Vector observations
INSERT INTO vector_observations (
    vector_id, area_id, observed_at, species,
    adult_count, larvae_count, sampling_method
)
SELECT
    'VEC-' || lpad(g::text, 5, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    CURRENT_TIMESTAMP - ((g % 120) * INTERVAL '1 day'),
    CASE WHEN g % 2 = 0 THEN 'Aedes aegypti' ELSE 'Anopheles' END,
    g % 150,
    g % 100,
    CASE WHEN g % 2 = 0 THEN 'TRAP' ELSE 'FIELD_SAMPLE' END
FROM generate_series(1, 10000) AS g;

-- 16. Breeding sites
INSERT INTO breeding_sites (
    breeding_site_id, area_id, site_type, location,
    site_status, last_inspected_at
)
SELECT
    'BS-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    CASE WHEN g % 2 = 0 THEN 'WATER_TANK' ELSE 'DRAIN' END,
    'Synthetic location ' || g,
    CASE WHEN g % 5 = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END,
    CURRENT_TIMESTAMP - ((g % 180) * INTERVAL '1 day')
FROM generate_series(1, 1200) AS g;

-- 17. Population estimates: two years per area
INSERT INTO population_estimates (
    population_id, area_id, reference_year, population_count, source
)
SELECT
    'POP-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    2025 + ((g - 1) / 100),
    10000 + (g * 137),
    'Synthetic census estimate'
FROM generate_series(1, 200) AS g;

-- 18. ML models
INSERT INTO ml_models (
    model_id, model_name, version, algorithm, trained_at, artifact_uri
)
SELECT
    'MODEL-' || lpad(g::text, 2, '0'),
    'Synthetic Risk Model ' || g,
    '1.' || g,
    CASE WHEN g % 2 = 0 THEN 'RANDOM_FOREST' ELSE 'GRADIENT_BOOSTING' END,
    CURRENT_TIMESTAMP - (g * INTERVAL '30 days'),
    'synthetic/models/model_' || g
FROM generate_series(1, 3) AS g;

-- 19. Insert risk predictions (20,000 rows)
INSERT INTO risk_predictions (
    prediction_id,
    area_id,
    disease_id,
    model_id,
    generated_at,
    forecast_start,
    forecast_end,
    risk_score,
    risk_level
)
SELECT
    CASE
        WHEN g < 1000 THEN 'RP-' || lpad(g::text, 3, '0')
        ELSE 'RP-' || g::text
    END,
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    'DIS-' || lpad(((((g - 1) / 100) % 8) + 1)::text, 2, '0'),
    'MODEL-' || lpad((((g - 1) % 3) + 1)::text, 2, '0'),
    CURRENT_TIMESTAMP - ((g % 25) * INTERVAL '1 day'),
    CURRENT_DATE + (g % 7),
    CURRENT_DATE + (g % 7) + 7,
    ROUND((((g * 37) % 100) / 100.0)::numeric, 2),
    CASE
        WHEN (g % 100) >= 75 THEN 'HIGH'
        WHEN (g % 100) >= 40 THEN 'MEDIUM'
        ELSE 'LOW'
    END
FROM generate_series(1, 20000) AS g;
 

-- 20. Insert prediction features (60,000 rows)
INSERT INTO prediction_features (
    prediction_id,
    feature_name,
    feature_value,
    contribution_value
)
SELECT
    CASE
        WHEN g < 1000 THEN 'RP-' || lpad(g::text, 3, '0')
        ELSE 'RP-' || g::text
    END,
    feature.feature_name,
    feature.feature_value,
    feature.contribution_value
FROM generate_series(1, 20000) AS g
CROSS JOIN LATERAL (
    VALUES
        (
            'humidity',
            ((g * 13) % 100)::numeric,
            (((g * 7) % 100) / 100.0)::numeric
        ),
        (
            'rainfall',
            ((g * 17) % 200)::numeric,
            (((g * 11) % 100) / 100.0)::numeric
        ),
        (
            'vector_density',
            ((g * 19) % 500)::numeric,
            (((g * 13) % 100) / 100.0)::numeric
        )
) AS feature(
    feature_name,
    feature_value,
    contribution_value
);

-- 21. Hotspots
INSERT INTO hotspots (
    hotspot_id, area_id, disease_id, detected_at, detection_method, intensity
)
SELECT
    'HS-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    'DIS-' || lpad((((g - 1) % 8) + 1)::text, 2, '0'),
    CURRENT_TIMESTAMP - ((g % 180) * INTERVAL '1 day'),
    CASE WHEN g % 2 = 0 THEN 'MODEL' ELSE 'FIELD_REPORT' END,
    (g % 100)::numeric / 10
FROM generate_series(1, 3000) AS g;

-- 22. Insert alerts (5,000 rows)
INSERT INTO alerts (
    alert_id,
    area_id,
    disease_id,
    prediction_id,
    created_at,
    severity,
    status
)
SELECT
    'ALT-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    'DIS-' || lpad(((((g - 1) / 100) % 8) + 1)::text, 2, '0'),
    CASE
        WHEN ((g - 1) % 20000) + 1 < 1000
        THEN 'RP-' || lpad((((g - 1) % 20000) + 1)::text, 3, '0')
        ELSE 'RP-' || (((g - 1) % 20000) + 1)::text
    END,
    CURRENT_TIMESTAMP - ((g % 60) * INTERVAL '1 day'),
    CASE
        WHEN g % 3 = 0 THEN 'HIGH'
        WHEN g % 3 = 1 THEN 'MEDIUM'
        ELSE 'LOW'
    END,
    CASE
        WHEN g % 3 = 0 THEN 'OPEN'
        WHEN g % 3 = 1 THEN 'ACKNOWLEDGED'
        ELSE 'RESOLVED'
    END
FROM generate_series(1, 5000) AS g;

-- 23. Interventions: 100 areas distributed across their matching offices
INSERT INTO interventions (
    intervention_id, area_id, medical_office_id,
    intervention_type, priority, status, created_at
)
SELECT
    'INT-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad(
        ((((g - 1) % 20) + 1) + (((g - 1) / 20) % 5) * 20)::text,
        4, '0'
    ),
    'MO-' || lpad((((g - 1) % 20) + 1)::text, 3, '0'),
    CASE WHEN g % 2 = 0 THEN 'FOGGING' ELSE 'SOURCE_REDUCTION' END,
    CASE WHEN g % 3 = 0 THEN 'HIGH' ELSE 'NORMAL' END,
    CASE
        WHEN g % 3 = 0 THEN 'COMPLETED'
        WHEN g % 3 = 1 THEN 'IN_PROGRESS'
        ELSE 'PENDING'
    END,
    CURRENT_TIMESTAMP - ((g % 180) * INTERVAL '1 day')
FROM generate_series(1, 2000) AS g;

-- 24. Field teams: five teams per medical office
INSERT INTO field_teams (
    team_id, medical_office_id, team_name, members_count
)
SELECT
    'TEAM-' || lpad(g::text, 3, '0'),
    'MO-' || lpad((((g - 1) / 5) + 1)::text, 3, '0'),
    'Synthetic Field Team ' || g,
    3 + (g % 6)
FROM generate_series(1, 100) AS g;

-- 25. Intervention assignments: team office matches intervention office
INSERT INTO intervention_assignments (
    intervention_id, team_id, assigned_at
)
SELECT
    'INT-' || lpad(g::text, 4, '0'),
    'TEAM-' || lpad(
        (
            (((g - 1) % 20) * 5)
            + (((g - 1) / 20) % 5)
            + 1
        )::text,
        3, '0'
    ),
    CURRENT_TIMESTAMP - ((g % 90) * INTERVAL '1 day')
FROM generate_series(1, 2000) AS g;

-- 26. Intervention reports
INSERT INTO intervention_reports (
    intervention_report_id, intervention_id, submitted_by,
    outcome, notes, completed_at
)
SELECT
    'IR-' || lpad(g::text, 4, '0'),
    'INT-' || lpad(g::text, 4, '0'),
    'USR-' || lpad((131 + ((g - 1) % 50))::text, 4, '0'),
    CASE WHEN g % 2 = 0 THEN 'SUCCESSFUL' ELSE 'PARTIAL' END,
    'Synthetic intervention report ' || g,
    CURRENT_TIMESTAMP - ((g % 120) * INTERVAL '1 day')
FROM generate_series(1, 1200) AS g;

-- 27. Public notifications
INSERT INTO public_notifications (
    notification_id, area_id, disease_id, title, published_at, expires_at
)
SELECT
    'PN-' || lpad(g::text, 4, '0'),
    'AREA-' || lpad((((g - 1) % 100) + 1)::text, 4, '0'),
    'DIS-' || lpad((((g - 1) % 8) + 1)::text, 2, '0'),
    'Synthetic prevention notification ' || g,
    CURRENT_TIMESTAMP - ((g % 30) * INTERVAL '1 day'),
    CASE
        WHEN g % 4 = 0 THEN NULL
        ELSE CURRENT_TIMESTAMP + ((g % 20) * INTERVAL '1 day')
    END
FROM generate_series(1, 1000) AS g;

-- 28. Prevention guidelines for six diseases.
-- Diseases 7 and 8 intentionally have no guideline for query Q22.
INSERT INTO prevention_guidelines (
    guideline_id, disease_id, title, source_name, updated_at
)
SELECT
    'GUIDE-' || lpad(g::text, 3, '0'),
    'DIS-' || lpad(g::text, 2, '0'),
    'Synthetic prevention guideline ' || g,
    'Synthetic Public Health Authority',
    CURRENT_TIMESTAMP - (g * INTERVAL '15 days')
FROM generate_series(1, 6) AS g;

-- Update planner statistics after loading the dataset.
ANALYZE;

COMMIT;