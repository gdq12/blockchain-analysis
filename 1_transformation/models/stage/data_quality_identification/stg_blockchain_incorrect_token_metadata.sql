select
    tk.block_hash,
    tk.block_number,
    tk.block_timestamp,
    tk.transaction_hash,
    tk.transaction_index,
    tk.event_hash,
    tk.event_index,
    tk.address,
    case 
        when cy.name is null or cy.symbol is null then 'token_transfer_missing_data'
        when cy.decimals is null then 'token_transfer_missing_decimals'
        when safe_cast(cy.decimals as numeric) > 30 then 'token_transfer_suspicious_decimals'
        end evaluation_flag
from {{ source('ethereum', 'token_transfers')}} tk 
join {{ source('crypto_ethereum', 'tokens') }} cy on lower(tk.address) = lower(cy.address)
                                                and tk.block_hash = cy.block_hash
where tk.block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (
    (cy.name is null or cy.symbol is null)
    or 
    (cy.decimals is null)
    or 
    (safe_cast(cy.decimals as numeric) > 30)
)