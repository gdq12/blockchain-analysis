select 
    de.block_hash, 
    de.block_number, 
    de.block_timestamp, 
    de.transaction_hash, 
    de.transaction_index, 
    de.log_index, 
    de.address, 
    de.event_hash, 
    de.event_signature, 
    de.topics, 
    de.args, 
    de.removed
from {{ source('ethereum', 'decoded_events') }} de 
join {{ ref('stg_clean_logs') }} l on de.block_hash = l.block_hash 
                                and de.transaction_hash = l.transaction_hash 
                                and de.log_index = l.log_index 
left join (select 
                de.block_hash, de.transaction_hash, de.log_index
            from {{ source('ethereum', 'decoded_events') }} de 
            join {{ ref('stg_etl_faulty_decoded_event') }} fde on de.block_hash = fde.block_hash
                                                            and de.transaction_hash = fde.transaction_hash 
                                                            and de.log_index = fde.log_index 
                                                            and de.address = fde.address  
                                                            and de.event_hash = fde.event_hash 
                                                            and MD5(to_json_string(de.topics)) = fde.topics_hash
                                                            and MD5(to_json_string(de.args)) = fde.args_hash
            where de.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            union all
            select 
                de.block_hash, de.transaction_hash, de.log_index
            from {{ source('ethereum', 'decoded_events') }} de  
            join {{ ref('stg_etl_duplicate_decoded_event') }} dde on de.block_hash  = dde.block_hash 
                                and de.transaction_hash = dde.transaction_hash 
                                and de.log_index = dde.log_index 
            where de.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            ) excl on de.block_hash = excl.block_hash 
                    and de.transaction_hash = excl.transaction_hash 
                    and de.log_index = excl.log_index
where de.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and excl.block_hash is null 