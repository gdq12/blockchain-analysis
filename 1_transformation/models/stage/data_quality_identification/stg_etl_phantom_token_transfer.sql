select 
    tk.block_hash,
    tk.block_number,
    tk.block_timestamp,
    tk.transaction_hash,
    tk.transaction_index,
    tk.event_index,
    tk.event_hash,
    tk.address,
    tk.from_address,
    tk.to_address,
    tk.quantity
from {{ source('ethereum', 'token_transfers') }} tk 
left join {{ source('ethereum', 'logs') }} l on tk.transaction_hash = l.transaction_hash
                                            and tk.block_hash = l.block_hash
                                            and tk.event_index = l.log_index
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and l.transaction_hash IS NULL