\set ON_ERROR_STOP on
\ir repair-core.sql
BEGIN;
SELECT pg_temp.repair_sup204() AS changed;
COMMIT;

BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders VALIDATE CONSTRAINT order_customer_in_tenant;
COMMIT;
