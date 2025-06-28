select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index, 
    log_index,
    log_hash,
    evaluation_flags,
    t topics,
    {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('core_fact_logs') }},
unnest(topics) t
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}