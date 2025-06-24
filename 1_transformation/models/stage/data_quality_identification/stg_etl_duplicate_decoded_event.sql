select 
  block_hash, 
  transaction_hash,
  log_index, 
  event_hash,
  address,
  to_json_string(topics) topics_as_string,
  to_json_string(args) args_as_string
from {{ source('ethereum', 'decoded_events') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(1) > 1