-- Заготовка домашнего задания первого занятия.
-- Дополните enrollments в этом файле и затем примените схему к пустой базе.
-- Родительские таблицы готовы; менять имена колонок не нужно для готового seed.
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
    user_id bigint,
    course_id bigint,
    amount_cents bigint,
    status text DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now()
    -- Добавьте обязательность ссылок, суммы и статуса.
    -- Добавьте FK на users и courses.
    -- Добавьте уникальность пары user_id и course_id.
    -- Добавьте CHECK для неотрицательной суммы и списка статусов.
    -- Перед ограничениями таблицы потребуется запятая после created_at.
);

COMMIT;
