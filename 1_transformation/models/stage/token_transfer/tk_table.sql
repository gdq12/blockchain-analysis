select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    address token_address,
    event_type,
    event_hash,
    event_signature,
    event_index,
    batch_index,
    operator_address,
    from_address,
    to_address, 
    quantity,
    token_id,
    removed
from {{ source('token_transfer') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}