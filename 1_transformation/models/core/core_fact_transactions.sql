with w_eval as 
(select 
    trx.*, 
    dtrx.evaluation_flag
from {{ ref('stg_clean_transactions') }} trx
join {{ ref('stg_blockchain_duplicate_transaction') }} dtrx on trx.block_hash = dtrx.block_hash
                                                            and trx.value_lossless = dtrx.value_lossless
                                                            and trx.gas = dtrx.gas
                                                            and trx.from_address = dtrx.from_address
                                                            and trx.to_address = dtrx.to_address
                                                            and trx.nonce = dtrx.nonce
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }} 
union all 
select 
    trx.*, 
    ftrx.evaluation_flag
from {{ ref('stg_clean_transactions') }} trx
join {{ ref('stg_blockchain_zero_value_failed_transaction') }} ftrx on trx.block_hash = ftrx.block_hash 
                                                                  and trx.transaction_hash = ftrx.transaction_hash 
where trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }} 
),
all_tr as
(select 
    trx.*, 
    cast(null as string) evaluation_flag
from {{ ref('stg_clean_transactions') }} trx
left join w_eval we on trx.block_hash = we.block_hash
                    and trx.transaction_hash = we.transaction_hash
where trx.block_timestamp between '2022-09-01 17:00:00' and '2022-09-01 18:00:00' 
and we.block_hash is null
union all 
select * from w_eval
)
select 
    block_hash, 
    block_number, 
    block_timestamp, 
    transaction_hash, 
    transaction_index, 
    nonce, 
    from_address, 
    to_address, 
    value, 
    value_lossless, 
    gas, 
    gas_price, 
    input, 
    max_fee_per_gas, 
    max_priority_fee_per_gas, 
    transaction_type, 
    chain_id, 
    access_list, 
    r, 
    s, 
    v, 
    y_parity,
    array_agg(evaluation_flag IGNORE NULLS) evaluation_flags
from all_tr 
group by all 