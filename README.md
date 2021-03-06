# Тестовое задание для вакансии Back-end разработчика в Tripment

[Вакансия](https://career.habr.com/vacancies/1000059509).

## Постановка

[Оригинал](https://github.com/tripment/test-tasks/blob/326bc8d/tripment-backend/README.md).

### Описание

У нас в Трипменте бэкенд и фронтенд работают сообща.
Часто нужно готовить такой эндпоинт, который был бы удобен фронту.
В тестовом задании упрощенная версия одного из таких эндпоинтов.

Нужно сделать эндпоинт поиска процедур. Он должен возвращать JSON.
Вначале списка выдаются те процедуры, у которых запрос совпадает с началом слова,
а далее те, у которых просто запрос входит в название.

Процедуры нужно спарсить из [Википедии](https://en.wikipedia.org/wiki/Medical_procedure#List_of_medical_procedures).

### Условия

- Используй Ruby on Rails и PostgreSQL
- Дай возможность наполнить базу процедурами
- Протестируй код
- Разверни приложение
- Остальное на твоё усмотрение

## Решение

### Rails

Впечатления о Rails описывал в [соседнем тестовом задании](https://github.com/AlexWayfer/realy_job_test#rails).

Новые:

*   Не понравилось, что `id:primary_key` добавляется по умолчанию в `create_table`,
    считаю это неправильным и контр-интуитивным.
*   Почему-то модель считает `belongs_to` ассоциацию обязательной, даже если нет на это валидаций
    и в БД `null: true`.
*   `union` (SQL) через дополнительный джем…
*   Нет `select_append`…
*   Нет `distinct on`. 😕
    [Issue](https://github.com/rails/rails/issues/17706)
    *   [Gem для этого](https://github.com/alecdotninja/active_record_distinct_on)
        [не работает](https://github.com/alecdotninja/active_record_distinct_on/pull/12).
*   Сложнее обернуть запрос в под-запрос,
    как [`from_self` в Sequel](https://www.rubydoc.info/gems/sequel/Sequel%2FDataset:from_self).
*   SQL `join` почему-то называется `joins`.
    *   И принимает либо чистый SQL, либо название ассоциации, не название таблицы.
*   Нет `select case` (кто бы мог рассчитывать после вышеизложенного).

### Парсинг из Википедии

Решил вынести запрос и первичный парсинг мед. процедур из Википедии в либу.
Не нашёл гайдов по менеджменту либ в Rails, сделал вручную и её, и тесты для неё.
В тестах можно использовать VCR или аналог, но я решил в том числе оставить тестирование запросов
к Википедии, то есть если она недоступна или изменился формат — чтобы это было легко отследить.
Но опционально, VCR настроить несложно.

Также не до конца ясно, как лучше сделать наполнение/обновление базы:
подобия Rake-task достаточно или лучше end-point, если последнее — публичный или приватный,
если последний — то по какой лучше системе авторизации (ключ, имя-пароль, что-то ещё).
Так как не было уточнений, решил, что таски достаточно (данные не шибко часто меняются).

Для тестов распарсенных данных брал актуальные данные с Википедии, но не все,
а какие-то общие и крайние случаи, вроде тех, когда есть текст вне ссылки, любая вложенность,
дефисы, аббревиатуры, сломанные ссылки, ссылки с примечаниями,
лишние слова-уточнения в ссылках ("(медицина)").

Сначала взял Faraday и ручные запросы, потом случайно наткнулся на джемы вроде
[MediaWiktory](https://github.com/molybdenum-99/mediawiktory), но всё равно вернулся к ручному,
так как облегчение запросов небольшое, плюс нет поддержки параметра `extracts`.
Однако, обратил внимание на джем `mediawiki_api` и решил использовать его:
чуть меньше кода, официальный поддерживаемый джем.

Пробовал разные структуры данных, для неограниченной вложенности и упрощения кода
остановился на вложенных `Hash`, включая пустые у процедур без под-видов.
Но всё же переделал на более интуитивные массивы с `Hash` для вложенных списков.

Ещё немного повозился с разными джемами:
*   `mediawiki_api`:
    *   Issues отключены (зеркало с Gerrit).
    *   Странный `client.get_wikitext`:
        *   Документации `action=raw` и поддержки в других либах не нашёл.
        *   Формат прикольный, но всё же спец. символы вырезать непросто.
    *   Поддержки аргументов вроде `exintro` и `explaintext` у `query` не нашёл.
*   `mediawiktory`:
    *   Поддерживается вроде лучше, синтаксис приятнее.
    *   Формата `raw` не получилось добиться.
        *   `plaintext` не подходит для вложенных списков, нет никаких маркеров вообще.
        *   Оставил `html` (дефолт) и решил парсить его.
            *   Имел опыт с джемом `oga` для этого, мне нравится, считаю, подходит.
            *   Сделал рекурсивный метод вместо кучи вспомогательных локальных переменных
                при плоском списке строк `raw` формата.

Сделал ассоциации `parent` и `children` вручную.

В том числе чтобы не дублировать `category` у вложенных процедур,
решил сделать полиморфную ассоциацию.

Потом вспомнил, что у Sequel есть неплохой плагин для деревьев, погуглил — нашёл
[устаревший официальный](https://github.com/rails/acts_as_tree)
и [поддерживаемый неофициальный](https://github.com/stefankroes/ancestry).
Не знаю, стоит ли подключать целый плагин для небольшой задачи, но хотел довериться ему
и не допускать простых ошибок, а также иметь множество хелперов "из коробки".
Однако я не нашёл информации по поддержке им полиморфных ассоциаций, так что решил не рисковать
и не тратить время на разбирательства, а оставить самостоятельную имплементацию.

Наверное, `Category` стоило назвать более точно, `ProcedureCategory`,
но раз в задании нет других категорий и конфликта — не буду переделывать.

Можно было оптимизировать импорт, сделав его массовым, или не удалять уже существующие сущности,
но я не стал на таких объёмах данных.

### Поиск

Я бы вынес код из контроллера в service objects, но:
*   встроенных в Rails нет;
*   action всего один;
*   он не выглядит громоздким;
так что не стал.

Ещё я мог бы использовать Elasticsearch, как [для Realy](https://github.com/AlexWayfer/realy_job_test),
но в задании такого указания не было, и я решил не усложнять себе жизнь,
в том числе потому что мало с ним знаком (а решение через SQL `like` оказалось интересным).

Есть потенциал поиска по категориям и родителям, но не стал его реализовывать,
потому как этого не было указано в задании, и я и так затянул его выполнение.

Так как `union` в PostgreSQL не гарантирует порядок из под-запросов,
добавил кастомную колонку с `order` потом.

Долго возился с `union`, `distinct on(id)` (или `group by id`) и `order by priority`,
но всё же сделал (не идеальный подход, но из принципа). В коде "Solution #1".

Пока делал, мне предложили упростить с помощью `_` перед `%query%`.
Я знал, что это требует какой-либо символ (как `.` в регулярных выражениях),
но забыл (редко использую `like`) и не догадался.

Далее предложили ещё упростить с помощью `case position()`, что позволяет избавиться от `union`
и/или группировки. Жалею, что не догадался сам.

Реализовал все 3 подхода. Да, видимо, с интересными запросами у меня мало опыта.

### Узнал новое

*   Полиморфные ассоциации в ActiveRecord.
*   `union` в PostgreSQL не гарантирует порядок строк из под-запросов.
*   `position(substring in string)` в SQL.

## Запуск

### Требования

*   Ruby, версия указана в файле `.ruby-version`
*   PostgreSQL

### Настройка

Стандартные операции для Rails приложений, которые они почему-то не написали в шаблоне,
ну и я не буду.

### Тестирование

`rails spec`, но он не принимает параметров для RSpec, так что я советую `bundle exec rspec`.
