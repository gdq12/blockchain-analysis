select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.log_index,
  count(distinct concat(l.address,array_to_string(l.topics, '|'),l.data)) distinct_metadata_count
from {{ source('ethereum', 'logs') }} l
group by all 
having count(distinct concat(l.address,array_to_string(l.topics, '|'),l.data)) > 1