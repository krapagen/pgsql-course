\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.repair_audit DROP CONSTRAINT audit_write_fault;
COMMIT;
