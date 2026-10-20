\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT count(*)=3 AND bool_and(total_amount=total_cents::numeric/100)
     FROM hw04.orders), 'all representations agree after reconciliation');
SELECT pg_temp.assert_true(
    (SELECT array_agg(total_amount ORDER BY id)=ARRAY[1500,600,199.9]::numeric[]
     FROM hw04.orders), 'final amounts preserve authoritative values');
SELECT pg_temp.assert_true(
    (SELECT data_type='numeric' AND numeric_precision=14 AND numeric_scale=4
         AND is_nullable='NO'
     FROM information_schema.columns
     WHERE table_schema='hw04' AND table_name='orders' AND column_name='total_amount'),
    'new representation has the intended type and mandatory value');
SELECT pg_temp.assert_true(
    (SELECT count(*)=3 AND bool_and(convalidated) FROM pg_constraint
     WHERE conrelid='hw04.orders'::regclass
       AND conname IN ('amount_present','amount_range','amount_matches_cents')),
    'amount history validated');

UPDATE hw04.orders SET total_cents=150001,total_amount=1500.01 WHERE id=1001;
SELECT pg_temp.assert_true(
    (SELECT total_cents=150001 AND total_amount=1500.01 FROM hw04.orders WHERE id=1001),
    'dual writer still works');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_cents=150002 WHERE id=1001', '23514');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=-0.01 WHERE id=1001', '23514');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=NULL WHERE id=1001', '23502');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=''NaN''::numeric WHERE id=1001', '23514');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_cents=1,total_amount=0.0125 WHERE id=1001', '23514');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=10000000000 WHERE id=1001', '22003');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders VALUES (9001,10,9001,201,100,1)', '23503');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders VALUES (9002,10,42,101,100,1)', '23505');
INSERT INTO hw04.orders VALUES (9003,20,43,201,0,0);
INSERT INTO hw04.orders VALUES (9004,10,9004,101,999999999999,9999999999.99);
SELECT pg_temp.assert_true(
    (SELECT count(*)=2 FROM hw04.orders WHERE id IN (9003,9004)),
    'zero, legacy upper limit and number in another tenant remain allowed');
ROLLBACK;
