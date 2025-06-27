with t1 as 
(select 
    l.*,
    array_agg(excl.evaluation_flag IGNORE NULLS) evaluation_flags
from {{ ref('stg_clean_logs') }} l
left join (select 
                dlg.block_hash, dlg.transaction_hash, dlg.transaction_index, dlg.log_index, dlg.evaluation_flag
            from {{ ref('stg_blockchain_duplicate_log') }} dlg 
            where dlg.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            union all 
            select 
                flg.block_hash, flg.transaction_hash, flg.transaction_index, flg.log_index, flg.evaluation_flag
            from {{ ref('stg_blockchain_faulty_log') }} flg 
            where flg.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            ) excl on l.block_hash = excl.block_hash 
                    and l.transaction_hash = excl.transaction_hash 
                    and l.transaction_index = excl.transaction_index 
                    and l.log_index = excl.log_index
where l.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
)
select 
    {{ dbt_utils.generate_surrogate_key( ['block_hash', 'transaction_hash', 'transaction_index', 'log_index']) }} log_hash,
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
    evaluation_flags
from t1