select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index,
  trace_address,
  subtrace_count
from {{ source('ethereum', 'traces') }}
where trace_type = 'call' and subtrace_count > 0