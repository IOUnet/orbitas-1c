# Orbitas для 1С:Предприятие

MVP расширения 1С:Предприятие для подключения информационной базы к Orbitas.

## Пользовательский поток

Реализация/Поступление → Обязательство Orbitas → Найти взаимозачёт → Согласовать → Распоряжение на расчёт → Исполнение → Отражение в учёте

## Что уже есть

- архитектурные инварианты расширения;
- reference adapter для «1С:Бухгалтерия предприятия 3.0»;
- нормализация реализации/поступления в obligation DTO;
- идемпотентная исходящая очередь;
- HTTP/JSON transport;
- подключение Participant Passport;
- поиск candidate paths;
- явные команды «Согласовать» / «Отклонить»;
- раздельная модель Orbitas status и бухгалтерского состояния;
- схема метаданных для obligation links, кэша, proposals и settlement instructions;
- тестовая матрица partial settlement / multicurrency / multi-company / retry;
- repository-local skill в .agents/skills/;
- PowerShell-сборка CFE и smoke-test.

## Сборка CFE

После однократного bootstrap XML-выгрузки расширения в src/extension:

~~~powershell
.\scripts\build.ps1 -InfoBasePath "C:\1c\orbitas-build"
~~~

Результат:

~~~text
build/Orbitas.cfe
~~~

Smoke-test на отдельной тестовой ИБ:

~~~powershell
.\scripts\test.ps1 -BuildInfoBasePath "C:\1c\orbitas-build" -TestInfoBasePath "C:\1c\orbitas-smoke"
~~~

Подробно: docs/BUILD.md.

## Важная граница MVP

В репозитории теперь есть воспроизводимый build pipeline, но сам каталог src/extension должен быть впервые получен выгрузкой реального расширения из целевого релиза БП 3.0. Это важно: UUID заимствованных объектов базовой конфигурации нельзя безопасно придумывать вручную.

До первого bootstrap build.ps1 специально завершится с понятной ошибкой, если src/extension/Configuration.xml отсутствует.

После bootstrap XML/BSL в src/extension становится source of truth, а .cfe — артефактом сборки.

Перед release также нужно:

1. зафиксировать точный релиз БП 3.0, платформу и режим совместимости;
2. собрать управляемые формы рабочего места и дополнения форм документов;
3. согласовать реальные URL/DTO Orbitas Core;
4. реализовать production-мэппинг подтверждённого settlement в штатные документы расчётов;
5. прогнать проверку расширения, smoke-test и функциональные тесты на целевой ИБ.

Разработка ведётся расширением конфигурации без изменения типовой конфигурации. Терминология интерфейса — из экосистемы 1С:Предприятие.
