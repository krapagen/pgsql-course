-- Домашнее задание 2. Выполняйте блоки отдельно в B с autocommit.
-- После каждого изменения повторяйте два готовых SELECT ниже.
-- Подпишите в отчёте: до изменений, UPDATE 1, UPDATE 2, после DELETE.

-- 1. Готовые запросы замеров.
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

-- 2. Первый UPDATE: увеличить progress на 1 у всех записей.

-- 3. Второй UPDATE: снова увеличить progress на 1 у всех записей.

-- 4. DELETE строк с id % 10 < 3.

-- 5. COUNT и чтение id = 5 в A и B для сравнения видимости.

-- 6. Дополнительно: VACUUM при открытой A, затем после её COMMIT.

-- 7. После COMMIT A восстановить autovacuum по заданию.
