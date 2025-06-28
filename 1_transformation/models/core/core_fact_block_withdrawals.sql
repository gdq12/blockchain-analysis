select 
    b.block_hash, 
    b.block_number, 
    b.block_timestamp, 
    b.evaluation_flags,
    w.address,
    w.amount,
    w.amount_lossless,
    w.index,
    w.validator_index,
    {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('core_fact_blocks') }} b
cross join unnest(withdrawals) w
where b.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}