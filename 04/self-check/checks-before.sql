\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT count(*) = 3 FROM hw04.orders), 'three initial orders');
SELECT pg_temp.assert_true(
    (SELECT array_agg(o.id ORDER BY o.id) = ARRAY[1003]::bigint[]
     FROM hw04.orders o JOIN hw04.customers c ON c.id = o.customer_id
     WHERE o.tenant_id <> c.tenant_id), 'legacy cross-tenant order exists');
-- Эти операции проходят: исходная схема пропускает оба нарушения.
INSERT INTO hw04.orders VALUES (9001, 10, 9001, 201, 100);
INSERT INTO hw04.orders VALUES (9002, 10, 42, 101, 100);
SELECT pg_temp.assert_true(
    (SELECT count(*) = 2 FROM hw04.orders WHERE id IN (9001,9002)),
    'legacy FK and missing scoped UNIQUE allow invalid rows');
ROLLBACK;

BEGIN;
ALTER TABLE hw04.customers ADD UNIQUE (tenant_id,id);
SELECT pg_temp.expect_error(
    'ALTER TABLE hw04.orders ADD FOREIGN KEY (tenant_id,customer_id)
     REFERENCES hw04.customers(tenant_id,id)', '23503');
ROLLBACK;
