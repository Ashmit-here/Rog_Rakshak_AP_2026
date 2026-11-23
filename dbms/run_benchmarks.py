#!/usr/bin/env python3

"""Run Q1-Q30 and save PostgreSQL execution plans and timings."""

import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
QUERY_FILE = ROOT / "dbms" / "04_queries.sql"
PLANS_DIR = ROOT / "dbms" / "plans"
REPORT_FILE = ROOT / "dbms" / "05_query_timings.md"

DATABASE = "Rog_AP_2026"


def load_queries():
    """Read numbered SQL queries from 04_queries.sql."""
    if not QUERY_FILE.exists():
        raise FileNotFoundError(f"Query file not found: {QUERY_FILE}")

    source = QUERY_FILE.read_text(encoding="utf-8")

    headers = list(
        re.finditer(r"(?m)^--\s*(\d+)\.\s+.*$", source)
    )

    if len(headers) != 30:
        raise ValueError(
            f"Expected 30 numbered queries, found {len(headers)}."
        )

    queries = []

    for index, header in enumerate(headers):
        query_number = int(header.group(1))

        if query_number != index + 1:
            raise ValueError(
                f"Unexpected query numbering: found Q{query_number:02d}."
            )

        end = (
            headers[index + 1].start()
            if index + 1 < len(headers)
            else len(source)
        )

        query_text = source[header.end():end]

        # Remove SQL comment lines and surrounding whitespace.
        query_text = re.sub(
            r"(?m)^\s*--.*(?:\n|$)",
            "",
            query_text
        ).strip()

        if not query_text:
            raise ValueError(f"Q{query_number:02d} is empty.")

        queries.append((query_number, query_text))

    return queries


def run_explain(number, query):
    """Execute one query using EXPLAIN ANALYZE."""
    explain_sql = (
        "EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)\n"
        + query
    )

    command = [
        "psql",
        "-X",
        "-v",
        "ON_ERROR_STOP=1",
        "-d",
        DATABASE,
        "-c",
        explain_sql,
    ]

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Q{number:02d} failed:\n{result.stderr}"
        )

    output = result.stdout

    planning_match = re.search(
        r"Planning Time:\s*([\d.]+)\s*ms",
        output
    )

    execution_match = re.search(
        r"Execution Time:\s*([\d.]+)\s*ms",
        output
    )

    if not planning_match or not execution_match:
        raise RuntimeError(
            f"Could not parse timings for Q{number:02d}."
        )

    planning_time = float(planning_match.group(1))
    execution_time = float(execution_match.group(1))

    return output, planning_time, execution_time


def write_report(results):
    """Create the Markdown timing report."""
    timestamp = datetime.now().astimezone().isoformat(
        timespec="seconds"
    )

    lines = [
        "# Query Execution Timings",
        "",
        "## Benchmark environment",
        "",
        "- Database: PostgreSQL",
        f"- Database name: `{DATABASE}`",
        "- Dataset: Synthetic benchmark data",
        "- Query source: `dbms/04_queries.sql`",
        "- Execution method: `EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)`",
        "- Executions per query: 1",
        f"- Benchmark timestamp: `{timestamp}`",
        "",
        "## Results",
        "",
        "| Query | Planning Time (ms) | Execution Time (ms) | Execution Plan |",
        "|---|---:|---:|---|",
    ]

    for number, planning, execution in results:
        plan_name = f"Q{number:02d}.txt"

        lines.append(
            f"| Q{number:02d} | {planning:.3f} | "
            f"{execution:.3f} | [View plan](plans/{plan_name}) |"
        )

    lines.extend([
        "",
        "## Notes",
        "",
        "- Timings are measured on the local PostgreSQL instance.",
        "- Each query was executed once for this benchmark.",
        "- Execution times may vary due to caching, system load, "
        "hardware, and database configuration.",
        "- These measurements represent this synthetic dataset and "
        "are not universal performance guarantees.",
        "- The execution plans are stored in `dbms/plans/`.",
        "",
    ])

    REPORT_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8"
    )


def main():
    if subprocess.run(
        ["psql", "-X", "-d", DATABASE, "-c", "SELECT 1;"],
        capture_output=True,
        text=True,
    ).returncode != 0:
        print(
            f"Cannot connect to database '{DATABASE}'. "
            "Check PostgreSQL and the database name."
        )
        return 1

    PLANS_DIR.mkdir(parents=True, exist_ok=True)

    queries = load_queries()
    results = []

    print(f"Running {len(queries)} queries on {DATABASE}...\n")

    for number, query in queries:
        print(f"Running Q{number:02d}...", end=" ", flush=True)

        try:
            plan, planning, execution = run_explain(number, query)

            plan_path = PLANS_DIR / f"Q{number:02d}.txt"
            plan_path.write_text(plan, encoding="utf-8")

            results.append((number, planning, execution))

            print(
                f"Planning: {planning:.3f} ms | "
                f"Execution: {execution:.3f} ms"
            )

        except Exception as error:
            print("FAILED")
            print(error)
            return 1

    write_report(results)

    print("\nBenchmark completed successfully.")
    print(f"Execution plans: {PLANS_DIR}")
    print(f"Timing report: {REPORT_FILE}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
    