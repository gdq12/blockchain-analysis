with w_eval as 
(select 
    tk.*,
    itk.evaluation_flag
from {{ ref('stg_clean_token_transfers') }} tk 
join {{ ref('stg_blockchain_incorrect_token_metadata') }} itk on tk.block_hash = itk.block_hash 
                                                            and tk.transaction_hash = itk.transaction_hash 
                                                            and tk.event_hash = itk.event_hash 
                                                            and tk.address = itk.address 
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and tk.log_index is not null
union all 
select 
    tk.*,
    stk.evaluation_flag
from {{ ref('stg_clean_token_transfers') }} tk 
join {{ ref('stg_blockchain_spam_unusual_token_transfer') }} stk on tk.block_hash = stk.block_hash 
                                                            and tk.transaction_hash = stk.transaction_hash 
                                                            and tk.event_hash = stk.event_hash 
                                                            and tk.address = stk.address 
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and tk.log_index is not null
union all
select 
    tk.*,
    ntk.evaluation_flag
from {{ ref('stg_clean_token_transfers') }} tk 
join {{ ref('stg_blockchain_undecoded_token_transfer') }} ntk on tk.block_hash = ntk.block_hash 
                                                            and tk.transaction_hash = ntk.transaction_hash 
                                                            and tk.event_hash = ntk.event_hash 
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
),
all_tk as 
(select 
    tk.*,
    cast(null as string) evalualtion_flag
from {{ ref('stg_clean_token_transfers') }} tk 
left join w_eval we on tk.block_hash = we.block_hash 
                    and tk.transaction_hash = we.transaction_hash 
                    and tk.event_hash = we.event_hash 
                    and tk.address = we.address 
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and we.block_hash is null 
union all 
select * from w_eval 
)
select 
    {{ dbt_utils.generate_surrogate_key( ['transaction_hash','log_index']) }} token_transfer_hash,
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    event_index, 
    batch_index, 
    log_index,
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
    array_agg(evaluation_flag IGNORE NULLS) evaluation_flags
from all_tk 
group by all 