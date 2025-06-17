select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index,
  trace_address,
  error
from {{ source('ethereum', 'traces') }}
where error is not null 