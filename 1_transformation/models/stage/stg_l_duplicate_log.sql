select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.log_index,
  l.address,
  l.topics,
  l.data,
  count(1) num_repeat
from {{ source('ethereum', 'logs') }} l
group by all 
having count(1) > 1