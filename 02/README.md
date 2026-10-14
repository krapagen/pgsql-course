# Пакет домашнего задания 2

Начните с [homework.md](homework.md). Ориентировочное время — **60–90 минут** при подготовленной среде. Схема и данные готовы; собственные команды записывайте в `queries.sql`. [Ключ](answer-key.md) и папка `self-check` предназначены для проверки после выполнения.

Пакет можно целиком скопировать в другую папку или передать студентам: все ссылки и команды относятся к файлам внутри пакета.

## Состав пакета

| Файл | Назначение |
| --- | --- |
| [homework.md](homework.md) | Условия домашнего задания |
| [answer-key.md](answer-key.md) | Решения, ожидаемые результаты и объяснения |
| [compose.yaml](compose.yaml) | Локальный стенд PostgreSQL 18.4 |
| [schema.sql](schema.sql) | Готовая схема учебной таблицы |
| [seed.sql](seed.sql) | Готовые исходные данные |
| [queries.sql](queries.sql) | Запросы замеров и место для собственных команд |
| [self-check/README.md](self-check/README.md) | Готовые SQL-примеры из ключа |
| [images/README.md](images/README.md) | Образ PostgreSQL, платформы и подготовка стенда |

## Подключение

Откройте терминал в этой папке, где находится `compose.yaml`:

```sh
docker compose up -d --wait
docker compose exec -T postgres psql -X -U course -d course_hw02 -c 'SELECT version(), current_database(), current_user;'
```

Пользователь — `course`, база — `course_hw02`. Подключение происходит внутри контейнера, установка отдельного SQL-клиента не требуется. Если используете готовую PostgreSQL, создайте отдельную пустую базу и выполняйте SQL в своём клиенте.

## Схема и данные

Примените готовую схему и исходные данные:

```sh
docker compose cp schema.sql postgres:/tmp/schema.sql
docker compose exec -T postgres psql -X -U course -d course_hw02 -v ON_ERROR_STOP=1 -f /tmp/schema.sql
docker compose cp seed.sql postgres:/tmp/seed.sql
docker compose exec -T postgres psql -X -U course -d course_hw02 -v ON_ERROR_STOP=1 -f /tmp/seed.sql
```

Схема и seed применяются один раз к пустой базе. В таблице появятся 30 000 записей с `progress = 20`. Команды копирования и запуска файлов можно использовать в Bash, Zsh и PowerShell.

## Выполнение запросов

Откройте в двух отдельных терминалах интерактивные psql A и B:

```sh
docker compose exec postgres psql -X -U course -d course_hw02
```

Запросы замеров уже находятся в `queries.sql`; дополните файл своими UPDATE и DELETE. Выполняйте команды B отдельно в autocommit. Порядок открытия снимка A и завершения работы описан в задании. Выход из psql — `\q`.

## Повторный прогон

Завершите транзакцию A и выйдите из обоих psql. Для нового опыта создайте другую пустую базу:

```sh
docker compose exec -T postgres createdb -U course course_hw02_repeat
```

В следующих командах замените `course_hw02` на `course_hw02_repeat`. Перед применением снова скопируйте изменённые SQL-файлы в контейнер. Исходная база сохранится. Не запускайте seed и массовые изменения повторно поверх предыдущего опыта.

## Остановка стенда

После COMMIT A и восстановления autovacuum по заданию выйдите из psql и выполните:

```sh
docker compose down
```

Данные сохраняются в именованном томе и будут доступны после следующего запуска.
