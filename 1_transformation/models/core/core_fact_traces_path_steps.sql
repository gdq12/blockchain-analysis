select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    trace_id_hash,
    trace_id,
    trace_depth,
    evaluation_flags,
    ofta traces_level,
    ta trace_step,
    {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('core_fact_traces') }}
left join UNNEST(trace_address) ta with offset ofta
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}