select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.log_index,
  l.address,
  array_to_spring(l.topics, '') topics_as_string,
  l.data
from {{ source('ethereum', 'logs') }} l
group by all 
having count(1) > 1