select 
    block_number,
    action.author miner_address,
    action.value_lossless value_lossless,
    subtrace_count,
    trace_type
from {{ source('ethereum', 'traces') }}
where trace_type = 'reward'
and transaction_hash IS NULL
and action.author IS NOT NULL
and subtrace_count = 0
and block_timestamp <= '2022-09-15'