select 
  trx.from_address eoa_creator_wallet,
  tr.action.to_address contract_address,
  min(case 
        when tk.block_hash is not null and tk.from_address = '0x0000000000000000000000000000000000000000'
          then tk.block_number
      else trx.block_number end) creation_block_number,
  min(case 
        when tk.block_hash is not null and tk.from_address = '0x0000000000000000000000000000000000000000'
          then tk.block_timestamp
      else trx.block_timestamp end) creation_block_dt,
  case 
    when tk.block_hash is not null and tk.from_address = '0x0000000000000000000000000000000000000000'
      then 'MINT_TOKEN_CONTRACT'
    when tk.block_hash is not null and tk.from_address != '0x0000000000000000000000000000000000000000'
      then 'OTHER_CONTRACT'
      else 'SMART_CONTRACT' end contract_type,
  tk.event_type token_standard,
  {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('core_fact_transactions') }} trx
join {{ ref('core_fact_traces') }} tr on trx.block_hash = tr.block_hash 
                                    and trx.transaction_hash = tr.transaction_hash 
                                    and trx.to_address is null 
                                    and tr.action.to_address is not null
                                    and tr.trace_type = 'create'
left join {{ ref('core_fact_token_transfers') }} tk on tr.action.to_address = tk.address 
group by all 