select 
    trx.block_hash, 
    trx.block_number, 
    trx.block_timestamp, 
    trx.transaction_hash, 
    trx.transaction_index, 
    trx.nonce, 
    trx.from_address, 
    trx.to_address, 
    trx.value, 
    trx.value_lossless, 
    trx.gas, 
    trx.gas_price, 
    trx.input, 
    trx.max_fee_per_gas, 
    trx.max_priority_fee_per_gas, 
    trx.transaction_type, 
    trx.chain_id, 
    trx.access_list, 
    trx.r, 
    trx.s, 
    trx.v, 
    trx.y_parity,
    array_agg(evaluation_flag IGNORE NULLS) evaluation_flags,
    {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('stg_clean_transactions') }} trx
left join (select 
                trx.block_hash, trx.transaction_hash, trx.transaction_index, dtrx.evaluation_flag
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
                ftrx.block_hash, ftrx.transaction_hash, ftrx.transaction_index, ftrx.evaluation_flag
            from{{ ref('stg_blockchain_zero_value_failed_transaction') }} ftrx 
            where ftrx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }} 
            ) excl on trx.block_hash = excl.block_hash 
                    and trx.transaction_hash = excl.transaction_hash
                    and trx.transaction_index = excl.transaction_index  
group by all 