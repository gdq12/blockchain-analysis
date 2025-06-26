select 
  tk.block_hash, 
  tk.transaction_hash,
  tk.event_hash,
  tk.event_type,
  tk.event_index,
  tk.operator_address,
  tk.from_address,
  tk.to_address,
  tk.quantity
from {{ source('ethereum', 'token_transfers')}} tk
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
group by all 
having count(1) > 1