# Use Cases

## UC-01. Create P2P Transfer

### Actor
Authenticated bank client.

### Preconditions
- The client is authenticated.
- The sender account exists.
- The sender account belongs to the client.

### Main Flow
1. The client selects the sender account.
2. The client specifies the recipient account.
3. The client specifies the transfer amount.
4. The system validates the request.
5. The system checks that the sender has sufficient funds.
6. The system creates the transfer.
7. The system starts transfer processing.
8. The system completes the transfer.
9. The transfer status becomes `SUCCEEDED`.
10. The system returns the transfer identifier and status.

### Alternative Flows

#### A1. Insufficient funds
If the sender does not have enough funds:
- the transfer is not completed;
- the transfer receives status `FAILED`;
- the client receives an error.

#### A2. Invalid amount
If `amount <= 0`:
- the request is rejected;
- no transfer is created.

#### A3. Recipient account not found
If the recipient account does not exist:
- the request is rejected;
- no transfer is created.

#### A4. Duplicate request
If a request with the same idempotency key was already processed:
- a new transfer is not created;
- the system returns the existing transfer.

## UC-02. Get Transfer Status

### Actor
Authenticated bank client.

### Preconditions
- The transfer exists.
- The client has access to the transfer.

### Main Flow
1. The client requests transfer information.
2. The system finds the transfer by its identifier.
3. The system returns the current transfer status.

### Alternative Flow

#### A1. Transfer not found
If the transfer does not exist:
- the system returns an error.
