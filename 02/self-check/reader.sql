-- Выполнить в интерактивном psql A после schema.sql и seed.sql.
-- Подключение оставить открытым до конца изменений B или первой очистки.
SET application_name = 'hw02_reader';
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS logical_rows FROM homework02.progress;
SELECT id, progress, ctid, xmin
FROM homework02.progress WHERE id = 5;
