# Business Rules

## Transfer Rules

- BR-01. Transfer amount must be greater than 0.
- BR-02. Only RUB transfers are supported.
- BR-03. The sender account must exist.
- BR-04. The sender account must belong to the authenticated client.
- BR-05. The recipient account must exist.
- BR-06. The sender and recipient accounts must be different.
- BR-07. The sender account must have sufficient funds for the transfer.
- BR-08. A transfer must have a unique transfer identifier.
- BR-09. Repeated requests with the same idempotency key and the same request data must not create duplicate transfers.
- BR-10. Reusing an existing idempotency key with different transfer data must be rejected.
- BR-11. A successful transfer cannot be cancelled.

## Transfer Status Rules

- BR-11. A newly created transfer has status `CREATED`.
- BR-12. A transfer being processed has status `PROCESSING`.
- BR-13. A successfully completed transfer has status `SUCCEEDED`.
- BR-14. A transfer that cannot be completed has status `FAILED`.
- BR-15. Transfer status update and corresponding status history record must be saved atomically.
