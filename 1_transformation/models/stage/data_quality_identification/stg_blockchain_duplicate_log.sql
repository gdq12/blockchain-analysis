select 
  l.block_hash, 
  l.block_number,
  l.block_timestamp,
  l.log_index,
  'log_reorg_index_data_corruption_issue' evaluation_flag
from {{ source('ethereum', 'logs') }} l
group by all 
having count(distinct concat(l.address,array_to_string(l.topics, '|'),l.data)) > 1