select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.') trace_id
from {{ source('ethereum', 'traces') }} tr
where tr.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and not exists (select 1 
                from {{ ref('stg_blockchain_trace_wo_transaction') }} mr
                where tr.block_number = mr.block_number
                and tr.action.value_lossless = mr.action_value_lossless
                and tr.subtrace_count = mr.subtrace_count
                and tr.trace_type = mr.trace_type
                and coalesce(tr.action.author, '0') = coalesce(mr.miner_address, '0')
                and coalesce(tr.action.from_address, '0') = coalesce(mr.action_from_address, '0')
                and coalesce(tr.action.to_address, '0') = coalesce(mr.action_to_address, '0')
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