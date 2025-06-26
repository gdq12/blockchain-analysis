with w_eval as 
(select 
    l.*,
    dlg.evaluation_flag
from {{ ref('stg_clean_logs') }} l
join {{ ref('stg_blockchain_duplicate_log') }} dlg on l.block_hash = dlg.block_hash 
                                                and l.log_index = dlg.log_index
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
union all 
select 
    l.*,
    flg.evaluation_flag
from {{ ref('stg_clean_logs') }} l
join {{ ref('stg_blockchain_faulty_log') }} flg on l.block_hash = flg.block_hash 
                                                and l.log_index = flg.log_index
                                                and l.transaction_hash = flg.transaction_hash
                                                and l.address = flg.address
                                                and to_json_string(l.topics) = flg.topics_as_string
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
), 
all_l as 
(select 
    l.*,
    cast(null as string) evaluation_flag
from {{ ref('stg_clean_logs') }} l
left join w_eval we on l.block_hash = we.block_hash 
                    and l.transaction_hash = we.transaction_hash 
                    and l.log_index = we.log_index 
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and we.block_hash is null 
union all 
select * from w_eval
)
select 
    {{ dbt_utils.generate_surrogate_key( ['block_hash','log_index']) }} log_hash,
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    log_index, 
    address, 
    data, 
    topics, 
    removed,
    array_agg(evaluation_flag IGNORE NULLS) evaluation_flags
from all_l
group by all 