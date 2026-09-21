# src/extension

Этот каталог — каноническая XML-выгрузка расширения Orbitas из Конфигуратора 1С.

Ожидаемая структура после первого bootstrap/export:

~~~text
src/extension/
├── Configuration.xml
├── ConfigDumpInfo.xml
├── Languages/
├── CommonModules/
│   ├── ORB_Константы.xml
│   ├── ORB_Константы/
│   │   └── Ext/
│   │       └── Module.bsl
│   └── ...
├── InformationRegisters/
├── DataProcessors/
├── Roles/
└── ...
~~~

## Первый bootstrap

Расширение зависит от конкретного релиза «1С:Бухгалтерия предприятия 3.0» и от UUID заимствованных объектов базовой конфигурации. Поэтому корневой Configuration.xml и adopted metadata не генерируются вручную.

Один раз:

1. Откройте тестовую ИБ с целевым релизом БП 3.0.
2. Создайте расширение с внутренним именем Orbitas.
3. Назначение: Дополнение.
4. Префикс собственных объектов: ORB_.
5. Создайте/заимствуйте объекты по docs/MVP-METADATA.md.
6. Выгрузите расширение в файлы непосредственно в этот каталог.
7. После этого scripts/build.ps1 собирает воспроизводимый Orbitas.cfe.

## Source of truth

После bootstrap source of truth — XML/BSL в этом каталоге.

Файл .cfe является артефактом сборки и в Git не коммитится.
