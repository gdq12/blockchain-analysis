select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    log_index,
    address,
    data,
    topics,
    removed
from {{ source('logs') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}