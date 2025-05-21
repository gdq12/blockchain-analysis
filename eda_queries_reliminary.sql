-- about the blockchain datasets 
with t1 as 
(select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_arbitrum_one_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_avalanche_contract_chain_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_cronos_mainnet_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_ethereum_goerli_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_ethereum_mainnet_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_fantom_opera_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_optimism_mainnet_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_polygon_mainnet_us`.__TABLES__
union all 
select dataset_id, size_bytes
from `bigquery-public-data.goog_blockchain_tron_mainnet_us`.__TABLES__
) select dataset_id, sum(size_bytes)/pow(10,12) from t1 group by 1 order by 2 desc
;

with t1 as 
(select table_schema, table_name
from `bigquery-public-data.goog_blockchain_arbitrum_one_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_avalanche_contract_chain_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_cronos_mainnet_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_ethereum_goerli_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_ethereum_mainnet_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_fantom_opera_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_optimism_mainnet_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_polygon_mainnet_us`.INFORMATION_SCHEMA.COLUMNS
union all 
select table_schema, table_name
from `bigquery-public-data.goog_blockchain_tron_mainnet_us`.INFORMATION_SCHEMA.COLUMNS
) 
select table_schema, count(distinct table_name)
from t1 
group by 1
order by 2 desc
;

-- about the crptocurrency datasets
with t1 as 
(select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_ethereum`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_ethereum_classic`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_band`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_bitcoin`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_bitcoin_cash`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_dash`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_dogecoin`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_iotex`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_kusama`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_litecoin`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_tezos`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_theta`.__TABLES__
union all
select dataset_id, size_bytes
from `bigquery-public-data`.`crypto_zcash`.__TABLES__
-- union all
-- select dataset_id, size_bytes
-- from `bigquery-public-data`.`crypto_zilliqa`.__TABLES__
) select  dataset_id, sum(size_bytes)/pow(10,12) from t1 group by 1 order by 2 desc
; 

with t1 as 
(select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_ethereum`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_ethereum_classic`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_bitcoin`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_bitcoin_cash`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_dash`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_dogecoin`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_litecoin`.INFORMATION_SCHEMA.COLUMNS
union all
select table_schema, table_name, column_name, data_type
from `bigquery-public-data`.`crypto_zcash`.INFORMATION_SCHEMA.COLUMNS
) 
select  table_schema, count(distinct table_name)
from t1 
group by 1
order by 2 desc
; 