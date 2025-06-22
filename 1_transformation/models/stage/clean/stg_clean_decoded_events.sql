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
join {{ ref('stg_clean_log') }} l on de.block_hash = l.block_hash 
                                and de.transaction_hash = l.transaction_hash 
                                and de.log_index = l.log_index 
                                and de.address = l.address
                                and to_json_string(de.topics) = to_json_string(l.topics)
where de.block_timestamp between between {{ var('start_time') }} and {{ var('end_time') }}
),
faulty_de as 
(select 
    de.block_hash, 
    de.transaction_hash, 
    de.log_index, 
    de.address, 
    de.event_hash, 
    de.event_signature, 
    coalesce(to_json_string(de.topics), '0') topics, 
    coalesce(to_json_string(de.args), '0') args
from in_log de 
where (
    (de.args is null)
    or 
    (array_length(de.topics) > 4)
    or 
    (de.topics is null)
    or 
    (array_length(de.topics) = 0)
    )
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
    de.topics, 
    de.args, 
    de.removed
from in_log de 
where not exists in (select 1 
                    from join {{ ref('stg_etl_duplicate_decoded_event') }} dde 
                    where de.block_hash  = dde.block_hash 
                    and de.transaction_hash = dde.transaction_hash 
                    and de.log_index = dde.log_index 
                    and de.event_hash = dde.event_hash 
                    and de.address = dde.address 
                    and array_to_string(de.topics, '') = attay_to_string(dde.topics, '')
                    and to_json_string(de.args) = dde.arg_string 
                    )
and not exists in (select 1
                from faulty_de fde 
                where de.block_hash = fde.block_hash
                and de.transaction_hash = fde.transaction_hash 
                and de.log_index = fde.log_index 
                and de.address = fde.address  
                and de.event_hash = fde.event_hash 
                and coalesce(to_json_string(de.topics), '0') topics = fde.topics
                and coalesce(de.args, '0') args = fde.args
                )