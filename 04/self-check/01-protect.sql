\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.customers
    ADD CONSTRAINT customer_in_tenant UNIQUE (tenant_id, id);
ALTER TABLE hw04.orders
    ADD CONSTRAINT order_number_in_tenant UNIQUE (tenant_id, order_no);
COMMIT;

BEGIN;
SET LOCAL lock_timeout = '2s';
ALTER TABLE hw04.orders
    ADD CONSTRAINT order_customer_in_tenant
    FOREIGN KEY (tenant_id, customer_id)
    REFERENCES hw04.customers (tenant_id, id) NOT VALID;
COMMIT;
