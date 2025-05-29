select 
    block_hash, 
    block_number,
    block_timestamp,
    transaction_hash,
    transaction_index,
    event_hash,
    event_signature,
    ofe event_signature_index,
    e arg_label,
    regexp_replace(a, '[^a-zA-Z0-9]', '') arg_value
from {{ ref('de_table') }},
unnest(split(regexp_replace(event_signature, '[a-zA-Z].*\\(|\\)', ''))) e with offset ofe
join unnest(split(to_json_string(args))) a with offset ofa on ofe = ofa
where block_timestamp between {{ var('start_time') }} and {{ var('end_time') }}