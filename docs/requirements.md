# Functional Requirements

## Scope

The system provides P2P money transfers between clients of the same bank.

## Functional Requirements

- FR-01. The system shall allow an authenticated client to create a money transfer.
- FR-02. The system shall allow the client to specify the sender account.
- FR-03. The system shall allow the client to specify the recipient account.
- FR-04. The system shall allow the client to specify the transfer amount.
- FR-05. The system shall validate that the sender account belongs to the authenticated client.
- FR-06. The system shall validate that the sender has sufficient funds.
- FR-07. The system shall create a transfer with a unique identifier.
- FR-08. The system shall allow the client to retrieve the current transfer status.

## Out of Scope

- Transfers to other banks
- Currency conversion
- Scheduled transfers
- Transfer cancellation after successful completion
- Credit funds
