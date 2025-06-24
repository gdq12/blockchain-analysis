with in_log as 
(select 
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
                                and de.address = l.address
                                and to_json_string(de.topics) = to_json_string(l.topics)
where de.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
),
faulty_de as 
(select 
    de.block_hash, 
    de.transaction_hash, 
    de.log_index, 
    de.address, 
    de.event_hash
from in_log de 
join {{ ref('stg_etl_faulty_decoded_event') }} fde on de.block_hash = fde.block_hash
                                                and de.transaction_hash = fde.transaction_hash 
                                                and de.log_index = fde.log_index 
                                                and de.address = fde.address  
                                                and de.event_hash = fde.event_hash 
                                                and coalesce(to_json_string(de.topics), '0') = fde.topics_as_string
                                                and coalesce(to_json_string(de.args), '0') = fde.args_as_string

),
dup_de as 
(select 
    de.block_hash, 
    de.transaction_hash, 
    de.log_index, 
    de.address, 
    de.event_hash
from in_log de 
join {{ ref('stg_etl_duplicate_decoded_event') }} dde on de.block_hash  = dde.block_hash 
                    and de.transaction_hash = dde.transaction_hash 
                    and de.log_index = dde.log_index 
                    and de.event_hash = dde.event_hash 
                    and de.address = dde.address 
                    and coalesce(to_json_string(de.topics), '0') = dde.topics_as_string
                    and coalesce(to_json_string(de.args), '0') = dde.args_as_string

)
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
from in_log de 
where not exists (select 1 
                    from dup_de dde 
                    where de.block_hash  = dde.block_hash 
                    and de.transaction_hash = dde.transaction_hash 
                    and de.log_index = dde.log_index 
                    and de.event_hash = dde.event_hash 
                    and de.address = dde.address 
                    )
and not exists (select 1
                from faulty_de fde 
                where de.block_hash = fde.block_hash
                and de.transaction_hash = fde.transaction_hash 
                and de.log_index = fde.log_index 
                and de.address = fde.address  
                and de.event_hash = fde.event_hash 
                )