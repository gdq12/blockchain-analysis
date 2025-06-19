select 
    block_hash,
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    event_hash,
    address,
    'token_transfer_spam_test' evaluation_flag
from {{ source('ethereum', 'token_transfers') }}
where coalesce(quantity, '0') = '0'