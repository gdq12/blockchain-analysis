select 
    block_hash,
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    event_hash,
    event_index,
    address,
    case 
        when coalesce(quantity, '0') = '0' 
            then 'token_transfer_spam_test' 
        when coalesce(event_type, 'NONE') not in ('ERC-20', 'ERC-721', 'ERC-1155') 
            then 'token_transfer_unusual_event_type' 
        end evaluation_flag
from {{ source('ethereum', 'token_transfers') }}
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}
and (
    -- spam/test token transfers
    (coalesce(quantity, '0') = '0')
    or
    -- unusual event types 
    (coalesce(event_type, 'NONE') not in ('ERC-20', 'ERC-721', 'ERC-1155'))
)