select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    event_hash,
    event_signature,
    oft topic_index, 
    t topics
from {{ ref('de_table') }}
cross join UNNEST(topics) t with offset oft
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}