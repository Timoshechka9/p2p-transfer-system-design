# P2P Transfer System Design

A small pet project where I designed a simplified P2P transfer flow between clients of the same bank.

The goal was to practice the parts of system analysis that usually come together in one feature: requirements, business rules, API contract, database model, state transitions and failure scenarios.

## What is covered

The current version supports transfers between two accounts inside the same bank.

The flow includes:

- sender and recipient validation;
- balance check;
- transfer creation and status tracking;
- protection against duplicate requests using an idempotency key;
- transfer status history;
- basic failure scenarios;
- publishing a status change event.

Only RUB transfers are considered. Cross-bank transfers, currency conversion and scheduled transfers are outside the scope of this project.

## Transfer flow

A successful transfer looks roughly like this:

`Client → Transfer Service → Account Service → Transfer DB`

The Transfer Service validates the request, checks the accounts and available funds through Account Service, creates a transfer and moves it through the following states:

`CREATED → PROCESSING → SUCCEEDED`

If processing cannot be completed:

`PROCESSING → FAILED`

More detailed flows are shown in the [sequence diagrams](diagrams/sequence.md) and [state diagram](diagrams/state.md).

## API

The service exposes two main operations:

```http
POST /api/v1/transfers
GET /api/v1/transfers/{transferId}
```

`POST /transfers` requires an `Idempotency-Key` header so that retrying the same client request does not create another transfer.

The full contract is described in [OpenAPI](api/openapi.yaml).

## Data model

Transfer Service owns two main entities:

- `transfers` — current transfer data and status;
- `transfer_status_history` — history of status changes.

Account balances are deliberately not stored in this service. Account validation and balance checks are delegated to Account Service.

The SQL schema is available in [schema.sql](db/schema.sql).

I also added several example queries in [queries.sql](db/queries.sql).

## Design notes

### Idempotency

A repeated request from the same user with the same idempotency key must return the already created transfer instead of creating a new one.

At the database level this is backed by a unique constraint on:

```text
(initiator_user_id, idempotency_key)
```

### Account ownership

The client sends `senderAccountId`, but does not send the user ID that owns the account.

The authenticated user is determined by the system, and Account Service is responsible for checking that the sender account actually belongs to this user.

### Partial execution

One of the problematic cases is:

```text
sender debit succeeded
recipient credit failed
```

The transfer must not be marked as `SUCCEEDED` in this situation.

A production payment system would require retry or compensation logic. I did not implement a complete compensation mechanism here, but documented the problem in [edge cases](docs/edge-cases.md).

## Repository navigation

- [Functional requirements](docs/requirements.md)
- [Business rules](docs/business-rules.md)
- [Use cases](docs/use-cases.md)
- [Edge cases](docs/edge-cases.md)
- [OpenAPI specification](api/openapi.yaml)
- [Database schema](db/schema.sql)
- [SQL examples](db/queries.sql)
- [Sequence diagrams](diagrams/sequence.md)
- [Transfer state diagram](diagrams/state.md)
- [Transfer status event example](events/transfer-status-changed.json)

## Event example

When a transfer changes its status, Transfer Service can publish a `TRANSFER_STATUS_CHANGED` event.

For example, this event could later be consumed by a notification or analytics service.

An example payload is available in [transfer-status-changed.json](events/transfer-status-changed.json).

## About

This is an educational project created for practicing system analysis.

The services, API and data used here are fictional and are not based on any real banking system.
