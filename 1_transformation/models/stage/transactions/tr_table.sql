select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index,
  from_address, 
  to_address,
  value,
  value_lossless,
  gas,
  gas_price,
  input,
  max_fee_per_gas,
  max_priority_fee_per_gas,
  transaction_type,
  chain_id,
  access_list
from {{ source('transactions') }}  tr
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}