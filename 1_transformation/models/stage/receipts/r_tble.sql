select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    from_address,
    to_address,
    contract_address,
    cumulative_gas_used,
    gas_used,
    effective_gas_used,
    logs_bloom,
    root,
    status
from {{ source('receipts') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}