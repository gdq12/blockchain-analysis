select 
    trx.block_hash, 
    trx.block_number,
    trx.block_timestamp,
    trx.transaction_hash,
    trx.transaction_index,
    trx.evaluation_flags,
    al.address,
    al.storage_keys 
from {{ ref('core_fact_transactions') }} trx
cross join unnest(access_list) al
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}