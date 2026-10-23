-- Домашнее задание 3. Выполняйте запросы по одному при одинаковых настройках.
-- Сначала в psql: \i /work/settings.sql
-- Для плана добавьте EXPLAIN (ANALYZE, BUFFERS, SETTINGS, TIMING OFF).
-- Исходные SELECT сохраняйте; своё решение пишите в отмеченном месте.
-- Выполнение всех блоков файла не заменяет отдельные замеры.

-- ========== Q1. Исходный запрос ==========
-- Q1: все клиенты, число оплаченных заказов и сумма их total_cents.
-- Клиенты без оплаченных заказов остаются с двумя нулями.
SELECT c.id AS customer_id,
       (SELECT count(*) FROM lab.orders o
        WHERE o.customer_id = c.id AND o.status = 'paid') AS paid_count,
       COALESCE((SELECT sum(o.total_cents) FROM lab.orders o
                 WHERE o.customer_id = c.id AND o.status = 'paid'), 0) AS paid_total
FROM lab.customers c;
 
-- ========== Q1. Ваше решение ==========
-- Напишите новый SELECT здесь.
-- Сравните результат через comparison.sql, затем сохраните планы до/после.
 
-- ========== Q2. Исходный запрос ==========
-- Q2: уникальные оплаченные заказы, у которых есть позиция sku <= 50,
-- успешная оплата и событие email. Число дочерних строк неважно.
SELECT DISTINCT o.id AS order_id, o.customer_id
FROM lab.orders o
JOIN lab.order_items i ON i.order_id = o.id AND i.sku_id <= 50
JOIN lab.payments p ON p.order_id = o.id AND p.status = 'success'
JOIN lab.events e ON e.order_id = o.id AND e.event_type = 'email'
WHERE o.status = 'paid';
 
-- ========== Q2. Ваше решение ==========
-- Напишите новый SELECT здесь.
-- Сравните результат через comparison.sql, затем сохраните планы до/после.
 
-- ========== Q3. Исходный запрос ==========
-- Q3: события email за полуоткрытый интервал; payload не нужен.
WITH all_events AS MATERIALIZED (
  SELECT * FROM lab.events
)
SELECT id AS event_id, order_id, occurred_at
FROM all_events
WHERE event_type = 'email'
  AND occurred_at >= timestamp '2026-04-29'
  AND occurred_at < timestamp '2026-05-01';
 
-- ========== Q3. Ваше решение ==========
-- Напишите новый SELECT здесь.
-- Сравните результат через comparison.sql, затем сохраните планы до/после.
 
-- ========== Q4. Исходный запрос ==========
-- Q4: оплаченные заказы за два дня и стоимость/число их позиций.
-- Заказ без позиций остаётся с нулями. total_cents не заменяет item_total.
SELECT o.id AS order_id, o.customer_id,
       COALESCE(m.item_total, 0) AS item_total,
       COALESCE(m.item_count, 0) AS item_count
FROM lab.orders o
LEFT JOIN (
  SELECT order_id, sum(qty * price_cents) AS item_total,
         count(*) AS item_count
  FROM lab.order_items
  GROUP BY order_id
) m ON m.order_id = o.id
WHERE o.status = 'paid'
  AND o.created_at >= timestamp '2026-04-29'
  AND o.created_at < timestamp '2026-05-01';
 
-- ========== Q4. Ваше решение ==========
-- Напишите новый SELECT здесь.
-- Сравните результат через comparison.sql, затем сохраните планы до/после.
 
-- ========== Q5. Исходный запрос ==========
-- Q5: последнее событие каждого оплаченного заказа за два дня.
-- Порядок внутри заказа: occurred_at DESC, id DESC; без событий заказ не входит.
SELECT o.id AS order_id, e.id AS event_id, e.event_type, e.occurred_at
FROM lab.orders o
JOIN (
  SELECT id, order_id, event_type, occurred_at,
         row_number() OVER (
           PARTITION BY order_id ORDER BY occurred_at DESC, id DESC
         ) AS rn
  FROM lab.events
) e ON e.order_id = o.id AND e.rn = 1
WHERE o.status = 'paid'
  AND o.created_at >= timestamp '2026-04-29'
  AND o.created_at < timestamp '2026-05-01';
 
-- ========== Q5. Ваше решение ==========
-- Напишите новый SELECT здесь.
-- Сравните результат через comparison.sql, затем сохраните планы до/после.
 
