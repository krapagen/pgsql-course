\set ON_ERROR_STOP on
-- Внешнее условие: old-only writers остановлены; оставшиеся пишут обе суммы.
-- Пока нужны целые копейки, authoritative total_cents сохраняется.
BEGIN;
UPDATE hw04.orders
SET total_amount = total_cents::numeric / 100
WHERE total_amount IS DISTINCT FROM total_cents::numeric / 100;
COMMIT;

BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders
    ADD CONSTRAINT amount_range CHECK (
        total_amount >= 0 AND total_amount <= 9999999999.9999
    ) NOT VALID,
    ADD CONSTRAINT amount_present CHECK (total_amount IS NOT NULL) NOT VALID,
    ADD CONSTRAINT amount_matches_cents CHECK (
        total_amount = total_cents::numeric / 100
    ) NOT VALID;
COMMIT;

BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders VALIDATE CONSTRAINT amount_range;
ALTER TABLE hw04.orders VALIDATE CONSTRAINT amount_present;
ALTER TABLE hw04.orders VALIDATE CONSTRAINT amount_matches_cents;
COMMIT;

BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders ALTER COLUMN total_amount SET NOT NULL;
COMMIT;
