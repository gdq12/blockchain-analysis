select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index, 
  trace_address,
  trace_type,
  action.author, 
  action.from_address action_from_address, 
  action.to_address action_to_address, 
  action.value_lossless action_value_lossless
from {{ source('ethereum', 'traces') }}
group by  all
having count(1) > 1