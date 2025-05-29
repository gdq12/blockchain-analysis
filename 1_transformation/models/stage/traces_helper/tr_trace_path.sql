select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    trace_id,
    trace_depth,
    ARRAY_TO_STRING(
      ARRAY(
        SELECT CAST(ta AS STRING)
        FROM UNNEST(trace_address) ta WITH OFFSET
        WHERE OFFSET < ARRAY_LENGTH(trace_address) - 1
      ),
      '.'
    ) trace_id_parent,
    'TOP_LEVEL_TRACE' trace_category,
    action.from_address from_address,
    action.to_address to_address,
    action.call_type call_type, 
    action.gas gas,
    action.input input,
    action.value value,
    action.value_lossless value_lossless,
    action.init init, 
    action.author author, 
    action.reward_type reward_type,
    action.refund_address refund_address,
    action. refund_balance refund_balance,
    action.refund_balance_lossless refund_balance_lossless,
    action.self_destructed_address self_destructed_address,
    result.gas_used gas_used,
    result.output output,
    result.address result_address,
    result.code result_code
from {{ ref('tr_table') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and trace_depth = 0
union all 
select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    trace_id,
    trace_depth,
    ARRAY_TO_STRING(
      ARRAY(
        SELECT CAST(ta AS STRING)
        FROM UNNEST(trace_address) ta WITH OFFSET
        WHERE OFFSET < ARRAY_LENGTH(trace_address) - 1
      ),
      '.'
    ) trace_id_parent,
    'INTERNAL_TRACE' trace_category,
    action.from_address from_address,
    action.to_address to_address,
    action.call_type call_type, 
    action.gas gas,
    action.input input,
    action.value value,
    action.value_lossless value_lossless,
    action.init init, 
    action.author author, 
    action.reward_type reward_type,
    action.refund_address refund_address,
    action. refund_balance refund_balance,
    action.refund_balance_lossless refund_balance_lossless,
    action.self_destructed_address self_destructed_address,
    result.gas_used gas_used,
    result.output output,
    result.address result_address,
    result.code result_code
from {{ ref('tr_table') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and trace_depth > 0