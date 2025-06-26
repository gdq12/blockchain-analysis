select 
  trx.block_hash, 
  trx.block_number,
  trx.block_timestamp,
  trx.value_lossless,
  trx.gas,
  trx.from_address,
  trx.to_address,
  trx.nonce,
  'transaction_user_multi_trigger_transaction' evaluation_flag
from {{ source('ethereum', 'transactions') }} trx
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(distinct trx.transaction_hash) > 1