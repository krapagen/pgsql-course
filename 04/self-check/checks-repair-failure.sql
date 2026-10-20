\set ON_ERROR_STOP on
\ir helpers.sql
\ir repair-core.sql
BEGIN;
ALTER TABLE hw04.repair_audit
    ADD CONSTRAINT audit_write_fault CHECK (false) NOT VALID;
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', '23514');
SELECT pg_temp.assert_true(
    (SELECT customer_id=201 FROM hw04.orders WHERE id=1003),
    'audit failure rolled back the customer update');
SELECT pg_temp.assert_true(
    (SELECT count(*)=0 FROM hw04.repair_audit), 'audit failure left no audit row');
ROLLBACK;

BEGIN;
INSERT INTO hw04.repair_audit(order_id,old_customer_id,new_customer_id,evidence)
VALUES(1003,201,102,'SUP-204');
SELECT pg_temp.expect_error('SELECT pg_temp.repair_sup204()', 'P0001');
SELECT pg_temp.assert_true(
    (SELECT customer_id=201 FROM hw04.orders WHERE id=1003),
    'audit claiming completion with old customer is a contradiction');
ROLLBACK;
