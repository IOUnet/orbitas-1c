# Ожидаемый API-контракт Orbitas Core для MVP

Этот файл задаёт **контракт адаптера 1С**, а не утверждает, что публичный Orbitas API уже имеет именно такие URL. Пути должны быть согласованы с Core перед релизом.

## Participant Passport
- create/link company passport
- get passport

## Obligations
- create obligation idempotently
- get obligation
- list incoming/outgoing obligations
- update/cancel only through Core-supported lifecycle commands

### Нормализованный DTO

```json
{
  "source_system": "1c-enterprise",
  "source_ref": "<uuid документа 1С>",
  "source_document_type": "РеализацияТоваровУслуг",
  "organization_ref": "<uuid организации>",
  "debtor_participant_id": "...",
  "creditor_participant_id": "...",
  "amount": "125000.00",
  "currency": "RUB",
  "due_date": "2026-10-15",
  "external_number": "...",
  "external_date": "2026-09-18"
}
```

Идемпотентный ключ:
`1c:<organization_uuid>:<document_uuid>:obligation:v1`.

## Clearing candidates
Запрос выполняется от Participant Passport организации. Ответ — **кандидаты**, не исполнение.

Candidate должен содержать:
- proposal_id;
- path nodes;
- matched amount/currency;
- затронутые obligations;
- новый конечный получатель, если есть redirect;
- policy/consent requirements;
- expiry.

## Consent
Операции:
- approve proposal
- reject proposal

Без явного approve расширение не должно инициировать redirect.

## Settlement instructions
Поля:
- settlement_instruction_id;
- proposal_id;
- payer;
- payee;
- amount;
- currency;
- due_date;
- status: pending | locked | settled | expired | cancelled.

Событие `settled` означает подтверждённое Core исполнение, но бухгалтерское отражение всё равно выполняется отдельным шагом в 1С.
