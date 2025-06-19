select 
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index,
  trace_address,
  case 
    when array_length(trace_address) > 10 then 'trace_suspicious_deep_nesting'
    when exists (select x from unnest(trace_address) as x where x < 0) then 'trace_malformed_negative_index'
    when trace_type = 'delegatecall' and action.value > 0 then 'trace_inconsistent_trace'
    when error is not null then 'trace_failed'
    end evaluation_flag
from {{ source('ethereum', 'traces') }}
where (
    -- failed trace
    (error is not null )
    or
    -- missing/malformed trace
    (array_length(trace_address) > 10)
    or 
    (exists (select x from unnest(trace_address) as x where x < 0))
    -- inconsistent traces
    or
    (trace_type = 'delegatecall' and action.value > 0)
)