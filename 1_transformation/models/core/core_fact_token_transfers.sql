with t1 as 
(select 
    tk.*, 
    array_agg(w_eval.evaluation_flag IGNORE NULLS) evaluation_flags
from {{ ref('stg_clean_token_transfers') }} tk
left join (select 
                itk.block_hash, itk.transaction_hash, itk.event_index, itk.evaluation_flag
            from {{ ref('stg_blockchain_incorrect_token_metadata') }} itk 
            where itk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            union all 
            select 
                stk.block_hash, stk.transaction_hash, stk.event_index, stk.evaluation_flag
            from {{ ref('stg_blockchain_spam_unusual_token_transfer') }} stk
            where stk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            union all 
            select 
                utk.block_hash, utk.transaction_hash, utk.event_index, utk.evaluation_flag
            from {{ ref('stg_blockchain_undecoded_token_transfer') }} utk 
            where utk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
            ) w_eval on tk.block_hash = w_eval.block_hash 
                    and tk.transaction_hash = w_eval.transaction_hash 
                    and tk.event_index = w_eval.event_index
group by all 
)
select 
    {{ dbt_utils.generate_surrogate_key( ['transaction_hash','event_index']) }} token_transfer_hash,
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    event_index, 
    batch_index, 
    address, 
    event_type, 
    event_hash, 
    event_signature, 
    operator_address, 
    from_address, 
    to_address, 
    token_id, 
    quantity, 
    removed, 
    evaluation_flags
from t1 