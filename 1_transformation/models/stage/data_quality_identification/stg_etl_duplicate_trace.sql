select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index, 
  MD5(ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(trace_address) ta), '.')) trace_hash,
  trace_type,
  action.author action_author, 
  action.from_address action_from_address, 
  action.to_address action_to_address, 
  action.value_lossless action_value_lossless
from {{ source('ethereum', 'traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by  all
having count(1) > 1