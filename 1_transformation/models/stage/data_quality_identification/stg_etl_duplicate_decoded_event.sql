select 
  block_hash, 
  transaction_hash,
  log_index, 
  event_hash,
  address,
  topics,
  to_json_string(args) args_string
from {{ source('ethereum', 'decoded_events') }}
group by all 
having count(1) > 1