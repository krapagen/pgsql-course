# Пакет домашнего задания 3

Начните с [homework.md](homework.md). Ориентировочное время — **2,5–3,5 часа** при подготовленной среде. Схема и данные готовы; пять исходных запросов и места для собственных решений находятся в [queries.sql](queries.sql). [Ключ](answer-key.md) и папка self-check предназначены для проверки после выполнения.

Пакет можно целиком скопировать в другую папку или передать студентам: все ссылки и команды относятся к файлам внутри пакета. Для основной работы достаточно Docker с Compose; psql уже есть в контейнере.

## Состав пакета

| Файл или папка | Назначение |
| --- | --- |
| [homework.md](homework.md) | Условия пяти задач, протокол и критерии |
| [answer-key.md](answer-key.md) | Решения, ожидаемые результаты и объяснения |
| [compose.yaml](compose.yaml) | Локальный стенд PostgreSQL 18.4 |
| [schema.sql](schema.sql) | Готовая схема без индексов |
| [seed.sql](seed.sql) | Готовые исходные данные |
| [queries.sql](queries.sql) | Пять исходных запросов и место для собственных решений |
| [settings.sql](settings.sql) / [sanity.sql](sanity.sql) | Общие условия замеров и проверка данных |
| [comparison.sql](comparison.sql) | Шаблон проверки результатов через EXCEPT ALL |
| [report-template.md](report-template.md) | Шаблон отчёта |
| [self-check/README.md](self-check/README.md) | Готовые SQL-примеры из ключа |
| [diagnostics.sql](diagnostics.sql) | Контрпримеры для разбора корректности |
| [images/README.md](images/README.md) | Образ PostgreSQL, платформы и подготовка стенда |

Папки bad/, solutions/ и tools/ — дополнительные файлы для автоматической проверки. Основную работу можно выполнить без Python. Интернет нужен для получения образа, если его ещё нет; [вариант с предварительной загрузкой](images/README.md).

## Подключение

Откройте терминал в этой папке, где находится compose.yaml:

```sh
docker compose up -d --wait
docker compose exec -T postgres psql -X -U course -d course_hw03 -c 'SELECT version(), current_database(), current_user;'
```

Пользователь — course, база — course_hw03. Подключение происходит внутри контейнера; установка отдельного SQL-клиента не требуется.

## Схема и данные

Примените готовую схему, данные и проверку:

```sh
docker compose exec -T postgres psql -X -U course -d course_hw03 -v ON_ERROR_STOP=1 -f /work/schema.sql -f /work/seed.sql -f /work/settings.sql -f /work/sanity.sql
```

Схема и seed применяются один раз к пустой базе. Ожидаемые объёмы: 1 200 клиентов, 48 000 заказов, 142 518 позиций, 96 001 платёж и 380 608 событий. Индексов в lab нет. Папка пакета доступна в контейнере как /work только для чтения; свои файлы редактируйте на компьютере.

## Выполнение запросов

Напишите пять собственных решений в queries.sql, рядом с исходными запросами. Выполняйте пары отдельно в интерактивном psql:

```sh
docker compose exec postgres psql -X -U course -d course_hw03 -v ON_ERROR_STOP=1
```

В psql выполните `\i /work/settings.sql`. Для плана поставьте EXPLAIN перед текстом нужного SELECT. Файл queries.sql служит рабочей тетрадью: для замеров копируйте отдельные запросы, а не запускайте все блоки одновременно. Проверку пары заполните в comparison.sql и выполните `\i /work/comparison.sql`. Выход из psql — `\q`.

Готовые решения для самопроверки находятся в self-check/queries.sql. Открывайте их после самостоятельной работы.

## Автоматическая проверка по желанию

Если удобнее использовать Python 3, перенесите пять решений из queries.sql в solutions/01.sql ... 05.sql: по одному SELECT/WITH на файл. Затем в терминале компьютера выполните:

```sh
python3 tools/check.py --solutions solutions
python3 tools/measure.py --solutions solutions --runs 3
```

Скрипты используют только стандартную библиотеку, находят compose.yaml относительно собственного файла и сохраняют планы в results/. Не запускайте их внутри psql. Проверка и сравнимые измерения обязательны, способ их выполнения выбираете сами.

## Повторный прогон

Переписывание SELECT не меняет таблицы. Можно повторять измерения на той же базе; подготовку повторять не нужно. Для полного воспроизведения seed создайте отдельную пустую базу:

```sh
docker compose exec -T postgres createdb -U course course_hw03_repeat
docker compose exec -T postgres psql -X -U course -d course_hw03_repeat -v ON_ERROR_STOP=1 -f /work/schema.sql -f /work/seed.sql -f /work/settings.sql -f /work/sanity.sql
python3 tools/check.py --solutions solutions --database course_hw03_repeat
```

Последняя команда нужна только при автоматической проверке. Для ручной работы подключайтесь к course_hw03_repeat и снова примените settings.sql. Для автоматических замеров добавьте такой же `--database course_hw03_repeat`. Не запускайте schema/seed повторно поверх существующих данных.

## Остановка стенда

Выйдите из psql и выполните:

```sh
docker compose down
```

Данные сохраняются в именованном томе и будут доступны после следующего запуска.

## Если используете установленный PostgreSQL

Создайте отдельную пустую базу, примените schema.sql, seed.sql и sanity.sql через psql. Выполните settings.sql в каждом измеряющем подключении. Python-скрипты рассчитаны на Compose; для другого подключения сравнения и замеры выполните вручную. На иной версии возможны другие планы: в отчёте зафиксируйте version и не требуйте точного совпадения задержек.
