\set ON_ERROR_STOP on
SELECT version(), current_database();
SELECT 'tenants' AS relation, count(*) FROM hw04.tenants
UNION ALL SELECT 'customers', count(*) FROM hw04.customers
UNION ALL SELECT 'orders', count(*) FROM hw04.orders
UNION ALL SELECT 'repair_audit', count(*) FROM hw04.repair_audit;
SELECT id, tenant_id, order_no, customer_id, total_cents
FROM hw04.orders ORDER BY id;
-- Исходно: 2 организации, 3 клиента, 3 заказа, пустой аудит.
