select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.value_lossless,
  tr.gas,
  tr.gas_price,
  tr.from_address,
  tr.to_address,
  tr.nonce
from {{ source('ethereum', 'transactions') }} tr 
group by all 
having count(distinct tr.transaction_hash) > 1