select
  block_hash, 
  block_number,
  block_timestamp,
  size block_size, 
  extra_data,
  gas_limit,
  gas_used,
  base_fee_per_gas,
  mix_hash,
  nonce,
  difficulty,
  total_difficulty,
  miner,
  sha3_uncles,
  transaction_count,
  transaction_root,
  receipts_root,
  state_root,
  logs_bloom,
  withdrawals_root,
  withdrawals
from {{ source('blocks') }} b
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}