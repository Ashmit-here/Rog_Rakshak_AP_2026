

# Query Execution Timings

## Benchmark Environment

- **Database:** PostgreSQL
- **Database name:** `Rog_AP_2026`
- **Dataset:** Synthetic benchmark data
- **Query source:** `dbms/04_queries.sql`
- **Execution method:** `EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)`
- **Executions per query:** 3
- **Total executions:** 90
- **Benchmark timestamp:** `2026-11-23T23:39:56+05:30`

## Results

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
|---|---|---|---:|---:|---:|---:|---|
| [R1](plans/R1.txt) | READ | List all users with their assigned role | 0.928 | 0.299 | 0.265 | 0.497 | Seq Scan |
| [R2](plans/R2.txt) | READ | List hospitals with their geographic location | 0.183 | 0.175 | 0.184 | 0.181 | Seq Scan |
| [R3](plans/R3.txt) | READ | Show hospital users and their membership status | 0.421 | 0.389 | 0.377 | 0.396 | Seq Scan |
| [R4](plans/R4.txt) | READ | Retrieve disease reports with hospital and submitter details | 1.820 | 1.658 | 1.595 | 1.691 | Seq Scan |
| [R5](plans/R5.txt) | READ | Get all observations belonging to one disease report | 0.102 | 0.081 | 0.083 | 0.089 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| [R6](plans/R6.txt) | READ | Daily reported cases by disease | 2.995 | 2.763 | 2.901 | 2.886 | Seq Scan |
| [R7](plans/R7.txt) | READ | Compare suspected and confirmed cases by disease | 2.679 | 2.740 | 2.639 | 2.686 | Seq Scan |
| [R8](plans/R8.txt) | READ | Identify areas with the highest reported case counts | 3.959 | 3.988 | 3.858 | 3.935 | Seq Scan |
| [R9](plans/R9.txt) | READ | Calculate case totals by age group | 1.565 | 1.524 | 1.554 | 1.548 | Seq Scan |
| [R10](plans/R10.txt) | READ | Find the latest weather observation for each area | 4.208 | 4.149 | 4.215 | 4.191 | Seq Scan |
| [R11](plans/R11.txt) | READ | Find areas with high humidity and recent rainfall | 0.796 | 0.766 | 0.812 | 0.791 | Seq Scan |
| [R12](plans/R12.txt) | READ | Calculate vector density by area | 2.034 | 1.725 | 1.778 | 1.846 | Seq Scan |
| [R13](plans/R13.txt) | READ | List active breeding sites that need inspection | 0.392 | 0.370 | 0.367 | 0.376 | Seq Scan |
| [R14](plans/R14.txt) | READ | Display the latest risk prediction for each area and disease | 20.134 | 18.920 | 20.122 | 19.725 | Seq Scan |
| [R15](plans/R15.txt) | READ | List high-risk predictions requiring attention | 2.677 | 2.715 | 2.661 | 2.684 | Seq Scan |
| [R16](plans/R16.txt) | READ | Explain the features contributing to a risk prediction | 0.043 | 0.032 | 0.035 | 0.037 | Index Scan |
| [R17](plans/R17.txt) | READ | Retrieve currently open or acknowledged alerts | 3.131 | 2.966 | 2.965 | 3.021 | Seq Scan |
| [R18](plans/R18.txt) | READ | Find interventions and the field teams assigned to them | 1.419 | 1.376 | 1.374 | 1.390 | Seq Scan |
| [R19](plans/R19.txt) | READ | Summarize intervention completion by status | 2.119 | 2.220 | 2.097 | 2.145 | Seq Scan |
| [R20](plans/R20.txt) | READ | Show public notifications that are currently active | 0.390 | 0.349 | 0.354 | 0.364 | Seq Scan |
| [R21](plans/R21.txt) | READ | List prevention guidelines for each disease | 0.049 | 0.045 | 0.042 | 0.045 | Seq Scan |
| [R22](plans/R22.txt) | READ | Find diseases with no prevention guideline recorded | 0.040 | 0.041 | 0.040 | 0.040 | Seq Scan |
| [R23](plans/R23.txt) | READ | Rank areas by risk score for each disease | 47.048 | 47.750 | 47.147 | 47.315 | Index Scan, Seq Scan, Index Only Scan |
| [R24](plans/R24.txt) | READ | Monthly trend of reported cases | 3.935 | 3.517 | 3.643 | 3.698 | Seq Scan |
| [R25](plans/R25.txt) | READ | Find hospitals that have not submitted a report during the last 30 days | 0.412 | 0.386 | 0.405 | 0.401 | Seq Scan |
| [R26](plans/R26.txt) | READ | Count reports and reported cases submitted by each hospital | 13.145 | 12.972 | 13.021 | 13.046 | Seq Scan |
| [R27](plans/R27.txt) | READ | Show the jurisdiction areas assigned to each medical office | 0.135 | 0.134 | 0.147 | 0.139 | Seq Scan |
| [R28](plans/R28.txt) | READ | Calculate cases per 1,000 population using the latest population estimate | 1.757 | 1.788 | 1.725 | 1.757 | Seq Scan, Subquery Scan |
| [R29](plans/R29.txt) | READ | Find detected hotspots with disease and geographic details | 1.865 | 1.864 | 1.826 | 1.852 | Seq Scan |
| [R30](plans/R30.txt) | READ | List reports with their attachment counts | 2.661 | 2.613 | 2.997 | 2.757 | Seq Scan |

## Notes

- Each of the 30 READ queries was executed three times.
- Average execution time is the arithmetic mean of the three runs.
- Execution plans for all three runs are stored in `dbms/plans/`.
- Scan types are recorded from the generated execution plans.
- R23 uses an index to improve the correlated lookup performance.
- Timings may vary due to caching, system load, hardware, and database configuration.
- Results represent this synthetic dataset and are not universal performance guarantees.

