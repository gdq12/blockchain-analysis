select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.log_index,
  l.address,
  array_to_string(l.topics, '') topics_as_string,
  l.data
from {{ source('ethereum', 'logs') }} l
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(1) > 1