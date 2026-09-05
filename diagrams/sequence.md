# Sequence Diagram

## Successful P2P Transfer

```mermaid
sequenceDiagram
    actor Client
    participant TransferService as Transfer Service
    participant AccountService as Account Service
    participant TransferDB as Transfer DB

    Client->>TransferService: POST /transfers
    TransferService->>AccountService: Validate sender account
    AccountService-->>TransferService: Sender account is valid

    TransferService->>AccountService: Validate recipient account
    AccountService-->>TransferService: Recipient account is valid

    TransferService->>AccountService: Check sufficient funds
    AccountService-->>TransferService: Funds are sufficient

    TransferService->>TransferDB: Create transfer (CREATED)
    TransferDB-->>TransferService: Transfer created

    TransferService->>TransferDB: Update status to PROCESSING
    TransferDB-->>TransferService: Status updated

    TransferService->>AccountService: Debit sender account
    AccountService-->>TransferService: Debit successful

    TransferService->>AccountService: Credit recipient account
    AccountService-->>TransferService: Credit successful

    TransferService->>TransferDB: Update status to SUCCEEDED
    TransferDB-->>TransferService: Status updated

    TransferService-->>Client: 201 Created + transferId + SUCCEEDED

## Notes

- Account balance validation and account ownership checks are performed by Account Service.
- Transfer Service stores transfer state but does not own account balances.
- The current diagram represents a simplified successful flow.
- Failure handling and compensation for partial transfer execution are described separately in edge cases.

## Insufficient Funds

```mermaid
sequenceDiagram
    actor Client
    participant TransferService as Transfer Service
    participant AccountService as Account Service

    Client->>TransferService: POST /transfers
    TransferService->>AccountService: Check sufficient funds
    AccountService-->>TransferService: Insufficient funds

    TransferService-->>Client: 409 INSUFFICIENT_FUNDS

