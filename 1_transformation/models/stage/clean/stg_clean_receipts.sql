select 
    r.block_hash, 
    r.block_number, 
    r.block_timestamp, 
    r.transaction_hash, 
    r.transaction_index, 
    r.from_address, 
    r.to_address, 
    r.contract_address, 
    r.cumulative_gas_used, 
    r.gas_used, 
    r.effective_gas_price, 
    r.logs_bloom, 
    r.root, 
    r.status
from {{ source('ethereum', 'receipts') }} r 
join {{ ref('stg_clean_transactions') }} tr on r.block_hash = tr.block_hash 
                                            and r.transaction_hash = tr.transaction_hash
                                            and r.from_address = tr.from_address 
                                            and r.to_address = tr.from_address
where r.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}