\set ON_ERROR_STOP on
\ir helpers.sql
\ir repair-core.sql
BEGIN;
SELECT pg_temp.assert_true(NOT pg_temp.repair_sup204(), 'confirmed retry is a no-op');
SELECT pg_temp.assert_true(
    (SELECT count(*)=1 FROM hw04.repair_audit WHERE order_id=1003), 'retry keeps one audit row');
ROLLBACK;

BEGIN;
UPDATE hw04.orders SET customer_id=101 WHERE id=1003;
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', 'P0001');
SELECT pg_temp.assert_true(
    (SELECT customer_id=101 FROM hw04.orders WHERE id=1003),
    'another same-tenant customer is not silently overwritten');
ROLLBACK;

BEGIN;
DELETE FROM hw04.repair_audit WHERE order_id=1003;
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', 'P0001');
SELECT pg_temp.assert_true(
    (SELECT count(*)=0 FROM hw04.repair_audit), 'correct customer without audit is not fabricated');
ROLLBACK;

BEGIN;
UPDATE hw04.repair_audit SET evidence='OTHER' WHERE order_id=1003;
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', 'P0001');
ROLLBACK;

BEGIN;
UPDATE hw04.orders SET tenant_id=20,customer_id=201 WHERE id=1003;
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', 'P0001');
ROLLBACK;
