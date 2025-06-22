select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index, 
  ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(trace_address) ta), '.') trace_id,
  trace_type,
  action.author action_author, 
  action.from_address action_from_address, 
  action.to_address action_to_address, 
  action.value_lossless action_value_lossless
from {{ source('ethereum', 'traces') }}
group by  all
having count(1) > 1