with cntr as 
(select 
  distinct contract_address
from {{ ref('core_dim_contracts') }}
),
wallet_activity as 
(select 
  address, 
  min(case when trx.from_address = address then trx.block_timestamp else null end) first_sent_activity_dt,
  min(case when trx.to_address = address then trx.block_timestamp else null end) first_received_activity_dt,
  max(case when trx.from_address = address then trx.block_timestamp else null end) last_sent_activity_dt,
  max(case when trx.to_address = address then trx.block_timestamp else null end) last_received_activity_dt,
  countif(trx.from_address = address) trx_sent_count, 
  countif(trx.to_address = address) trx_received_count,
  count(1) trx_count_overall,
  bqutil.fn.bignumber_div(bqutil.fn.bignumber_sum(ARRAY_AGG(case when trx.from_address = address then trx.value_lossless else '0' end)), "1000000000") trx_eth_sent,
  bqutil.fn.bignumber_div(bqutil.fn.bignumber_sum(ARRAY_AGG(case when trx.to_address = address then trx.value_lossless else '0' end)), "1000000000") trx_eth_received
from {{ ref('core_fact_transactions') }} trx 
cross join unnest([trx.from_address, trx.to_address]) address
group by all 
)
select 
  wa.address,
  case 
    when cntr.contract_address is not null 
      then 'CONTRACT'
    else 'EOA' 
    end wallet_type,
  wa.first_sent_activity_dt,
  wa.first_received_activity_dt,
  wa.last_sent_activity_dt,
  wa.last_received_activity_dt,
  wa.trx_sent_count, 
  wa.trx_received_count,
  wa.trx_count_overall,
  wa.trx_eth_sent,
  wa.trx_eth_received,
  {{ dbt.current_timestamp() }} transformation_dt
from wallet_activity wa 
left join cntr on wa.address = cntr.contract_address 