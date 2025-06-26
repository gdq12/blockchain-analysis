select 
    block_hash,
    block_number,
    block_timestamp,
    action.from_address action_from_address, 
    action.to_address action_to_address,
    action.author miner_address,
    action.value_lossless action_value_lossless,
    subtrace_count,
    trace_type,
    case 
        when trace_type = 'reward'
            and transaction_hash is null
            and action.author is not null
            and subtrace_count = 0
            and block_timestamp <= '2022-09-15'
            then 'traces_miner_miner_reward' 
        when transaction_hash is null 
            then 'traces_genesis_system_call'
        end evaluation_flag
from {{ source('ethereum', 'traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and transaction_hash is null