select 
  trx.block_hash, 
  trx.block_number,
  trx.block_timestamp,
  trx.transaction_hash,
  trx.transaction_index,
  case
    when r.status = 0 then 'transaction_failed'
    when trx.value = 0 then 'transaction_zero_value'
    end evaluation_flag
from {{ source('ethereum', 'transactions') }} trx
join {{ source('ethereum', 'receipts') }} r on trx.transaction_hash = r.transaction_hash
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (r.status = 0 or trx.value = 0)