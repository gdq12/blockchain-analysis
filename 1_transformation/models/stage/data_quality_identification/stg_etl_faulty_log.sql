select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  l.address,
  array_to_string(l.topics, '') topics_as_string
from {{ source('ethereum', 'logs') }} l
where l.address is null