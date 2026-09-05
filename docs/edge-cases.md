# Edge Cases

## EC-01. Invalid Transfer Amount

If `amount <= 0`:
- the request is rejected;
- no transfer is created;
- the client receives `400 Bad Request`;
- error code: `INVALID_AMOUNT`.

---

## EC-02. Sender Account Not Found

If the sender account does not exist:
- the request is rejected;
- no transfer is created;
- the client receives `404 Not Found`;
- error code: `SENDER_ACCOUNT_NOT_FOUND`.

---

## EC-03. Recipient Account Not Found

If the recipient account does not exist:
- the request is rejected;
- no transfer is created;
- the client receives `404 Not Found`;
- error code: `RECIPIENT_ACCOUNT_NOT_FOUND`.

---

## EC-04. Sender Account Does Not Belong to Client

If the sender account belongs to another client:
- the request is rejected;
- no transfer is created;
- the client receives an authorization error;
- error code: `ACCOUNT_ACCESS_DENIED`.

---

## EC-05. Same Sender and Recipient Account

If `senderAccountId = recipientAccountId`:
- the request is rejected;
- no transfer is created;
- the client receives `400 Bad Request`;
- error code: `SAME_ACCOUNT_TRANSFER`.

---

## EC-06. Insufficient Funds

If the sender account balance is less than the transfer amount:

- the request is rejected before transfer creation;
- no transfer is stored;
- the client receives `409 Conflict`;
- error code: `INSUFFICIENT_FUNDS`.

---

## EC-07. Duplicate Request

If the client repeats a request with the same `Idempotency-Key`:
- a new transfer must not be created;
- the system returns the existing transfer;
- the existing `transferId` is reused.

---

## EC-08. Account Service Is Unavailable

If Account Service is temporarily unavailable:
- Transfer Service must not assume that the account validation succeeded;
- the transfer must not be completed;
- the client receives a temporary service error;
- the request may be retried later.

---

## EC-09. Debit Succeeded but Credit Failed

If funds were successfully debited from the sender but crediting the recipient failed:
- the transfer must not be marked as `SUCCEEDED`;
- the situation requires compensation or retry logic;
- the transfer remains in a non-successful state until consistency is restored.

This project does not implement a full compensation mechanism, but the risk is explicitly documented.

---

## EC-10. Invalid Transfer Status Transition

If the system attempts an invalid status transition, for example:

`SUCCEEDED -> PROCESSING`

the operation must be rejected.

Allowed transitions are described in `diagrams/state.md`.

---

## EC-11. Unsupported Currency

If currency is not `RUB`:
- the request is rejected;
- no transfer is created;
- the client receives `400 Bad Request`;
- error code: `UNSUPPORTED_CURRENCY`.

---

## EC-12. Transfer Not Found

If the client requests a transfer that does not exist:
- the system returns `404 Not Found`;
- error code: `TRANSFER_NOT_FOUND`.
