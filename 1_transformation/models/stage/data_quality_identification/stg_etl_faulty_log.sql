select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index
from {{ source('ethereum', 'logs') }} l
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (
    (l.address is null)
    or 
    (l.topics is null or array_length(l.topics) = 0)
)