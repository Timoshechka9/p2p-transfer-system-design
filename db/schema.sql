CREATE TABLE transfers (
    transfer_id UUID PRIMARY KEY,
    initiator_user_id UUID NOT NULL,
    sender_account_id UUID NOT NULL,
    recipient_account_id UUID NOT NULL,
    amount NUMERIC(15, 2) NOT NULL
        CHECK (amount > 0),
    currency CHAR(3) NOT NULL
        CHECK (currency = 'RUB'),
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED'
        CHECK (
            status IN (
                'CREATED',
                'PROCESSING',
                'SUCCEEDED',
                'FAILED'
            )
        ),
    idempotency_key UUID NOT NULL,
    failure_code VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_different_accounts
        CHECK (sender_account_id <> recipient_account_id),
    CONSTRAINT uq_transfer_idempotency
        UNIQUE (initiator_user_id, idempotency_key)
);

CREATE TABLE transfer_status_history (
    history_id BIGSERIAL PRIMARY KEY,
    transfer_id UUID NOT NULL
        REFERENCES transfers(transfer_id),
    status VARCHAR(20) NOT NULL
        CHECK (
            status IN (
                'CREATED',
                'PROCESSING',
                'SUCCEEDED',
                'FAILED'
            )
        ),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
