-- Выполнить один раз после schema.sql, до открытия снимка A.
-- Каждая SQL-команда выполняется отдельно с autocommit.
INSERT INTO homework02.progress (id, progress, payload)
SELECT g, 20, repeat(md5(g::text), 8)
FROM generate_series(1, 30000) AS g;

-- Исходное обслуживание; VACUUM нельзя оборачивать в BEGIN/COMMIT.
VACUUM (ANALYZE, TRUNCATE FALSE) homework02.progress;

SELECT count(*) AS logical_rows, min(progress), max(progress)
FROM homework02.progress;
