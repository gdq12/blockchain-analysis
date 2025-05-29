select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index, 
    log_index,
    t topics
from {{ ref('l_table') }},
unnest(topics) t
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}