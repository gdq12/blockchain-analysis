select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  l.address,
  to_json_string(l.topics) topics_as_string,
  'log_faulty_topic' evaluation_flag
from {{ source('ethereum', 'logs') }} l
where l. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (array_length(l.topics) > 4 
    or l.topics is null 
    or array_length(l.topics) = 0
    )