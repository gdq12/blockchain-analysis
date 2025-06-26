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
    trx.y_parity
from {{ source('ethereum', 'transactions') }} trx
join {{ ref('stg_clean_blocks') }} b on trx.block_hash = b.block_hash 
                                    and trx.block_number = b.block_number
where not exists (select 1 
                from {{ref ('stg_etl_duplicate_transaction') }} dtr 
                where trx.block_hash = dtr.block_hash
                and trx.value_lossless = dtr.value_lossless
                and trx.gas = dtr.gas 
                and trx.gas_price = dtr.gas_price 
                and trx.from_address = dtr.from_address 
                and trx.to_address = dtr.to_address 
                and trx.nonce = dtr.nonce
                )
and trx.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}