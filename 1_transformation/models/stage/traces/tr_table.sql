select
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    transaction_type,
    transaction_address, 
    ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(trace_address) ta), '.')  trace_id,
    array_length(trace_address) trace_depth,
    subtrace_count,
    error,
    action, 
    result
from {{ source('traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}