select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  l.address,
  l.topics,
  array_length(l.topics) num_topic
from {{ source('ethereum', 'logs') }} l
where array_length(l.topics) > 4 or l.address is null