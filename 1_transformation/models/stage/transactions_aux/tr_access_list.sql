select 
    tr.block_hash, 
    tr.block_number,
    tr.block_timestamp,
    tr.transaction_hash,
    tr.transaction_index,
    al.address,
    al.storage_keys 
from {{ ref('tr_table') }} tr
cross join (access_list) al
where tr.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}