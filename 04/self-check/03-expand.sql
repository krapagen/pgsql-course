\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders ADD COLUMN total_amount numeric(14,4);
COMMIT;
