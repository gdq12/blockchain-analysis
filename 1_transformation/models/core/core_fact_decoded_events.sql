select 
    {{ dbt_utils.generate_surrogate_key( ['transaction_hash','log_index']) }} decoded_event_hash,
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    log_index, 
    address, 
    event_hash, 
    event_signature, 
    topics, 
    args, 
    removed,
    cast(null as string) evaluation_flags,
    {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('stg_clean_decoded_events') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}