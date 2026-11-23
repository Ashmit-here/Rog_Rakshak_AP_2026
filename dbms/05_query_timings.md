# Query Execution Timings

## Benchmark environment

- Database: PostgreSQL
- Database name: `Rog_AP_2026`
- Dataset: Synthetic benchmark data
- Query source: `dbms/04_queries.sql`
- Execution method: `EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)`
- Executions per query: 1
- Benchmark timestamp: `2026-11-23T23:02:21+05:30`

## Results

| Query | Planning Time (ms) | Execution Time (ms) | Execution Plan |
|---|---:|---:|---|
| Q01 | 0.409 | 0.709 | [View plan](plans/Q01.txt) |
| Q02 | 1.399 | 0.185 | [View plan](plans/Q02.txt) |
| Q03 | 0.656 | 0.487 | [View plan](plans/Q03.txt) |
| Q04 | 0.565 | 2.255 | [View plan](plans/Q04.txt) |
| Q05 | 0.683 | 0.107 | [View plan](plans/Q05.txt) |
| Q06 | 0.332 | 3.770 | [View plan](plans/Q06.txt) |
| Q07 | 0.301 | 3.366 | [View plan](plans/Q07.txt) |
| Q08 | 0.442 | 4.661 | [View plan](plans/Q08.txt) |
| Q09 | 0.179 | 1.824 | [View plan](plans/Q09.txt) |
| Q10 | 0.336 | 4.521 | [View plan](plans/Q10.txt) |
| Q11 | 0.336 | 0.861 | [View plan](plans/Q11.txt) |
| Q12 | 0.326 | 1.870 | [View plan](plans/Q12.txt) |
| Q13 | 0.397 | 0.367 | [View plan](plans/Q13.txt) |
| Q14 | 0.481 | 18.154 | [View plan](plans/Q14.txt) |
| Q15 | 0.372 | 2.653 | [View plan](plans/Q15.txt) |
| Q16 | 0.176 | 0.038 | [View plan](plans/Q16.txt) |
| Q17 | 0.519 | 3.022 | [View plan](plans/Q17.txt) |
| Q18 | 0.653 | 1.361 | [View plan](plans/Q18.txt) |
| Q19 | 0.295 | 2.073 | [View plan](plans/Q19.txt) |
| Q20 | 0.413 | 0.362 | [View plan](plans/Q20.txt) |
| Q21 | 0.246 | 0.046 | [View plan](plans/Q21.txt) |
| Q22 | 0.225 | 0.040 | [View plan](plans/Q22.txt) |
| Q23 | 0.379 | 10750.690 | [View plan](plans/Q23.txt) |
| Q24 | 0.358 | 4.070 | [View plan](plans/Q24.txt) |
| Q25 | 0.282 | 0.388 | [View plan](plans/Q25.txt) |
| Q26 | 0.490 | 13.111 | [View plan](plans/Q26.txt) |
| Q27 | 0.407 | 0.137 | [View plan](plans/Q27.txt) |
| Q28 | 0.323 | 1.786 | [View plan](plans/Q28.txt) |
| Q29 | 0.462 | 1.803 | [View plan](plans/Q29.txt) |
| Q30 | 0.402 | 2.534 | [View plan](plans/Q30.txt) |

## Notes

- Timings are measured on the local PostgreSQL instance.
- Each query was executed once for this benchmark.
- Execution times may vary due to caching, system load, hardware, and database configuration.
- These measurements represent this synthetic dataset and are not universal performance guarantees.
- The execution plans are stored in `dbms/plans/`.
