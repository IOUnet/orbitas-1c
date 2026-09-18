# Sources — 1С:Предприятие extension-development skill

Актуализировано: 2026-09-18.

## Приоритет источников

При конфликте:

1. официальная документация платформы 1С:Предприятие / 1С:ИТС;
2. официальная Система стандартов и методик разработки конфигураций;
3. официальная документация 1C:EDT;
4. официальные материалы БСП;
5. open-source инструменты сообщества — только как tooling recommendation.

## Официальные источники 1С

1. Расширения — платформа 1С:Предприятие  
   https://v8.1c.ru/platforma/rasshireniya/

2. Расширения конфигураций. Как адаптировать прикладные решения при внедрении  
   https://its.1c.ru/db/pubextensions

3. Проект расширения конфигурации — 1C:EDT  
   https://its.1c.ru/db/content/edtdoc/src/topics/t000538.html

4. 1C:EDT — официальный сайт  
   https://edt.1c.ru/

5. 1C:EDT 2026.1  
   https://edt.1c.ru/docs/new/versiya-2026-1/

6. Общие требования к конфигурации — стандарт 467  
   https://its.1c.ru/db/content/v8std/src/200/100/i8100467.htm

7. Стандартные роли — стандарт 488  
   https://its.1c.ru/db/content/v8std/src/700/i8100488.htm

8. Настройка ролей и прав доступа — стандарт 689  
   https://its.1c.ru/db/content/v8std/src/700/i8100689.htm

9. Проверка прав доступа — стандарт 737  
   https://its.1c.ru/db/content/v8std/src/700/i8100737.htm

10. Безопасность прикладного программного интерфейса сервера — стандарт 678  
    https://its.1c.ru/db/content/v8std/src/600/i8100678.htm

11. Ограничение на выполнение внешнего кода — стандарт 669  
    https://its.1c.ru/db/content/v8std/src/600/i8100669.htm

12. Транзакции: правила использования — стандарт 783  
    https://its.1c.ru/db/content/v8std/src/300/300/i8100783.htm

13. Минимизация количества серверных вызовов и трафика — стандарт 487  
    https://its.1c.ru/db/content/v8std/src/500/i8100487.htm

14. Минимизация кода, выполняемого на клиенте — стандарт 629  
    https://its.1c.ru/db/content/v8std/src/500/i8100629.htm

15. Таймауты при работе с внешними ресурсами — стандарт 748  
    https://its.1c.ru/db/content/v8std/src/500/i8100748.htm

16. Общие требования к регламентным заданиям — стандарт 540  
    https://its.1c.ru/db/content/v8std/src/200/500/i8100540.htm

17. Запуск регламентных заданий — стандарт 539  
    https://its.1c.ru/db/content/v8std/src/200/500/i8100539.htm

18. Перехват исключений в коде — стандарт 499  
    https://its.1c.ru/db/content/v8std/src/400/200/i8100499.htm

19. Использование Журнала регистрации — стандарт 498  
    https://its.1c.ru/db/content/v8std/src/400/200/i8100498.htm

20. Правила создания общих модулей — стандарт 469  
    https://its.1c.ru/db/content/v8std/src/200/100/i8100469.htm

21. Обработчики обновления информационной базы (БСП) — стандарт 690  
    https://its.1c.ru/db/content/v8std/src/900/i8100690.htm

22. HTTP-сервисы — Технологии интеграции 1С:Предприятия 8.3  
    https://its.1c.ru/db/content/intgr83/src/24.html

23. JSON — Технологии интеграции 1С:Предприятия 8.3  
    https://its.1c.ru/db/intgr83/content/6/hdoc

24. Язык запросов — оптимизация запросов  
    https://its.1c.ru/db/pubqlang/content/138/hdoc

## Community tooling

25. YAxUnit  
    https://github.com/bia-technologies/yaxunit

26. Vanessa Automation  
    https://github.com/Pr-Mex/vanessa-automation

27. BSL Language Server  
    https://github.com/1c-syntax/bsl-language-server

## Проектная база Orbitas

Проектный профиль опирается на архитектурные инварианты Orbitas:

- ERP-specific объекты не должны попадать в clearing core;
- 1С является адаптером и источником учетных фактов;
- Core отвечает за графовый поиск, R/Q/S, locks и финальную проверку;
- settlement instruction не является доказательством оплаты;
- redirect требует явного consent;
- интеграционные write-операции должны быть идемпотентны;
- бухгалтерское отражение выполняется после подтвержденного исполнения.
