select 
    block_hash, 
    transaction_hash, 
    log_index, 
    address, 
    event_hash, 
    event_signature, 
    coalesce(to_json_string(topics), '0') topics_as_string, 
    coalesce(to_json_string(args), '0') args_as_string
from {{ source('ethereum', 'decoded_events') }}
where (
    (args is null)
    or 
    (array_length(topics) > 4)
    or 
    (topics is null)
    or 
    (array_length(topics) = 0)
    )