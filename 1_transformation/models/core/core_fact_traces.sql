with w_eval as 
(select 
    tr.*,
    ftr.evaluation_flag
from {{ ref('stg_clean_traces') }} tr 
join {{ ref('stg_blockchain_failed_faulty_trace') }} ftr on tr.block_hash = ftr.block_hash 
                                                            and tr.transaction_hash = ftr.transaction_hash 
                                                            and ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.') = ftr.trace_address_as_string
where tr. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
union all 
select 
    tr.*,
    wotrx.evaluation_flag
from {{ ref('stg_clean_traces') }} tr 
join {{ ref('stg_blockchain_trace_wo_transaction') }} wotrx on tr.block_hash = wotrx.block_hash 
                                                            and coalesce(tr.action.author, '0') = coalesce(wotrx.miner_address , '0')
                                                            and coalesce(tr.action.from_address, '0') = coalesce(wotrx.action_from_address, '0')
                                                            and coalesce(tr.action.to_address, '0') = coalesce(wotrx.action_to_address, '0')
                                                            and tr.action.value_lossless = wotrx.action_value_lossless
                                                            and tr.subtrace_count = wotrx.subtrace_count 
                                                            and tr.trace_type = wotrx.trace_type 
where tr. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
), 
all_tr as 
(select 
    tr.*,
    cast(null as string) evaluation_flag
from {{ ref('stg_clean_traces') }} tr 
left join w_eval we on tr.transaction_hash = we.transaction_hash 
                    and tr.trace_id = we.trace_id
where tr. block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
union all 
select * from w_eval
)
select 
    {{ dbt_utils.generate_surrogate_key( ['transaction_hash','trace_id']) }} trace_hash,
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
    array_agg(evaluation_flag IGNORE NULLS) evaluation_flags
from all_tr
group by all 