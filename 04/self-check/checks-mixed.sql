\set ON_ERROR_STOP on
\ir helpers.sql
BEGIN;
SELECT pg_temp.assert_true(
    (SELECT total_cents=150000 AND total_amount=1500 FROM hw04.orders WHERE id=1001),
    'new writer updated both representations');
SELECT pg_temp.assert_true(
    (SELECT total_cents=60000 AND total_amount=500 FROM hw04.orders WHERE id=1002),
    'old import made a non-null amount stale');
SELECT pg_temp.assert_true(
    (SELECT total_amount IS NULL FROM hw04.orders WHERE id=1003), 'history partly unfilled');
SELECT pg_temp.assert_true(
    (SELECT coalesce(total_amount,total_cents::numeric/100)=500
     FROM hw04.orders WHERE id=1002), 'COALESCE reads the stale amount');
UPDATE hw04.orders SET total_amount=total_cents::numeric/100 WHERE total_amount IS NULL;
SELECT pg_temp.assert_true(
    (SELECT array_agg(id ORDER BY id)=ARRAY[1002]::bigint[] FROM hw04.orders
     WHERE total_amount IS DISTINCT FROM total_cents::numeric/100),
    'NULL-only backfill leaves a mismatch');
ROLLBACK;
