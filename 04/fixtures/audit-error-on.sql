\set ON_ERROR_STOP on
-- Служебная ошибка: запретить новые записи аудита без изменения заказов.
-- Включать до первого успешного ремонта, не повторять до отключения.
BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.repair_audit
    ADD CONSTRAINT audit_write_fault CHECK (false) NOT VALID;
COMMIT;
