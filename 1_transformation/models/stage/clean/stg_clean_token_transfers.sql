select 
    tk.block_hash, 
    tk.block_number, 
    tk.block_timestamp, 
    tk.transaction_hash, 
    tk.transaction_index, 
    tk.event_index, 
    tk.batch_index, 
    de.log_index,
    tk.address, 
    tk.event_type, 
    tk.event_hash, 
    tk.event_signature, 
    tk.operator_address, 
    tk.from_address, 
    tk.to_address, 
    tk.token_id, 
    tk.quantity, 
    tk.removed
from {{ source('ethereum', 'token_transfers') }} tk
left join {{ source('ethereum', 'decoded_events')}} de on tk.block_hash = de.block_hash 
                                                  and tk.transaction_hash = de.transaction_hash 
                                                  and tk.event_hash = de.event_hash 
                                                  and tk.from_address = de.address
left join {{ ref('stg_etl_duplicate_token_transfer') }} dtk on tk.block_hash = dtk.block_hash 
                                                            and tk.transaction_hash = dtk.transaction_hash 
                                                            and tk.event_hash = dtk.event_hash 
                                                            and tk.operator_address = dtk.operator_address
                                                            and tk.from_address = dtk.from_address 
                                                            and tk.to_address = dtk.to_address 
                                                            and tk.quantity = dtk.quantity 
left join {{ ref('stg_etl_phantom_token_transfer') }} ptk on tk.block_hash = ptk.block_hash 
                                                            and tk.transaction_hash = ptk.transaction_hash 
                                                            and tk.event_hash = ptk.event_hash 
                                                            and tk.address = ptk.address
                                                            and tk.from_address = ptk.from_address 
                                                            and tk.to_address = ptk.to_address 
                                                            and tk.quantity = ptk.quantity
where dtk.block_hash is null 
and ptk.block_hash is null 
and tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }} 