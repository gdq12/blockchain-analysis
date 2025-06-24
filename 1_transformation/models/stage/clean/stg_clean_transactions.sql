select 
    tr.block_hash, 
    tr.block_number, 
    tr.block_timestamp, 
    tr.transaction_hash, 
    tr.transaction_index, 
    tr.nonce, 
    tr.from_address, 
    tr.to_address, 
    tr.value, 
    tr.value_lossless, 
    tr.gas, 
    tr.gas_price, 
    tr.input, 
    tr.max_fee_per_gas, 
    tr.max_priority_fee_per_gas, 
    tr.transaction_type, 
    tr.chain_id, 
    tr.access_list, 
    tr.r, 
    tr.s, 
    tr.v, 
    tr.y_parity
from {{ source('ethereum', 'transactions') }} tr
join {{ ref('stg_clean_blocks') }} b on tr.block_hash = b.block_hash 
                                    and tr.block_number = b.block_number
where not exists in (select 1 
                    from {{ref ('stg_etl_duplicate_transaction') }} dtr 
                    where tr.block_hash = dtr.block_hash
                    and tr.value_lossless = dtr.value_lossless
                    and tr.gas = dtr.gas 
                    and tr.gas_price = dtr.gas_price 
                    and tr.from_address = dtr.from_address 
                    and tr.to_address = dtr.to_address 
                    and tr.nonce = dtr.nonce
                    )
and tr.block_timestamp between between {{ var('start_time') }} and {{ var('end_time') }}