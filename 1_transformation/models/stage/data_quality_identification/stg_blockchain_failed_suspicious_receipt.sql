select 
    block_hash,
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    case 
        when gas_used is null then 'receipts_failed_reverted_transaction'
        when gas_used = 0 and status = 1 then 'receipts_suspicious_on_chain_behavior'
        end evaluation_flag
from {{ source('ethereum', 'receipts') }}
where (
    -- failed/reverted transaction
    (gas_used is null)
    or 
    -- suspicous on-chain behavior 
    (gas_used = 0 and status = 1)
)