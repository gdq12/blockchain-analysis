select 
  tk.block_hash, 
  tk.transaction_hash,
  tk.event_hash,
  tk.event_type,
  de.log_index,
  tk.operator_address,
  tk.from_address,
  tk.to_address,
  tk.quantity
from {{ source('ethereum', 'token_transfers')}} tk
join {{ source('ethereum', 'decoded_events')}} de on tk.block_hash = de.block_hash 
                                                  and tk.transaction_hash = de.transaction_hash 
                                                  and tk.event_hash = de.event_hash 
                                                  and tk.from_address = de.address
group by all 
having count(1) > 1