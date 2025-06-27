select 
    block_hash, 
    transaction_hash, 
    log_index, 
    address, 
    event_hash, 
    event_signature, 
    MD5(to_json_string(topics)) topics_hash, 
    MD5(to_json_string(args)) args_hash
from {{ source('ethereum', 'decoded_events') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (
    (args is null)
    or 
    (array_length(topics) > 4)
    or 
    (topics is null)
    or 
    (array_length(topics) = 0)
    )