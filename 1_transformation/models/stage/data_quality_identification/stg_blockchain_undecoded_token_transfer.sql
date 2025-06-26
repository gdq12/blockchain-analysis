select 
    tk.block_hash, 
    tk.block_timestamp,
    tk.transaction_hash, 
    tk.transaction_index,
    tk.event_hash,
    tk.event_index,
    'token_transfers_not_decoded_event' evaluation_flag
from {{ source('ethereum', 'token_transfers') }} tk
left join {{ source('ethereum', 'decoded_events')}} de on tk.block_hash = de.block_hash 
                                                  and tk.transaction_hash = de.transaction_hash 
                                                  and tk.event_index = de.log_index
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }} 
and de.block_hash is null 