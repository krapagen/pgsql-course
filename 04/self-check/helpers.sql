\set ON_ERROR_STOP on
CREATE OR REPLACE FUNCTION pg_temp.assert_true(ok boolean, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    IF ok IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'Unexpected result: %', label;
    END IF;
    RAISE NOTICE 'OK: %', label;
END $$;

CREATE OR REPLACE FUNCTION pg_temp.expect_error(statement text, expected_state text)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual_state text;
BEGIN
    BEGIN
        EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_state = RETURNED_SQLSTATE;
    END;
    IF actual_state IS DISTINCT FROM expected_state THEN
        RAISE EXCEPTION 'Expected SQLSTATE %, got %: %',
            expected_state, coalesce(actual_state, 'success'), statement;
    END IF;
    RAISE NOTICE 'OK SQLSTATE %: %', actual_state, statement;
END $$;
