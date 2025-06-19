select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  l.address,
  l.topics,
  'log_faulty_topic' evaluation_flag
from {{ source('ethereum', 'logs') }} l
where array_length(l.topics) > 4 