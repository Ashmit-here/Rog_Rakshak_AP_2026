-- Rog Rakshak / VectorWatch
-- File: dbms/04_queries.sql
-- PostgreSQL queries based on dbms/03_schema.sql.
-- Run after creating the schema and loading data.

-- 1. List all users with their assigned role
SELECT u.user_id, u.full_name, u.email, r.role_name, u.account_status
FROM users u
LEFT JOIN roles r ON r.role_id = u.role_id
ORDER BY u.full_name;

-- 2. List hospitals with their geographic location
SELECT h.hospital_id, h.hospital_name, h.registration_no, h.address,
       a.area_name, d.district_name, s.state_name, h.hospital_status
FROM hospitals h
LEFT JOIN areas a ON a.area_id = h.area_id
LEFT JOIN districts d ON d.district_id = a.district_id
LEFT JOIN states s ON s.state_id = d.state_id
ORDER BY s.state_name, d.district_name, h.hospital_name;

-- 3. Show hospital users and their membership status
SELECT h.hospital_name, u.user_id, u.full_name, u.email,
       hu.membership_status, hu.joined_at
FROM hospital_users hu
JOIN hospitals h ON h.hospital_id = hu.hospital_id
JOIN users u ON u.user_id = hu.user_id
ORDER BY h.hospital_name, u.full_name;

-- 4. Retrieve disease reports with hospital and submitter details
SELECT dr.report_id, dr.submitted_at, h.hospital_name,
       u.full_name AS submitted_by, dr.report_status
FROM disease_reports dr
JOIN hospitals h ON h.hospital_id = dr.hospital_id
JOIN users u ON u.user_id = dr.submitted_by
ORDER BY dr.submitted_at DESC;

-- 5. Get all observations belonging to one disease report
SELECT dr.report_id, dr.submitted_at, d.disease_name, a.area_name,
       drl.report_date, drl.age_group, drl.case_classification, drl.case_count
FROM disease_reports dr
JOIN disease_report_lines drl ON drl.report_id = dr.report_id
JOIN diseases d ON d.disease_id = drl.disease_id
JOIN areas a ON a.area_id = drl.area_id
WHERE dr.report_id = 'REP-11016'
ORDER BY drl.line_no;

-- 6. Daily reported cases by disease
SELECT drl.report_date, d.disease_name, SUM(drl.case_count) AS total_cases
FROM disease_report_lines drl
JOIN diseases d ON d.disease_id = drl.disease_id
GROUP BY drl.report_date, d.disease_name
ORDER BY drl.report_date DESC, total_cases DESC;

-- 7. Compare suspected and confirmed cases by disease
SELECT d.disease_name,
       SUM(drl.case_count) FILTER (
           WHERE drl.case_classification = 'SUSPECTED'
       ) AS suspected_cases,
       SUM(drl.case_count) FILTER (
           WHERE drl.case_classification = 'CONFIRMED'
       ) AS confirmed_cases
FROM disease_report_lines drl
JOIN diseases d ON d.disease_id = drl.disease_id
GROUP BY d.disease_id, d.disease_name
ORDER BY confirmed_cases DESC NULLS LAST;

-- 8. Identify areas with the highest reported case counts
SELECT a.area_id, a.area_name, d.district_name,
       SUM(drl.case_count) AS total_cases
FROM disease_report_lines drl
JOIN areas a ON a.area_id = drl.area_id
JOIN districts d ON d.district_id = a.district_id
GROUP BY a.area_id, a.area_name, d.district_name
ORDER BY total_cases DESC
LIMIT 10;

-- 9. Calculate case totals by age group
SELECT drl.age_group, SUM(drl.case_count) AS total_cases
FROM disease_report_lines drl
GROUP BY drl.age_group
ORDER BY total_cases DESC;

-- 10. Find the latest weather observation for each area
SELECT DISTINCT ON (a.area_id)
       a.area_id, a.area_name, wo.observed_at, wo.temperature_c,
       wo.humidity_percent, wo.rainfall_mm, wo.source
FROM weather_observations wo
JOIN areas a ON a.area_id = wo.area_id
ORDER BY a.area_id, wo.observed_at DESC;

-- 11. Find areas with high humidity and recent rainfall
SELECT a.area_id, a.area_name, wo.observed_at,
       wo.humidity_percent, wo.rainfall_mm
FROM weather_observations wo
JOIN areas a ON a.area_id = wo.area_id
WHERE wo.humidity_percent >= 70
  AND wo.rainfall_mm >= 10
  AND wo.observed_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
ORDER BY wo.rainfall_mm DESC, wo.humidity_percent DESC;

-- 12. Calculate vector density by area
SELECT
    a.area_id,
    a.area_name,
    SUM(COALESCE(vo.adult_count, 0)) AS adult_vectors,
    SUM(COALESCE(vo.larvae_count, 0)) AS larvae
FROM vector_observations vo
JOIN areas a ON a.area_id = vo.area_id
GROUP BY a.area_id, a.area_name
ORDER BY
    SUM(COALESCE(vo.adult_count, 0))
    + SUM(COALESCE(vo.larvae_count, 0)) DESC;

-- 13. List active breeding sites that need inspection
SELECT bs.breeding_site_id, bs.site_type, bs.site_status,
       bs.last_inspected_at, a.area_name, d.district_name
FROM breeding_sites bs
JOIN areas a ON a.area_id = bs.area_id
JOIN districts d ON d.district_id = a.district_id
WHERE bs.site_status = 'ACTIVE'
ORDER BY bs.last_inspected_at ASC NULLS FIRST;

-- 14. Display the latest risk prediction for each area and disease
SELECT DISTINCT ON (rp.area_id, rp.disease_id)
       a.area_name, dis.disease_name, rp.generated_at,
       rp.forecast_start, rp.forecast_end, rp.risk_score,
       rp.risk_level, m.model_name, m.version AS model_version
FROM risk_predictions rp
JOIN areas a ON a.area_id = rp.area_id
JOIN diseases dis ON dis.disease_id = rp.disease_id
JOIN ml_models m ON m.model_id = rp.model_id
ORDER BY rp.area_id, rp.disease_id, rp.generated_at DESC;

-- 15. List high-risk predictions requiring attention
SELECT rp.prediction_id, a.area_name, d.disease_name,
       rp.risk_score, rp.risk_level, rp.generated_at,
       rp.forecast_start, rp.forecast_end
FROM risk_predictions rp
JOIN areas a ON a.area_id = rp.area_id
JOIN diseases d ON d.disease_id = rp.disease_id
WHERE rp.risk_level = 'HIGH'
ORDER BY rp.risk_score DESC, rp.generated_at DESC;

-- 16. Explain the features contributing to a risk prediction
SELECT pf.prediction_id, pf.feature_name,
       pf.feature_value, pf.contribution_value
FROM prediction_features pf
WHERE pf.prediction_id = 'RP-001'
ORDER BY ABS(pf.contribution_value) DESC NULLS LAST;

-- 17. Retrieve currently open or acknowledged alerts
SELECT al.alert_id, a.area_name, d.disease_name, al.severity,
       al.status, al.created_at, rp.risk_score
FROM alerts al
JOIN areas a ON a.area_id = al.area_id
JOIN diseases d ON d.disease_id = al.disease_id
LEFT JOIN risk_predictions rp ON rp.prediction_id = al.prediction_id
WHERE al.status IN ('OPEN', 'ACKNOWLEDGED')
ORDER BY al.created_at DESC;

-- 18. Find interventions and the field teams assigned to them
SELECT i.intervention_id, a.area_name, i.intervention_type,
       i.priority, i.status, mo.office_name, ft.team_name, ia.assigned_at
FROM interventions i
JOIN areas a ON a.area_id = i.area_id
JOIN medical_offices mo ON mo.medical_office_id = i.medical_office_id
LEFT JOIN intervention_assignments ia ON ia.intervention_id = i.intervention_id
LEFT JOIN field_teams ft ON ft.team_id = ia.team_id
ORDER BY i.created_at DESC NULLS LAST, i.priority;

-- 19. Summarize intervention completion by status
SELECT
    i.status,
    COUNT(DISTINCT i.intervention_id) AS intervention_count,
    COUNT(DISTINCT ir.intervention_report_id) AS submitted_reports
FROM interventions i
LEFT JOIN intervention_reports ir
    ON ir.intervention_id = i.intervention_id
GROUP BY i.status
ORDER BY intervention_count DESC;

-- 20. Show public notifications that are currently active
SELECT pn.notification_id, pn.title, d.disease_name, a.area_name,
       pn.published_at, pn.expires_at
FROM public_notifications pn
JOIN diseases d ON d.disease_id = pn.disease_id
JOIN areas a ON a.area_id = pn.area_id
WHERE pn.published_at <= CURRENT_TIMESTAMP
  AND (pn.expires_at IS NULL OR pn.expires_at >= CURRENT_TIMESTAMP)
ORDER BY pn.published_at DESC;

-- 21. List prevention guidelines for each disease
SELECT d.disease_name, pg.title AS guideline_title,
       pg.source_name, pg.updated_at
FROM prevention_guidelines pg
JOIN diseases d ON d.disease_id = pg.disease_id
ORDER BY d.disease_name, pg.updated_at DESC NULLS LAST;

-- 22. Find diseases with no prevention guideline recorded
SELECT d.disease_id, d.disease_name
FROM diseases d
WHERE NOT EXISTS (
    SELECT 1
    FROM prevention_guidelines pg
    WHERE pg.disease_id = d.disease_id
)
ORDER BY d.disease_name;

-- 23. Rank areas by risk score for each disease
SELECT d.disease_name, a.area_name, rp.risk_score, rp.risk_level,
       RANK() OVER (
           PARTITION BY rp.disease_id
           ORDER BY rp.risk_score DESC
       ) AS risk_rank
FROM risk_predictions rp
JOIN diseases d ON d.disease_id = rp.disease_id
JOIN areas a ON a.area_id = rp.area_id
WHERE rp.generated_at = (
    SELECT MAX(rp2.generated_at)
    FROM risk_predictions rp2
    WHERE rp2.area_id = rp.area_id
      AND rp2.disease_id = rp.disease_id
)
ORDER BY d.disease_name, risk_rank;

-- 24. Monthly trend of reported cases
SELECT DATE_TRUNC('month', drl.report_date)::date AS report_month,
       d.disease_name, SUM(drl.case_count) AS total_cases
FROM disease_report_lines drl
JOIN diseases d ON d.disease_id = drl.disease_id
GROUP BY DATE_TRUNC('month', drl.report_date), d.disease_name
ORDER BY report_month, d.disease_name;

-- 25. Find hospitals that have not submitted a report during the last 30 days
SELECT h.hospital_id, h.hospital_name, h.contact_email
FROM hospitals h
WHERE NOT EXISTS (
    SELECT 1
    FROM disease_reports dr
    WHERE dr.hospital_id = h.hospital_id
      AND dr.submitted_at >= CURRENT_TIMESTAMP - INTERVAL '30 days'
)
ORDER BY h.hospital_name;

-- 26. Count reports and reported cases submitted by each hospital
SELECT h.hospital_id, h.hospital_name,
       COUNT(DISTINCT dr.report_id) AS report_count,
       COALESCE(SUM(drl.case_count), 0) AS reported_cases
FROM hospitals h
LEFT JOIN disease_reports dr ON dr.hospital_id = h.hospital_id
LEFT JOIN disease_report_lines drl ON drl.report_id = dr.report_id
GROUP BY h.hospital_id, h.hospital_name
ORDER BY reported_cases DESC, report_count DESC;

-- 27. Show the jurisdiction areas assigned to each medical office
SELECT mo.medical_office_id, mo.office_name, a.area_id, a.area_name,
       moa.valid_from, moa.valid_to
FROM medical_office_areas moa
JOIN medical_offices mo ON mo.medical_office_id = moa.medical_office_id
JOIN areas a ON a.area_id = moa.area_id
WHERE moa.valid_to IS NULL OR moa.valid_to >= CURRENT_DATE
ORDER BY mo.office_name, a.area_name;

-- 28. Calculate cases per 1,000 population using the latest population estimate
WITH latest_population AS (
    SELECT DISTINCT ON (area_id)
           area_id, population_count, reference_year
    FROM population_estimates
    ORDER BY area_id, reference_year DESC
),
area_cases AS (
    SELECT area_id, SUM(case_count) AS total_cases
    FROM disease_report_lines
    GROUP BY area_id
)
SELECT a.area_id, a.area_name, lp.reference_year, lp.population_count,
       COALESCE(ac.total_cases, 0) AS total_cases,
       ROUND(
           1000.0 * COALESCE(ac.total_cases, 0) / NULLIF(lp.population_count, 0),
           2
       ) AS cases_per_1000_people
FROM areas a
JOIN latest_population lp ON lp.area_id = a.area_id
LEFT JOIN area_cases ac ON ac.area_id = a.area_id
ORDER BY cases_per_1000_people DESC;

-- 29. Find detected hotspots with disease and geographic details
SELECT hs.hotspot_id, hs.detected_at, hs.detection_method, hs.intensity,
       a.area_name, d.district_name, dis.disease_name
FROM hotspots hs
JOIN areas a ON a.area_id = hs.area_id
JOIN districts d ON d.district_id = a.district_id
JOIN diseases dis ON dis.disease_id = hs.disease_id
ORDER BY hs.intensity DESC NULLS LAST, hs.detected_at DESC;

-- 30. List reports with their attachment counts
SELECT dr.report_id, h.hospital_name, dr.submitted_at,
       COUNT(ra.attachment_id) AS attachment_count
FROM disease_reports dr
JOIN hospitals h ON h.hospital_id = dr.hospital_id
LEFT JOIN report_attachments ra ON ra.report_id = dr.report_id
GROUP BY dr.report_id, h.hospital_name, dr.submitted_at
ORDER BY dr.submitted_at DESC;
