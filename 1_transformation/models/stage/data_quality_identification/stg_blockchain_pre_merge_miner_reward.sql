select 
    block_hash,
    block_number,
    block_timestamp,
    action.author miner_address,
    action.value_lossless value_lossless,
    subtrace_count,
    trace_type
from {{ source('ethereum', 'traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and trace_type = 'reward'
and transaction_hash is null
and action.author is not null
and subtrace_count = 0
and block_timestamp <= '2022-09-15'