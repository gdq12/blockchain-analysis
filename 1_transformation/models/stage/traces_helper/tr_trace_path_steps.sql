select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    trace_id,
    trace_depth,
    ofta traces_level,
    ta  trace_step
from {{ ref('tr_table') }}
left UNNEST(trace_address) ta with offset ofta
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}