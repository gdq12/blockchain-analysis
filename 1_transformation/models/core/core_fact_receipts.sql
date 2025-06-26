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
    r.status,
    array_agg(sr.evaluation_flag IGNORE NULLS) evaluation_flags
from {{ ref('stg_clean_receipts') }} r 
left join {{ ref('stg_blockchain_failed_suspicious_receipt') }} sr on r.block_hash = sr.block_hash 
                                                                and r.transaction_hash = sr.transaction_hash 
where r.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 