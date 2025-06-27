select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_index,
  l.transaction_hash,
  l.log_index,
  l.address,
  MD5(to_json_string(l.topics)) topics_hash,
  l.data
from {{ source('ethereum', 'logs') }} l
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(1) > 1