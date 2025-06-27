select 
    block_hash,
    block_number,
    block_timestamp,
    action.author action_author_address,
    MD5(
        COALESCE(
            ARRAY_TO_STRING(
            ARRAY(
                SELECT CAST(ta AS STRING)
                FROM UNNEST(trace_address) ta
            ), '.'
            ),
            'null'
            )
        ) trace_hash,
    trace_address,
    subtrace_count,
    trace_type,
    action.value_lossless action_value_lossless,
    case 
        when trace_type = 'reward'
            and transaction_hash is null
            and action.author is not null
            and subtrace_count = 0
            and block_timestamp <= '2022-09-15'
            then 'traces_miner_miner_reward' 
        when transaction_hash is null 
            and trace_address is null 
            and trace_type in ('call', 'create')
            then 'traces_genesis_system_call'
        end evaluation_flag
from {{ source('ethereum', 'traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (
    (trace_type = 'reward'
    and transaction_hash is null
    and action.author is not null
    and subtrace_count = 0
    and block_timestamp <= '2022-09-15'
    )
    or 
    (transaction_hash is null 
    and trace_address is null 
    and trace_type in ('call', 'create')
    )
)
