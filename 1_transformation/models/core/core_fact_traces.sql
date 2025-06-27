with t1 as 
(select 
    tr.*,
    array_agg(excl.evaluation_flag IGNORE NULLS) evaluation_flags
from {{ ref('stg_clean_traces') }} tr 
left join (select 
                ftr.block_hash,
                ftr.transaction_hash, 
                coalesce(ftr.action_author, '0x0000000000000000000000000000000000000000') action_author_address, 
                ftr.action_value_lossless, 
                ftr.subtrace_count,
                ftr.trace_type, 
                ftr.trace_hash, 
                ftr.evaluation_flag
            from {{ ref('stg_blockchain_failed_faulty_trace') }} ftr 
            where ftr. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            union all 
            select 
                wotr.block_hash,
                '0x0000000000000000000000000000000000000000000000000000000000000000' transaction_hash,
                coalesce(wotr.action_author_address, '0x0000000000000000000000000000000000000000') action_author_address, 
                wotr.action_value_lossless, 
                wotr.subtrace_count,
                wotr.trace_type, 
                wotr.trace_hash, 
                wotr.evaluation_flag
            from {{ ref('stg_blockchain_trace_wo_transaction') }} wotr 
            where wotr. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            ) excl on tr.block_hash = excl.block_hash 
                and coalesce(tr.transaction_hash, '0x0000000000000000000000000000000000000000000000000000000000000000') = excl.transaction_hash
                and coalesce(tr.action.author, '0x0000000000000000000000000000000000000000') = excl.action_author_address
                and tr.action.value_lossless = excl.action_value_lossless
                and tr.subtrace_count = excl.subtrace_count
                and tr.trace_type = excl.trace_type 
                and MD5(COALESCE(ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.'),'null')) = excl.trace_hash
where tr.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
)
select 
    {{ dbt_utils.generate_surrogate_key( ['transaction_hash','trace_id']) }} trace_id_hash,
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    trace_type, 
    trace_address, 
    trace_id,
    trace_depth,
    subtrace_count, 
    action, 
    result, 
    error,
    evaluation_flags
from t1