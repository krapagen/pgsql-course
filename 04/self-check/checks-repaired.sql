\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT tenant_id=10 AND customer_id=102 FROM hw04.orders WHERE id=1003),
    'confirmed customer repaired without changing tenant');
SELECT pg_temp.assert_true(
    (SELECT count(*)=1 FROM hw04.repair_audit
     WHERE order_id=1003 AND old_customer_id=201 AND new_customer_id=102
       AND evidence='SUP-204'), 'audit contains actual old/new and source');
SELECT pg_temp.assert_true(
    (SELECT convalidated FROM pg_constraint
     WHERE conrelid='hw04.orders'::regclass AND conname='order_customer_in_tenant'),
    'history validated after repair');
ROLLBACK;
