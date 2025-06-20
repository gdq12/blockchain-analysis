select 
    tk.block_hash,
    tk.block_number,
    tk.block_timestamp,
    tk.transaction_hash,
    tk.transaction_index,
    tk.event_hash,
    tk.address,
    tk.from_address,
    tk.to_address,
    tk.quantity
from {{ source('ethereum', 'token_transfers') }} tk 
left join {{ source('ethereum', 'logs') }} l on tk.transaction_hash = l.transaction_hash
                                            and tk.block_number = l.block_number
                                            and tk.address = l.address
                                            and tk.event_hash = l.topics[SAFE_OFFSET(0)]
where l.transaction_hash IS NULL