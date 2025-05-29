select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    log_index,
    address,
    event_hash,
    event_signature,
    topics,
    args,
    removed 
from {{ source('decoded_events') }} 
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}