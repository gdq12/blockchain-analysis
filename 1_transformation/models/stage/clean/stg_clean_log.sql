select 
    l.block_hash, 
    l.block_number, 
    l.block_timestamp, 
    l.transaction_hash, 
    l.transaction_index, 
    l.log_index, 
    l.address, 
    l.data, 
    l.topics, 
    l.removed
from {{ source('ethereum', 'logs') }} l 
left join {{ ref('stg_etl_duplicate_log') }} dl on l.block_hash = dl.block_hash
                                                and l.log_index = dl.log_index
                                                and l.address = dl.address
                                                and array_to_string(l.topics, '') = array_to_string(dl.topics, '')
                                                and l.data = dl.data
left join {{ ref('stg_etl_faulty_log') }} fl on l.block_hash = fl.block_hash
                                            and l.transaction_hash = fl.transaction_hash
                                            and l.log_index = dl.log_index
                                            and l.address = dl.address
                                            and array_to_string(l.topics, '') = array_to_string(dl.topics, '')
where dl.block_hash is null
and fl.block_hash is null 
and l.block_timestamp between between {{ var('start_time') }} and {{ var('end_time') }}
