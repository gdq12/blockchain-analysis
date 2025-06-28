{% set snapshot_granularity = var('snapshot_granularity', 'MONTH') %}

with base_trnfs as 
(select 
    address token_address,
    from_address wallet_address,
    block_timestamp,
    block_number,
    -cast(quantity as bignumeric) balance
from {{ ref('core_fact_toekn_transfers') }}
union all 
select 
    address token_address,
    to_address wallet_address,
    block_timestamp, 
    block_number,
    cast(quantity as bignumeric) balance
from {{ ref('core_fact_toekn_transfers') }}
),
snap_shots as 
(select 
    token_address,
    wallet_address,
    date_trunc(block_timestamp, {{ snapshot_granularity | upper }} ) snapshot_date,
    min(block_number) first_blck_num, 
    max(block_number) last_blck_num,
    sum(balance) balance
from base_trnfs
group by all 
)
select 
    ss.token_address, 
    dtk.token_symbol,
    dtk.token_name,
    dtk.token_decimals,
    ss.wallet_address,
    dw.wallet_type,
    ss.snapshot_date,
    ss.first_blck_num, 
    ss.last_blck_num,
    sum(ss.balance) over (partition by ss.token_address, ss.wallet_address 
                    order by ss.snapshot_date
                    rows between unbounded preceding and current row) balance,
    {{ dbt.current_timestamp() }} transformation_dt
from snap_shots ss 
left join {{ ref('core_dim_tokens') }} dtk on ss.token_address = dtk.token_address
left join {{ ref('core_dim_wallets') }} dw on ss.wallet_address = dw.address