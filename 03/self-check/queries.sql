-- Готовые решения домашнего задания 3 для самопроверки.
-- Открывайте после самостоятельного выполнения.
-- Перед замерами выполните settings.sql; запускайте запросы по одному.

-- ========== Q1. Решение ==========
SELECT c.id AS customer_id,
       COALESCE(m.paid_count, 0) AS paid_count,
       COALESCE(m.paid_total, 0) AS paid_total
FROM lab.customers c
LEFT JOIN (
  SELECT customer_id, count(*) AS paid_count,
         sum(total_cents) AS paid_total
  FROM lab.orders
  WHERE status = 'paid'
  GROUP BY customer_id
) m ON m.customer_id = c.id;
 
-- ========== Q2. Решение ==========
SELECT o.id AS order_id, o.customer_id
FROM lab.orders o
WHERE o.status = 'paid'
  AND EXISTS (SELECT FROM lab.order_items i
              WHERE i.order_id = o.id AND i.sku_id <= 50)
  AND EXISTS (SELECT FROM lab.payments p
              WHERE p.order_id = o.id AND p.status = 'success')
  AND EXISTS (SELECT FROM lab.events e
              WHERE e.order_id = o.id AND e.event_type = 'email');
 
-- ========== Q3. Решение ==========
SELECT id AS event_id, order_id, occurred_at
FROM lab.events
WHERE event_type = 'email'
  AND occurred_at >= timestamp '2026-04-29'
  AND occurred_at < timestamp '2026-05-01';
 
-- ========== Q4. Решение ==========
SELECT o.id AS order_id, o.customer_id,
       COALESCE(sum(i.qty * i.price_cents), 0) AS item_total,
       count(i.id) AS item_count
FROM lab.orders o
LEFT JOIN lab.order_items i ON i.order_id = o.id
WHERE o.status = 'paid'
  AND o.created_at >= timestamp '2026-04-29'
  AND o.created_at < timestamp '2026-05-01'
GROUP BY o.id, o.customer_id;
 
-- ========== Q5. Решение ==========
SELECT DISTINCT ON (o.id)
       o.id AS order_id, e.id AS event_id, e.event_type, e.occurred_at
FROM lab.orders o
JOIN lab.events e ON e.order_id = o.id
WHERE o.status = 'paid'
  AND o.created_at >= timestamp '2026-04-29'
  AND o.created_at < timestamp '2026-05-01'
ORDER BY o.id, e.occurred_at DESC, e.id DESC;
 
