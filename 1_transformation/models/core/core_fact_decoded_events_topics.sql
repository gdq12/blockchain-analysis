select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    log_index, 
    decoded_event_hash,
    event_hash,
    event_signature,
    evaluation_flags,
    oft topic_index, 
    t topics
from {{ ref('core_fact_decoded_events') }}
cross join UNNEST(topics) t with offset oft
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}