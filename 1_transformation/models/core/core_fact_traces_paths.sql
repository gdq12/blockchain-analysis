with t1 as
(select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    trace_id_hash,
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
    case 
        when trace_depth = 0
            then 'top_level_trace'
        else 'internal_trace' 
        end trace_category,
    evaluation_flags,
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
    action.refund_balance refund_balance,
    action.refund_balance_lossless refund_balance_lossless,
    action.self_destructed_address self_destructed_address,
    result.gas_used gas_used,
    result.output output,
    result.address result_address,
    result.code result_code
from {{ ref('core_fact_traces') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
)
select 
  {{ dbt_utils.generate_surrogate_key( ['transaction_hash','trace_id', 'trace_id_parent', 'trace_depth']) }} trace_path_hash,
  block_hash, 
  block_number,
  block_timestamp,
  transaction_hash,
  transaction_index,
  trace_id_hash,
  trace_id,
  trace_depth,
  trace_id_parent,
  trace_category,
  evaluation_flags,
  from_address,
  to_address,
  call_type, 
  gas,
  input,
  value,
  value_lossless,
  init, 
  author, 
  reward_type,
  refund_address,
  refund_balance,
  refund_balance_lossless,
  self_destructed_address,
  gas_used,
  output,
  result_address,
  result_code,
  {{ dbt.current_timestamp() }} transformation_dt
from t1 