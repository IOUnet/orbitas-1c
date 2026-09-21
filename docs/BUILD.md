# Сборка Orbitas.cfe

## Требования

- Windows;
- установленная платформа 1С:Предприятие;
- файловая build-ИБ с тем же релизом БП 3.0, на котором проверяется расширение;
- в build-ИБ уже создано расширение с внутренним именем Orbitas;
- полный XML-dump расширения в src/extension.

Точный релиз БП, версия платформы и режим совместимости являются частью release metadata.

## Первый bootstrap

Команда LoadConfigFromFiles с параметром -Extension работает с расширением в контексте информационной базы. Поэтому один раз:

1. открыть build-ИБ в Конфигураторе;
2. открыть «Конфигурация → Расширения конфигурации»;
3. создать Orbitas;
4. назначение — «Дополнение»;
5. префикс — ORB_;
6. создать/заимствовать метаданные MVP по docs/MVP-METADATA.md;
7. выгрузить расширение в файлы в src/extension.

После этого ручная сборка не требуется.

## Сборка

~~~powershell
.\scripts\build.ps1 -InfoBasePath "C:\1c\orbitas-build"
~~~

Явный путь к платформе:

~~~powershell
.\scripts\build.ps1 -InfoBasePath "C:\1c\orbitas-build" -V8Path "C:\Program Files\1cv8\8.3.xx.xxxx\bin\1cv8.exe"
~~~

С пользователем ИБ:

~~~powershell
.\scripts\build.ps1 -InfoBasePath "C:\1c\orbitas-build" -UserName "Администратор" -Password $env:ONEC_PASSWORD
~~~

Результат:

~~~text
build/Orbitas.cfe
build/logs/
~~~

Скрипт выполняет:

~~~text
src/extension
    ↓
DESIGNER /LoadConfigFromFiles ... -Extension Orbitas -updateConfigDumpInfo
    ↓
DESIGNER /UpdateDBCfg -Extension Orbitas
    ↓
DESIGNER /DumpCfg build/Orbitas.cfe -Extension Orbitas
~~~

Для batch-команд проверяются exit code и /DumpResult. После DumpCfg дополнительно проверяется, что CFE реально создан и не пуст.

## Smoke-test

Используйте отдельную disposable ИБ:

~~~powershell
.\scripts\test.ps1 -BuildInfoBasePath "C:\1c\orbitas-build" -TestInfoBasePath "C:\1c\orbitas-smoke"
~~~

Скрипт:

1. собирает build/Orbitas.cfe;
2. загружает его в test-ИБ через /LoadCfg ... -Extension Orbitas;
3. выполняет /UpdateDBCfg -Extension Orbitas.

Успех smoke-test означает, что артефакт загружается и применим к целевой ИБ. Это не заменяет:

- проверку расширения в Конфигураторе/EDT;
- YAxUnit;
- Vanessa Automation;
- тесты partial settlement, multicurrency, multi-company, retry/replay;
- ручную проверку управляемых форм.

## Безопасность

Пароли и токены не коммитить. В CI передавать пароль через secret/environment variable.

build/ и *.cfe игнорируются Git, кроме build/.gitkeep.
