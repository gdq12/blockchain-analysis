select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  l.address,
  l.topics
from {{ source('ethereum', 'logs') }} l
where l.address is null