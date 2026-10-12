# Ключ к домашнему заданию первого занятия

## PostgreSQL и реляционные базы данных

Откройте ключ после самостоятельного выполнения задания. Сопоставьте свою схему, результаты запросов и сообщения об ошибках с примерами ниже. SQL можно записать по-другому; важно, чтобы он выражал те же правила и возвращал те же данные.

## 1 Полная схема

```sql
-- Полная схема для отдельной пустой учебной базы.
BEGIN;

CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email text NOT NULL,
    CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE TABLE courses (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code text NOT NULL,
    title text NOT NULL,
    CONSTRAINT courses_code_unique UNIQUE (code)
);

CREATE TABLE enrollments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL,
    course_id bigint NOT NULL,
    amount_cents bigint NOT NULL,
    status text NOT NULL DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT enrollments_user_fk FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT enrollments_course_fk FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT enrollments_user_course_unique UNIQUE (user_id, course_id),
    CONSTRAINT enrollments_amount_nonnegative CHECK (amount_cents >= 0),
    CONSTRAINT enrollments_status_allowed
        CHECK (status IN ('pending', 'paid', 'cancelled'))
);

COMMIT;

```

- FK связывают регистрацию с существующими родительскими строками.
- NOT NULL делает ссылки, сумму и статус обязательными.
- UNIQUE по паре запрещает две регистрации одного пользователя на один курс.
- CHECK суммы допускает ноль, но запрещает отрицательное значение.
- CHECK статуса ограничивает список значений. Переходы между статусами он не проверяет.

Имена ограничений могут отличаться. Объявление `REFERENCES` непосредственно у колонки также выражает внешний ключ.

## 2 Исходные данные

После применения готового seed должны быть 3 пользователя, 2 курса и 3 регистрации. Вера существует, но ни на один курс не зарегистрирована. ID могут различаться; ориентируйтесь на email и код курса.

## 3 Решения SELECT

### Все регистрации

```sql
SELECT u.email, c.code AS course_code, e.status
FROM enrollments AS e
JOIN users AS u ON u.id = e.user_id
JOIN courses AS c ON c.id = e.course_id
ORDER BY u.email, c.code;
```

Результат:

| email | course_code | status |
| --- | --- | --- |
| anna@example.test | postgres-dev | paid |
| anna@example.test | sql-basics | pending |
| boris@example.test | postgres-dev | cancelled |

### Оплаченные регистрации

```sql
SELECT u.email, c.code AS course_code
FROM enrollments AS e
JOIN users AS u ON u.id = e.user_id
JOIN courses AS c ON c.id = e.course_id
WHERE e.status = 'paid'
ORDER BY u.email, c.code;
```

Результат:

| email | course_code |
| --- | --- |
| anna@example.test | postgres-dev |

### Пользователи без регистраций

```sql
SELECT u.email
FROM users AS u
LEFT JOIN enrollments AS e ON e.user_id = u.id
WHERE e.id IS NULL
ORDER BY u.email;
```

Результат:

| email |
| --- |
| vera@example.test |

То же условие можно выразить через NOT EXISTS:

```sql
SELECT u.email
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.user_id = u.id
)
ORDER BY u.email;
```

В LEFT JOIN важно искать отсутствие связанной строки, а не фильтровать регистрации только по статусу. Пользователь с отменённой регистрацией всё равно имеет регистрацию.

## 4 Некорректные вставки

Выполняйте команды отдельно в autocommit на схеме с загруженным seed. Все три должны быть отклонены ограничениями; новых регистраций не появится.

### Повтор регистрации Анны

```sql
INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT u.id, c.id, 150000, 'paid'
FROM users AS u
CROSS JOIN courses AS c
WHERE u.email = 'anna@example.test'
  AND c.code = 'postgres-dev';
```

Ожидается нарушение UNIQUE по `(user_id, course_id)`. В эталоне имя ограничения — `enrollments_user_course_unique`, SQLSTATE — `23505`. Новый ID не делает повтор этой пары допустимым.

### Отсутствующий пользователь

```sql
INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT -1, c.id, 150000, 'pending'
FROM courses AS c
WHERE c.code = 'postgres-dev';
```

Ожидается нарушение FK на пользователя. В эталоне — `enrollments_user_fk`, SQLSTATE — `23503`. Курс существует, но пользователя с ID `-1` в исходном наборе нет.

### Отрицательная сумма

```sql
INSERT INTO enrollments(user_id, course_id, amount_cents, status)
SELECT u.id, c.id, -100, 'pending'
FROM users AS u
CROSS JOIN courses AS c
WHERE u.email = 'vera@example.test'
  AND c.code = 'sql-basics';
```

Ожидается нарушение CHECK суммы. В эталоне — `enrollments_amount_nonnegative`, SQLSTATE — `23514`. Пользователь и курс существуют, пара ещё не зарегистрирована; нарушено именно условие суммы.

Конкретный текст сообщения зависит от языка PostgreSQL и имени ограничения. SQLSTATE полезен как дополнительный ориентир, запоминать коды не требуется.

### Количество регистраций после попыток

```sql
SELECT count(*) AS registrations
FROM enrollments;
```

Результат — **3**. Пропуски в сгенерированных ID после неудачных вставок возможны и не означают, что появилась новая строка.

Если команда вернула `INSERT 0 0` без ошибки, SELECT внутри неё не нашёл родительские строки. Проверьте email, код курса и наличие данных: в таком случае ограничение не было проверено попыткой записи.

## 5 Объяснения

### PK и уникальность пары

PK по `id` идентифицирует отдельную строку. Две строки могут иметь разные ID, но одинаковые `user_id` и `course_id`. UNIQUE по паре запрещает именно такой повтор бизнес-связи.

### CHECK и обязательность суммы

`CHECK(amount_cents >= 0)` отклоняет ложное условие. Сравнение с NULL даёт неизвестный результат, поэтому только CHECK не запрещает неизвестную сумму. `NOT NULL` задаёт отдельное требование обязательности.

Аналогично, FK сам по себе не делает ссылку обязательной: для обязательной связи добавляется NOT NULL.

### DEFAULT и NOT NULL

DEFAULT подставляет `pending`, если поле статуса пропущено в INSERT либо передано ключевое слово DEFAULT. Явный NULL не заменяется значением по умолчанию: в эталоне он отклоняется из-за NOT NULL.

### Выбор типов

`bigint` хранит сумму как точное целое число копеек. `timestamptz` хранит момент времени, который отображается в часовом поясе сессии. Эти решения соответствуют правилам учебного кейса.

Если после первого отказа PostgreSQL сообщает, что транзакция прервана, выполните ROLLBACK и повторите попытки отдельно, без общего BEGIN/COMMIT.
