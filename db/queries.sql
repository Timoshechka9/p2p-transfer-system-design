-- 1. Get transfer by ID

SELECT
    transfer_id,
    initiator_user_id,
    sender_account_id,
    recipient_account_id,
    amount,
    currency,
    status,
    failure_code,
    created_at,
    updated_at
FROM transfers
WHERE transfer_id = :transfer_id;


-- 2. Get transfer status history

SELECT
    status,
    changed_at
FROM transfer_status_history
WHERE transfer_id = :transfer_id
ORDER BY changed_at ASC;


-- 3. Count successful transfers by user

SELECT
    initiator_user_id,
    COUNT(*) AS successful_transfers
FROM transfers
WHERE status = 'SUCCEEDED'
GROUP BY initiator_user_id
ORDER BY successful_transfers DESC;


-- 4. Calculate total successful transfer amount by user

SELECT
    initiator_user_id,
    SUM(amount) AS total_amount
FROM transfers
WHERE status = 'SUCCEEDED'
GROUP BY initiator_user_id
ORDER BY total_amount DESC;


-- 5. Find failed transfers

SELECT
    transfer_id,
    initiator_user_id,
    amount,
    failure_code,
    created_at
FROM transfers
WHERE status = 'FAILED'
ORDER BY created_at DESC;


-- 6. Count failed transfers by failure reason

SELECT
    failure_code,
    COUNT(*) AS failures_count
FROM transfers
WHERE status = 'FAILED'
GROUP BY failure_code
ORDER BY failures_count DESC;
