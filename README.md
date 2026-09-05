# P2P Transfer System Design

A small pet project where I designed a simplified P2P transfer flow between clients of the same bank.

The goal was to practice the parts of system analysis that usually come together in one feature: requirements, business rules, API contract, database model, state transitions, failure scenarios and asynchronous events.

## What is covered

The current version supports transfers between two accounts inside the same bank.

The flow includes:

- sender and recipient validation;
- account ownership validation;
- balance check;
- transfer creation and status tracking;
- protection against duplicate requests using an idempotency key;
- transfer status history;
- authentication using a bearer token;
- basic failure scenarios;
- publishing a transfer status change event.

Only RUB transfers are considered.

Out of scope:

- transfers to other banks;
- currency conversion;
- scheduled transfers;
- cancellation of successful transfers;
- credit funds.

## Transfer flow

A successful transfer looks roughly like this:

`Client → Transfer Service → Account Service → Transfer DB`

The Transfer Service validates the request, checks the accounts and available funds through Account Service, creates a transfer and moves it through the following states:

`CREATED → PROCESSING → SUCCEEDED`

If processing fails after the transfer has already been created:

`CREATED → PROCESSING → FAILED`

Validation errors such as invalid amount, unsupported currency or insufficient funds are handled before transfer creation.

A high-level system overview is available in the [context diagram](diagrams/context.md).

More detailed flows are shown in the [sequence diagrams](diagrams/sequence.md) and [state diagram](diagrams/state.md).

## API

The service exposes two main operations:

```http
POST /api/v1/transfers
GET /api/v1/transfers/{transferId}
```

Requests are authenticated using a bearer token.

The authenticated user is determined by the system and is not passed explicitly in the transfer request.

`POST /transfers` also requires an `Idempotency-Key` header so that retrying the same client request does not create another transfer.

The full contract is described in [OpenAPI](api/openapi.yaml).

## Data model

Transfer Service owns two main entities:

- `transfers` — current transfer data and status;
- `transfer_status_history` — history of status changes.

Account balances are deliberately not stored in this service.

Account validation, ownership checks and balance checks are delegated to Account Service.

The SQL schema is available in [schema.sql](db/schema.sql).

I also added several example queries in [queries.sql](db/queries.sql).

## Design notes

### Idempotency

Each transfer request contains an `Idempotency-Key`.

If the same user repeats the same request with the same key, a new transfer is not created and the existing transfer is returned.

If the same key is reused with different transfer data, the request is rejected.

At the database level duplicate transfer creation is prevented by a unique constraint on:

```text
(initiator_user_id, idempotency_key)
```

### Account ownership

The client sends `senderAccountId`, but does not send the user ID that owns the account.

The authenticated user is determined by the system, and Account Service is responsible for checking that the sender account actually belongs to this user.

### Transfer states

A valid transfer follows this lifecycle:

`CREATED → PROCESSING → SUCCEEDED`

or:

`CREATED → PROCESSING → FAILED`

`SUCCEEDED` and `FAILED` are terminal states in the current version.

Validation errors are handled before transfer creation and therefore do not result in a `FAILED` transfer.

### Status history

The `transfers` table stores the current transfer status.

The `transfer_status_history` table stores every status change.

A status update and the corresponding history record should be saved atomically in a single database transaction.

### Partial execution

One of the problematic cases is:

```text
sender debit succeeded
recipient credit failed
```

The transfer must not be marked as `SUCCEEDED` in this situation.

A production payment system would require retry or compensation logic.

I did not implement a complete compensation mechanism here, but documented the problem in [edge cases](docs/edge-cases.md).

### Event publication

When a transfer changes status, Transfer Service may publish a `TRANSFER_STATUS_CHANGED` event.

A possible problem is:

```text
transfer state saved successfully
event publication failed
```

The transfer state should not be rolled back only because notification or event delivery failed.

A production implementation could use the Transactional Outbox pattern for reliable event delivery.

The full outbox implementation is outside the scope of this project.

## Repository navigation

- [Functional requirements](docs/requirements.md)
- [Business rules](docs/business-rules.md)
- [Use cases](docs/use-cases.md)
- [Edge cases](docs/edge-cases.md)
- [OpenAPI specification](api/openapi.yaml)
- [Database schema](db/schema.sql)
- [SQL examples](db/queries.sql)
- [System context diagram](diagrams/context.md)
- [Sequence diagrams](diagrams/sequence.md)
- [Transfer state diagram](diagrams/state.md)
- [Transfer status event example](events/transfer-status-changed.json)

## Event example

When a transfer changes its status, Transfer Service can publish a `TRANSFER_STATUS_CHANGED` event.

This event could later be consumed by a notification or analytics service.

An example payload is available in [transfer-status-changed.json](events/transfer-status-changed.json).

## About

This is an educational project created for practicing system analysis.

The services, API and data used here are fictional and are not based on any real banking system.
