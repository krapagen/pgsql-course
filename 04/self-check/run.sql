\set ON_ERROR_STOP on
-- Только отдельная ПУСТАЯ база: ничего не удаляет и не пересоздаёт.
\ir ../schema.sql
\ir ../seed.sql
\ir checks-before.sql
\ir 01-protect.sql
\ir checks-protected.sql
\ir checks-repair-failure.sql
\ir 02-repair.sql
-- Повтор после COMMIT: должен быть успешным без новой записи аудита.
\ir 02-repair.sql
\ir checks-repaired.sql
\ir checks-repair-conflicts.sql
\ir 03-expand.sql
\ir ../prepare-mixed.sql
\ir checks-mixed.sql
\ir 04-cutover.sql
\ir checks-final.sql
\ir 05-rollback.sql
\ir checks-rollback.sql
