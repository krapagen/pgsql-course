\set ON_ERROR_STOP on
-- Временная функция позволяет отдельно воспроизводить отказы той же логики.
-- В прикладной схеме функция не создаётся; это форма записи эталона.
CREATE OR REPLACE FUNCTION pg_temp.repair_sup204()
RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    actual_tenant bigint;
    actual_old bigint;
    actual_new bigint;
    audit_row hw04.repair_audit%ROWTYPE;
    audit_found boolean;
BEGIN
    SELECT tenant_id, customer_id INTO STRICT actual_tenant, actual_old
    FROM hw04.orders WHERE id=1003 FOR UPDATE;
    SELECT * INTO audit_row FROM hw04.repair_audit
    WHERE order_id=1003 FOR UPDATE;
    audit_found := FOUND;

    IF actual_tenant <> 10 THEN
        RAISE EXCEPTION 'SUP-204 conflicts with current tenant';
    END IF;
    IF actual_old = 102 THEN
        IF NOT audit_found THEN
            RAISE EXCEPTION 'Customer already changed without confirming audit';
        END IF;
        IF audit_row.old_customer_id <> 201 OR audit_row.new_customer_id <> 102
            OR audit_row.evidence <> 'SUP-204' THEN
            RAISE EXCEPTION 'SUP-204 conflicts with existing audit';
        END IF;
        RETURN false;
    END IF;
    IF actual_old <> 201 OR audit_found THEN
        RAISE EXCEPTION 'Unexpected source state for SUP-204';
    END IF;

    UPDATE hw04.orders SET customer_id=102 WHERE id=1003
    RETURNING customer_id INTO STRICT actual_new;
    INSERT INTO hw04.repair_audit
        (order_id, old_customer_id, new_customer_id, evidence)
    VALUES (1003, actual_old, actual_new, 'SUP-204');
    RETURN true;
END $$;
