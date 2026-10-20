\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT is_nullable='YES' FROM information_schema.columns
     WHERE table_schema='hw04' AND table_name='orders' AND column_name='total_amount'),
    'rollback restored nullable expansion');
SELECT pg_temp.assert_true(
    NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conrelid='hw04.orders'::regclass
               AND conname IN ('amount_present','amount_matches_cents')),
    'rollback removed both incompatible transitional checks');
UPDATE hw04.orders SET total_cents=150001 WHERE id=1001;
INSERT INTO hw04.orders(id,tenant_id,order_no,customer_id,total_cents)
VALUES(9003,20,43,201,100);
SELECT pg_temp.assert_true(
    (SELECT total_cents=150001 AND total_amount=1500 FROM hw04.orders WHERE id=1001),
    'old-only UPDATE works and makes the new value stale');
SELECT pg_temp.assert_true(
    (SELECT total_amount IS NULL FROM hw04.orders WHERE id=9003),
    'old-only INSERT works without filling the new column');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders(id,tenant_id,order_no,customer_id,total_cents)
     VALUES(9004,10,9004,201,100)', '23503');
SELECT pg_temp.expect_error(
    'INSERT INTO hw04.orders(id,tenant_id,order_no,customer_id,total_cents)
     VALUES(9005,10,42,101,100)', '23505');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=-1 WHERE id=1001', '23514');
SELECT pg_temp.expect_error(
    'UPDATE hw04.orders SET total_amount=''NaN''::numeric WHERE id=1001', '23514');
ROLLBACK;
