select 
    tr.block_hash, 
    tr.block_number, 
    tr.block_timestamp, 
    tr.transaction_hash, 
    tr.transaction_index, 
    tr.trace_type, 
    tr.trace_address, 
    tr.subtrace_count, 
    tr.action, 
    tr.result, 
    tr.error
from {{ source('ethereum', 'traces') }} tr 
left join {{ ref('stg_etl_duplicate_trace') }} dtr on tr.block_hash = dtr.block_hash 
                                                    and tr.transaction_hash = dtr.transaction_hash 
                                                    and ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.') = dtr.trace_id
                                                    and tr.trace_type = dtr.trace_type 
                                                    and tr.action.author = dtr.action_author 
                                                    and tr.action.from_address = dtr.action_from_address 
                                                    and tr.action.to_address = dtr.action_to_address 
                                                    and tr.action.value_lossless = dtr.action_value_lossless
left join {{ ref('stg_etl_faulty_trace') }} ftr on tr.block_hash = ftr.block_hash 
                                                and tr.transaction_hash = ftr.transaction_hash
                                                and ARRAY_TO_STRING(ARRAY(SELECT CAST(ta AS STRING) FROM UNNEST(tr.trace_address) ta), '.') = ftr.trace_id 
where dtr.block_hash is null 
and ftr.block_hash is null 
and tr.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
