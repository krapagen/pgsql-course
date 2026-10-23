-- Проверка одной пары запросов. Заполните оба CTE своими SELECT без ';' внутри.
-- Пример-заготовка использует Q4. after_result пока пуст: проверка НЕ проходит.
-- Для другой задачи замените оба запроса; сохранить нужно значения и кратности.
-- EXCEPT ALL не проверяет совпадение типов: используйте также psql \gdesc.
WITH before_result AS MATERIALIZED (
  SELECT o.id AS order_id, o.customer_id,
         COALESCE(m.item_total, 0) AS item_total,
         COALESCE(m.item_count, 0) AS item_count
  FROM lab.orders o
  LEFT JOIN (
    SELECT order_id, sum(qty * price_cents) AS item_total, count(*) AS item_count
    FROM lab.order_items GROUP BY order_id
  ) m ON m.order_id = o.id
  WHERE o.status = 'paid'
    AND o.created_at >= timestamp '2026-04-29'
    AND o.created_at < timestamp '2026-05-01'
), after_result AS MATERIALIZED (
  -- Замените этот пустой SELECT своим решением Q4.
  SELECT NULL::bigint AS order_id, NULL::bigint AS customer_id,
         NULL::numeric AS item_total, NULL::bigint AS item_count
  WHERE false
)
SELECT
  (SELECT count(*) FROM before_result) AS before_rows,
  (SELECT count(*) FROM after_result) AS after_rows,
  (SELECT count(*) FROM
     (TABLE before_result EXCEPT ALL TABLE after_result) d) AS before_minus_after,
  (SELECT count(*) FROM
     (TABLE after_result EXCEPT ALL TABLE before_result) d) AS after_minus_before;
