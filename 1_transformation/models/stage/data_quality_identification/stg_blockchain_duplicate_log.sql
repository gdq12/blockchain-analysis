select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.transaction_hash,
  l.transaction_index,
  l.log_index,
  'log_reorg_index_data_corruption_issue' evaluation_flag
from {{ source('ethereum', 'logs') }} l
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(distinct concat(l.address,array_to_string(l.topics, '|'),l.data)) > 1