select 
  block_hash, 
  transaction_hash,
  log_index, 
  event_hash,
  address,
  MD5(to_json_string(topics)) topics_hash,
  MD5(to_json_string(args)) args_hash
from {{ source('ethereum', 'decoded_events') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(1) > 1