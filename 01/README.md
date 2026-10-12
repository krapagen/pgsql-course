# Пакет домашнего задания 1

Начните с [homework.md](homework.md). Ориентировочное время — **60 минут** при подготовленной среде. Рабочая заготовка — `schema.sql`; её нужно дополнить самостоятельно. [Ключ](answer-key.md) и папка `self-check` предназначены для проверки после выполнения.

Пакет можно целиком скопировать в другую папку или передать студентам: все ссылки и команды относятся к файлам внутри пакета.

## Состав пакета

| Файл | Назначение |
| --- | --- |
| [homework.md](homework.md) | Условия домашнего задания |
| [answer-key.md](answer-key.md) | Решения, ожидаемые результаты и объяснения |
| [compose.yaml](compose.yaml) | Локальный стенд PostgreSQL 18.4 |
| [schema.sql](schema.sql) | Заготовка схемы для самостоятельного завершения |
| [seed.sql](seed.sql) | Готовые исходные данные |
| [queries.sql](queries.sql) | Место для собственных запросов |
| [self-check/README.md](self-check/README.md) | Готовые SQL-примеры из ключа |
| [images/README.md](images/README.md) | Образ PostgreSQL, платформы и подготовка стенда |

## Подключение

Откройте терминал в этой папке, где находится `compose.yaml`:

```sh
docker compose up -d --wait
docker compose exec -T postgres psql -X -U course -d course_hw01 -c 'SELECT version(), current_database(), current_user;'
```

Пользователь — `course`, база — `course_hw01`. Подключение происходит внутри контейнера, установка отдельного SQL-клиента не требуется. Если используете готовую PostgreSQL, создайте отдельную пустую базу и выполняйте SQL в своём клиенте.

## Схема и данные

Сначала завершите ограничения в `schema.sql` по правилам задания. Затем примените схему и готовые данные:

```sh
docker compose cp schema.sql postgres:/tmp/schema.sql
docker compose exec -T postgres psql -X -U course -d course_hw01 -v ON_ERROR_STOP=1 -f /tmp/schema.sql
docker compose cp seed.sql postgres:/tmp/seed.sql
docker compose exec -T postgres psql -X -U course -d course_hw01 -v ON_ERROR_STOP=1 -f /tmp/seed.sql
```

Схема и seed применяются один раз к пустой базе. В ней появятся 3 пользователя, 2 курса и 3 регистрации. Команды копирования и запуска файлов можно использовать в Bash, Zsh и PowerShell.

## Выполнение запросов

Напишите собственные запросы в `queries.sql`. Для выполнения по одному откройте интерактивный psql:

```sh
docker compose exec postgres psql -X -U course -d course_hw01
```

Выполняйте команды отдельно в autocommit. Выход из psql — `\q`.

## Повторный прогон

После изменения уже применённой схемы создайте другую пустую базу:

```sh
docker compose exec -T postgres createdb -U course course_hw02
```

В следующих командах замените `course_hw01` на `course_hw02`. Перед новым применением снова скопируйте изменённый `schema.sql` в контейнер. Исходная база сохранится.

## Остановка стенда

```sh
docker compose down
```

Данные сохраняются в именованном томе и будут доступны после следующего запуска.
