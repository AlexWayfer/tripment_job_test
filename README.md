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

TODO

## Запуск

### Требования

*   Ruby, версия указана в файле `.ruby-version`
*   PostgreSQL

### Настройка

Стандартные операции для Rails приложений, которые они почему-то не написали в шаблоне,
ну и я не буду.

### Тестирование

`rails spec`, но он не принимает параметров для RSpec, так что я советую `bundle exec rspec`.
