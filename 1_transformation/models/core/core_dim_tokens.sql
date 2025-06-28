select 
  tk.address token_address,
  min(tk.block_number) block_first_transfer,
  min(tk.block_timestamp) block_first_transfer_dt,
  array_agg(distinct cy.symbol IGNORE NULLS) token_symbol, 
  count(distinct cy.symbol) token_symbol_count,
  any_value(cy.name) token_name,
  any_value(cy.decimals) token_decimals,
  {{ dbt.current_timestamp() }} transformation_dt
from {{ ref('core_fact_token_transfers') }} tk 
left join {{ source('crypto_ethereum', 'tokens') }} cy on tk.address = cy.address 
                                                    and tk.block_hash = cy.block_hash 
group by all