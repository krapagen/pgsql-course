\set ON_ERROR_STOP on
-- До ремонта.
SELECT o.id, o.tenant_id AS order_tenant, o.customer_id, c.tenant_id AS customer_tenant
FROM hw04.orders o JOIN hw04.customers c ON c.id=o.customer_id
WHERE o.tenant_id<>c.tenant_id;

SELECT tenant_id,order_no,count(*) FROM hw04.orders
GROUP BY tenant_id,order_no HAVING count(*)>1;

-- После prepare-mixed.sql.
SELECT id,total_cents,total_amount,
       coalesce(total_amount,total_cents::numeric/100) AS unsafe_reader,
       total_cents::numeric/100 AS authoritative_reader
FROM hw04.orders ORDER BY id;

SELECT id,total_cents,total_amount FROM hw04.orders
WHERE total_amount IS DISTINCT FROM total_cents::numeric/100 ORDER BY id;

-- После ремонта и VALIDATE.
SELECT order_id,old_customer_id,new_customer_id,evidence FROM hw04.repair_audit;
SELECT conname,contype,convalidated,pg_get_constraintdef(oid)
FROM pg_constraint WHERE conrelid='hw04.orders'::regclass ORDER BY conname;
