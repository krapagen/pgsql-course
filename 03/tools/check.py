#!/usr/bin/env python3
"""EXCEPT ALL в обе стороны для пяти пар. Только стандартная библиотека."""
import argparse
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def query(path):
    text = path.read_text(encoding="utf-8").strip()
    # Файлы содержат один запрос, завершающий ';' и комментарии в начале.
    body = "\n".join(line for line in text.splitlines()
                     if not line.lstrip().startswith("--")).strip()
    if not body or not body.endswith(";"):
        raise ValueError(f"{path}: нужен один законченный SELECT/WITH с ';'")
    return body[:-1]


def run(sql, database="course_hw03"):
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "postgres", "psql", "-X", "-qAt",
         "-U", "course", "-d", database, "-v", "ON_ERROR_STOP=1"],
        input=sql, text=True, capture_output=True, cwd=ROOT, check=True)
    return result.stdout


def prefix():
    # SHOW и version из settings.sql в JSON-вывод не попадают.
    return "\n".join(line for line in (ROOT / "settings.sql").read_text(encoding="utf-8").splitlines()
                     if line.startswith("SET ")) + "\nBEGIN READ ONLY;\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--solutions", default="solutions")
    parser.add_argument("--database", default="course_hw03")
    args = parser.parse_args()
    folder = ROOT / args.solutions
    failures = 0
    for number in range(1, 6):
        name = f"{number:02}.sql"
        before, after = query(ROOT / "bad" / name), query(folder / name)
        sql = prefix() + f"""
WITH before_result AS MATERIALIZED ({before}),
     after_result AS MATERIALIZED ({after})
SELECT json_build_object(
  'query', {number},
  'before_rows', (SELECT count(*) FROM before_result),
  'after_rows', (SELECT count(*) FROM after_result),
  'before_minus_after', (SELECT count(*) FROM
    (TABLE before_result EXCEPT ALL TABLE after_result) d),
  'after_minus_before', (SELECT count(*) FROM
    (TABLE after_result EXCEPT ALL TABLE before_result) d));
ROLLBACK;
"""
        result = json.loads(run(sql, args.database))
        before_columns = run(prefix() + before + "\n\\gdesc\nROLLBACK;\n", args.database)
        after_columns = run(prefix() + after + "\n\\gdesc\nROLLBACK;\n", args.database)
        result["columns_equal"] = before_columns == after_columns
        print(json.dumps(result, ensure_ascii=False))
        failures += bool(result["before_minus_after"] or result["after_minus_before"]
                         or not result["columns_equal"])
    if failures:
        raise SystemExit(f"Несовпадающих пар: {failures}")
    print("Все пять пар равны как мультимножества; имена, порядок и типы колонок совпадают. Порядок строк проверяйте отдельно.")


if __name__ == "__main__":
    main()
