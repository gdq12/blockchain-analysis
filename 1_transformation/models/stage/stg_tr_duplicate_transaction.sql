select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.value_lossless,
  tr.gas,
  tr.from_address,
  tr.to_address,
  tr.nonce,
  count(distinct tr.transaction_hash) num_transaction_hash,
  array_agg(tr.transaction_hash) transaction_hash_list
from {{ source('ethereum', 'transactions') }} tr 
group by all 
having count(distinct tr.transaction_hash) > 1