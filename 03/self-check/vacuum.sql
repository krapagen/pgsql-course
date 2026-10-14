-- Дополнительная часть. Запускать в B вне BEGIN/COMMIT.
-- Первый раз: пока A открыта. Второй раз: после COMMIT A.
SELECT pid, application_name, state,
       clock_timestamp() - xact_start AS xact_age, backend_xmin
FROM pg_stat_activity
WHERE datname = current_database()
  AND application_name = 'hw02_reader';

VACUUM (VERBOSE, ANALYZE, TRUNCATE FALSE) homework02.progress;

SELECT
    (SELECT count(*) FROM homework02.progress) AS logical_rows,
    pg_relation_size('homework02.progress'::regclass) AS heap_bytes,
    pg_table_size('homework02.progress'::regclass) AS table_bytes,
    pg_indexes_size('homework02.progress'::regclass) AS index_bytes,
    pg_total_relation_size('homework02.progress'::regclass) AS total_bytes;

SELECT n_live_tup, n_dead_tup, n_tup_upd, n_tup_del,
       last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE schemaname = 'homework02' AND relname = 'progress';
