select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  tr.trace_address
from {{ source('ethereum', 'traces') }} tr
where not exists (select 1 
                from {{ ref('stg_blockchain_pre_merge_miner_reward') }} mr
                where tr.block_number = mr.block_number
                and tr.action.value_lossless = mr.value_lossless
                and tr.subtrace_count = mr.subtrace_count
                and tr.trace_type = mr.trace_type
                and tr.action.author = mr.miner_address
                )
and (
    -- missing/malformed trace
    (tr.trace_address is null)
    or 
    -- inconsistent traces
    (tr.trace_type in ('call', 'create') and tr.error is not null)
    or
    (tr.trace_type = 'call' and tr.action.to_address is null)
)