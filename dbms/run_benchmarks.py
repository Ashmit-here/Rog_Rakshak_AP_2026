#!/usr/bin/env python3

"""Run database queries three times and save execution plans and timings."""

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
RUNS_PER_QUERY = 3


HEADER_PATTERN = re.compile(
    r"(?m)^--\s*R(\d+)\s*\|\s*(READ|WRITE)\s*\|\s*(.+?)\s*$"
)


SCAN_PATTERN = re.compile(
    r"^\s*(?:->\s*)?"
    r"((?:Parallel\s+)?"
    r"(?:Seq|Index Only|Index|Bitmap Heap|Bitmap Index|Tid|"
    r"CTE|Subquery|Function|Values|Foreign|Sample|WorkTable) Scan)\b",
    re.MULTILINE,
)


def load_queries():
    """Read and validate numbered queries from the SQL file."""
    if not QUERY_FILE.exists():
        raise FileNotFoundError(f"Query file not found: {QUERY_FILE}")

    source = QUERY_FILE.read_text(encoding="utf-8")
    headers = list(HEADER_PATTERN.finditer(source))

    if len(headers) != 30:
        raise ValueError(
            f"Expected 30 labelled queries, found {len(headers)}."
        )

    queries = []

    for index, header in enumerate(headers):
        number = int(header.group(1))
        query_type = header.group(2)
        description = header.group(3).strip()

        if number != index + 1:
            raise ValueError(
                f"Unexpected query numbering: found R{number}."
            )

        end = (
            headers[index + 1].start()
            if index + 1 < len(headers)
            else len(source)
        )

        query_text = source[header.end():end]

        # Remove SQL comment lines, preserving the actual query.
        query_text = re.sub(
            r"(?m)^[ \t]*--[^\n]*(?:\n|$)",
            "",
            query_text,
        ).strip()

        if not query_text:
            raise ValueError(f"R{number} is empty.")

        first_word = query_text.split(None, 1)[0].upper()

        if query_type == "READ" and first_word not in ("SELECT", "WITH"):
            raise ValueError(
                f"R{number} is labelled READ but starts with {first_word}."
            )

        if query_type == "WRITE" and first_word not in (
            "INSERT", "UPDATE", "DELETE", "MERGE"
        ):
            raise ValueError(
                f"R{number} is labelled WRITE but starts with {first_word}."
            )

        queries.append({
            "number": number,
            "type": query_type,
            "description": description,
            "sql": query_text,
        })

    return queries


def run_explain(query):
    """Execute one query with EXPLAIN ANALYZE and return its plan and timings."""
    explain_sql = (
        "EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)\n"
        + query["sql"]
    )

    # Roll back write queries so benchmark data is not permanently changed.
    if query["type"] == "WRITE":
        explain_sql = (
            "BEGIN;\n"
            + explain_sql
            + "\nROLLBACK;"
        )

    command = [
        "psql",
        "-X",
        "-q",
        "-A",
        "-t",
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
        raise RuntimeError(result.stderr.strip() or "PostgreSQL query failed.")

    output = result.stdout.strip()

    planning_match = re.search(
        r"Planning Time:\s*([\d.]+)\s*ms",
        output,
    )

    execution_match = re.search(
        r"Execution Time:\s*([\d.]+)\s*ms",
        output,
    )

    if not planning_match or not execution_match:
        raise RuntimeError("Could not parse PostgreSQL timing output.")

    planning_time = float(planning_match.group(1))
    execution_time = float(execution_match.group(1))

    return output, planning_time, execution_time


def detect_scan_types(plan):
    """Find the scan nodes used in an execution plan."""
    matches = SCAN_PATTERN.findall(plan)

    # Preserve order while removing duplicate scan types.
    unique_scans = list(dict.fromkeys(matches))

    return ", ".join(unique_scans) if unique_scans else "No scan node detected"


def save_plan(number, plan_sections):
    """Save all three execution plans in one file."""
    plan_path = PLANS_DIR / f"R{number}.txt"

    content = [
        f"Execution plans for R{number}",
        f"Database: {DATABASE}",
        f"Executions: {RUNS_PER_QUERY}",
        "",
    ]

    for run_number, plan in enumerate(plan_sections, start=1):
        content.extend([
            "=" * 80,
            f"RUN {run_number}",
            "=" * 80,
            "",
            plan,
            "",
        ])

    plan_path.write_text("\n".join(content), encoding="utf-8")


def write_report(results):
    """Generate the Markdown report with three timings and their average."""
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
        f"- Executions per query: {RUNS_PER_QUERY}",
        f"- Benchmark timestamp: `{timestamp}`",
        "",
        "## Results",
        "",
        "| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |",
        "|---|---|---|---:|---:|---:|---:|---|",
    ]

    for result in results:
        number = result["number"]
        times = result["execution_times"]
        average = result["average"]
        description = result["description"].replace("|", "\\|")
        scan_type = result["scan_type"].replace("|", "\\|")

        lines.append(
            f"| [R{number}](plans/R{number}.txt) "
            f"| {result['type']} "
            f"| {description} "
            f"| {times[0]:.3f} "
            f"| {times[1]:.3f} "
            f"| {times[2]:.3f} "
            f"| {average:.3f} "
            f"| {scan_type} |"
        )

    lines.extend([
        "",
        "## Notes",
        "",
        "- Each query was executed three times.",
        "- Average execution time is the arithmetic mean of the three runs.",
        "- WRITE queries are executed inside a transaction and rolled back.",
        "- Execution plans for all three runs are stored in `dbms/plans/`.",
        "- Timings may vary due to caching, system load, hardware, and configuration.",
        "- Results represent this synthetic dataset and are not universal performance guarantees.",
        "",
    ])

    REPORT_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )



def main():
    connection = subprocess.run(
        ["psql", "-X", "-q", "-d", DATABASE, "-c", "SELECT 1;"],
        capture_output=True,
        text=True,
    )

    if connection.returncode != 0:
        print(
            f"Cannot connect to database '{DATABASE}'. "
            "Check PostgreSQL and the database name."
        )
        return 1

    PLANS_DIR.mkdir(parents=True, exist_ok=True)

    try:
        queries = load_queries()
    except Exception as error:
        print(f"Could not load queries: {error}")
        return 1

    results = []

    print(
        f"Running {len(queries)} queries "
        f"with {RUNS_PER_QUERY} executions each...\n"
    )

    for query in queries:
        number = query["number"]
        execution_times = []
        planning_times = []
        plan_sections = []
        scan_types = []

        print(
            f"R{number}: {query['description']}",
            flush=True,
        )

        try:
            for run_number in range(1, RUNS_PER_QUERY + 1):
                plan, planning, execution = run_explain(query)

                plan_sections.append(plan)
                planning_times.append(planning)
                execution_times.append(execution)

                scan_types.append(detect_scan_types(plan))

                print(
                    f"  Run {run_number}: "
                    f"{execution:.3f} ms",
                    flush=True,
                )

            average = sum(execution_times) / RUNS_PER_QUERY

            # Combine scan types from all three executions.
            all_scans = []
            for scan in scan_types:
                for scan_type in scan.split(", "):
                    if scan_type not in all_scans:
                        all_scans.append(scan_type)

            scan_summary = ", ".join(all_scans)

            save_plan(number, plan_sections)

            results.append({
                "number": number,
                "type": query["type"],
                "description": query["description"],
                "execution_times": execution_times,
                "planning_times": planning_times,
                "average": average,
                "scan_type": scan_summary,
            })

            print(
                f"  Average: {average:.3f} ms\n",
                flush=True,
            )

        except Exception as error:
            print(f"\nR{number} FAILED: {error}")
            return 1

    write_report(results)

    print("Benchmark completed successfully.")
    print(f"Queries benchmarked: {len(results)}")
    print(f"Total executions: {len(results) * RUNS_PER_QUERY}")
    print(f"Execution plans: {PLANS_DIR}")
    print(f"Timing report: {REPORT_FILE}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
