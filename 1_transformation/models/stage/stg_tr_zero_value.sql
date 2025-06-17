select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  tr.value
from {{ source('ethereum', 'transactions') }} tr 
where tr.value = 0 