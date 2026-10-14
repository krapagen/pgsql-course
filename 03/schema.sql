-- Домашнее задание 2. Готовая схема; выполнить один раз в пустой базе.
-- На время опыта автоматическая очистка отключена только у этой таблицы.
BEGIN;

CREATE SCHEMA homework02;

CREATE TABLE homework02.progress (
    id bigint PRIMARY KEY,
    progress integer NOT NULL CHECK (progress BETWEEN 0 AND 100),
    payload text NOT NULL
) WITH (fillfactor = 100, autovacuum_enabled = false);

COMMIT;
