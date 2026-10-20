\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT NOT convalidated FROM pg_constraint
     WHERE conrelid = 'hw04.orders'::regclass
       AND conname = 'order_customer_in_tenant'), 'FK installed without history validation');
SELECT pg_temp.assert_true(
    (SELECT customer_id = 201 FROM hw04.orders WHERE id = 1003),
    'installing protection did not silently repair history');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders VALUES (9001,10,9001,201,100)', '23503');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET customer_id=201 WHERE id=1001', '23503');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders VALUES (9002,10,42,101,100)', '23505');
-- У организации 20 ещё нет номера 43: такой же номер у tenant 10 разрешён.
INSERT INTO hw04.orders VALUES (9003,20,43,201,100);
SELECT pg_temp.assert_true(
    (SELECT count(*) = 1 FROM hw04.orders WHERE id=9003), 'same number in another tenant is allowed');
ROLLBACK;
