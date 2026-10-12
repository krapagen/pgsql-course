-- Три некорректные вставки из ключа. Выполнять отдельно в autocommit.
-- Ожидаются отказы UNIQUE, FOREIGN KEY и CHECK соответственно.

INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT u.id, c.id, 150000, 'paid'
FROM users AS u
CROSS JOIN courses AS c
WHERE u.email = 'anna@example.test'
  AND c.code = 'postgres-dev';

INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT -1, c.id, 150000, 'pending'
FROM courses AS c
WHERE c.code = 'postgres-dev';

INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT u.id, c.id, -100, 'pending'
FROM users AS u
CROSS JOIN courses AS c
WHERE u.email = 'vera@example.test'
  AND c.code = 'sql-basics';
