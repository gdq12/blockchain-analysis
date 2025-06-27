select 
  tr.block_hash, 
  tr.block_number,
  tr.block_timestamp,
  tr.transaction_hash,
  tr.transaction_index,
  MD5(ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.')) trace_hash
from {{ source('ethereum', 'traces') }} tr
where tr.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and not exists (select 1 
                from {{ ref('stg_blockchain_trace_wo_transaction') }} mr
                where tr.block_number = mr.block_number
                and tr.subtrace_count = mr.subtrace_count
                and tr.trace_type = mr.trace_type
                and tr.action.value_lossless = mr.action_value_lossless
                and coalesce(tr.action.author, '0x0000000000000000000000000000000000000000') = coalesce(mr.action_author_address, '0x0000000000000000000000000000000000000000')
                and tr.trace_address[SAFE_OFFSET(0)] = mr.trace_address[SAFE_OFFSET(0)] 
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