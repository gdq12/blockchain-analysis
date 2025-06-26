select 
  trx.block_hash, 
  trx.block_number,
  trx.block_timestamp,
  trx.value_lossless,
  trx.gas,
  trx.gas_price,
  trx.from_address,
  trx.to_address,
  trx.nonce
from {{ source('ethereum', 'transactions') }} trx
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(distinct trx.transaction_hash) > 1