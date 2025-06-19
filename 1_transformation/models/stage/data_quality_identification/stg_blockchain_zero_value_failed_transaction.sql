select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  case
    when r.status = 0 then 'transaction_failed'
    when tr.value = 0 then 'transaction_zero_value'
    end evaluation_flag
from {{ source('ethereum', 'transactions') }} tr 
join {{ source('ethereum', 'receipts') }} r on tr.transaction_hash = r.transaction_hash
where r.status = 0 or tr.value = 0