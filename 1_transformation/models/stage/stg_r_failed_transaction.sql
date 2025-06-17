select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  r.status
from {{ source('ethereum', 'transactions') }} tr 
join {{ source('ethereum', 'receipts') }} r on tr.transaction_hash = r.transaction_hash
where r.status = 0