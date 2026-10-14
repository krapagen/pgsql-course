-- Готовое решение. Выполнить один раз в B с autocommit, пока A открыта.
SET application_name = 'hw02_writer';

SELECT 'before' AS stage,
    (SELECT count(*) FROM homework02.progress) AS logical_rows,
    pg_relation_size('homework02.progress'::regclass) AS heap_bytes,
    pg_table_size('homework02.progress'::regclass) AS table_bytes,
    pg_indexes_size('homework02.progress'::regclass) AS index_bytes,
    pg_total_relation_size('homework02.progress'::regclass) AS total_bytes;

UPDATE homework02.progress SET progress = progress + 1;

SELECT 'update_1' AS stage,
    (SELECT count(*) FROM homework02.progress) AS logical_rows,
    pg_relation_size('homework02.progress'::regclass) AS heap_bytes,
    pg_table_size('homework02.progress'::regclass) AS table_bytes,
    pg_indexes_size('homework02.progress'::regclass) AS index_bytes,
    pg_total_relation_size('homework02.progress'::regclass) AS total_bytes;

UPDATE homework02.progress SET progress = progress + 1;

SELECT 'update_2' AS stage,
    (SELECT count(*) FROM homework02.progress) AS logical_rows,
    pg_relation_size('homework02.progress'::regclass) AS heap_bytes,
    pg_table_size('homework02.progress'::regclass) AS table_bytes,
    pg_indexes_size('homework02.progress'::regclass) AS index_bytes,
    pg_total_relation_size('homework02.progress'::regclass) AS total_bytes;

DELETE FROM homework02.progress WHERE id % 10 < 3;

SELECT 'after_delete' AS stage,
    (SELECT count(*) FROM homework02.progress) AS logical_rows,
    pg_relation_size('homework02.progress'::regclass) AS heap_bytes,
    pg_table_size('homework02.progress'::regclass) AS table_bytes,
    pg_indexes_size('homework02.progress'::regclass) AS index_bytes,
    pg_total_relation_size('homework02.progress'::regclass) AS total_bytes;

SELECT n_live_tup, n_dead_tup, n_tup_upd, n_tup_del,
       last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE schemaname = 'homework02' AND relname = 'progress';

SELECT id, progress, ctid, xmin
FROM homework02.progress WHERE id = 5;
