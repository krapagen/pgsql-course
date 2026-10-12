-- Решения трёх SELECT. Выполнить на схеме с готовым seed.

SELECT u.email, c.code AS course_code, e.status
FROM enrollments AS e
JOIN users AS u ON u.id = e.user_id
JOIN courses AS c ON c.id = e.course_id
ORDER BY u.email, c.code;

SELECT u.email, c.code AS course_code
FROM enrollments AS e
JOIN users AS u ON u.id = e.user_id
JOIN courses AS c ON c.id = e.course_id
WHERE e.status = 'paid'
ORDER BY u.email, c.code;

SELECT u.email
FROM users AS u
LEFT JOIN enrollments AS e ON e.user_id = u.id
WHERE e.id IS NULL
ORDER BY u.email;
