#!/usr/bin/env python3
"""Один прогрев и чередующиеся замеры пяти пар; сохраняет JSON и текст планов."""
import argparse
import csv
import json
from pathlib import Path
import statistics
from check import ROOT, prefix, query, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--solutions", default="solutions")
    parser.add_argument("--database", default="course_hw03")
    parser.add_argument("--runs", type=int, default=3)
    args = parser.parse_args()
    if args.runs < 3:
        parser.error("Для сравнения нужно хотя бы 3 измерения на вариант")
    folder = ROOT / args.solutions
    target = ROOT / "results"
    target.mkdir(exist_ok=True)
    summary = []
    for number in range(1, 6):
        sql = {"before": query(ROOT / "bad" / f"{number:02}.sql"),
               "after": query(folder / f"{number:02}.sql")}
        timings = {variant: [] for variant in sql}
        for repetition in range(args.runs + 1):
            variants = ["before", "after"] if repetition % 2 == 0 else ["after", "before"]
            for variant in variants:
                statement = (prefix() + "EXPLAIN (ANALYZE, BUFFERS, SETTINGS, "
                             "TIMING OFF, FORMAT JSON) " + sql[variant] + ";\nROLLBACK;\n")
                plan = json.loads(run(statement, args.database))
                filename = f"q{number:02}-{variant}-{'warmup' if repetition == 0 else repetition}.json"
                (target / filename).write_text(json.dumps(plan, indent=2), encoding="utf-8")
                if repetition:
                    timings[variant].append(plan[0]["Execution Time"])
                print(f"Q{number} {variant} run={repetition}: {plan[0]['Execution Time']} ms", flush=True)
        # Один отдельный план с таймингами узлов - для чтения, вне выборки медианы.
        for variant in sql:
            detailed = run(prefix() + "EXPLAIN (ANALYZE, BUFFERS, SETTINGS) " +
                           sql[variant] + ";\nROLLBACK;\n", args.database)
            (target / f"q{number:02}-{variant}.txt").write_text(detailed, encoding="utf-8")
        before, after = (statistics.median(timings[v]) for v in ["before", "after"])
        summary.append({"query": number, "before_ms": before, "after_ms": after,
                        "speedup": round(before / after, 2),
                        "before_runs": json.dumps(timings["before"]),
                        "after_runs": json.dumps(timings["after"])})
    with (target / "summary.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=summary[0].keys())
        writer.writeheader()
        writer.writerows(summary)
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
