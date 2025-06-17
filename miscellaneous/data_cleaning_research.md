## Summary of Data Quality Applications

### Faulty records due to googles extraction-load pipeline

* duplicate transactions 

* duplicate traces

* duplicate logs 

* faulty logs

* phantom token transfers

* Missing/Malformed traces (only where trace_address is null)

* Inconsistent traces (only 2 of 3 reasons)

* duplicate logs (1 of the 2) 

* faulty logs (1 of 2)

* phantom token transfer

### Records that should be removed from high level KPI consideration

* zero-valued transactions

* failed trasnactions

* duplicate transactions based on semantic duplicates 

* contracts w/o usage for the time period analysis 

* duplicate traces 

* internal transactions (theyre impact already covered in transactions table)

    + perhaps just use for protocol-level KPIs --> then filter out failed traces 

* Missing/Malformed traces associated to suspicious deep nesting or trace negative indexing

* inconsistent traces due to semantic error 

* duplicate logs due to a bug in the blockchain

* faulty logs with topics longer than 4 objects 

* spam/test token transfers 

* token transfers with incorrect token metadata 

* outliers 

## Data Quality Evaluation Definitions

### Zero-valued transactions 

* represent failed/spammy transactions that don't contribute to economic activity 

* it is common in contract interaction

* they would be good to look at for: 

    + spam detection (Bots usually create these)

    + contract signaling (some dApps use them to trigger events or log data)

    + airdrop farming (wallers interact with contracts to qualify for rewards)

* identified as `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.transactions.value = 0`

### Failed transactions 

* consume gas but don't result in state changes or token transfers 

* would be good for:

    * user experience analysis (may indicate usability issue)

    * gas estimation research (failed transactions can come from mis calculation of gas prior to submitting transaction)

    * security (failed attempts at chain breach)

* identified as `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.receipts.status = 0`

### Duplicate transactions 

* not too common but can be caused by reorg and indexing 

* identify duplicate transactions based on ETL issues when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.transactions` a group by of block_hash/from_address/to_address/value/nonce/gas/gas_price have more than 1 unique transaction_hash

* to identify duplicate transactions that are based on **semantic duplicates (users resending transaction for faster processing - replacement transactions)**, in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.transactions` a group by of block_hash/from_address/to_address/value/nonce/gas have more than 1 unique transaction_hash

### Contract w/o usage

* contract are deployed but never interacted/used, so may not be useful for contract centric KPIs 

* other analysis they can be useful for 

    + contract deploymen trends

    + security audits (unused contracts may pose risks)

    + innovation tracking (new protocols often start with lowe usage) 

* identified as `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.transactions.to_address is null` and `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.transactions.transaction_hash is null`

* caveats: there may be a delay in usage, instead should try to track activity over time by seeing if there are call contracts in traces or events emitted in logs table.

* reasons for delayed usage:

    + Staged Deployments: Developers deploy contracts in advance of a launch.

    + Upgradeable Proxies: Logic contracts are deployed but only used via proxies.

    + Airdrop or Claim Contracts: Created early, used later when users claim tokens.

    + Security or Audit Delays: Contracts are deployed but not activated until reviewed.

    + Abandoned or Forgotten Contracts: Some are never used at all.

### Duplicate traces 

* they are not common, but can exist due to ETL issues 

* identified as entries in the `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces` where combo of transaction_hash/trace_address/action.from_address/action.to_address/action.value have more than 1 row

### Internal transactions/message calls 

* they may not be relevant for KPI calcs since they dont reflect user behavior and are instead side effects of user actions

* when want to look into pure ETH transfers (w/o contract logic) best to filter out transactions that produced traces

* identified as `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces.trace_type = 'call'` and `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces.subtrace > 0`

* what can they be used for: 

    + smart contract behavior analysis 

    + MEV and flash loan detection

    + token transfer tracking 

    + protocol-level KPIs (measuring dApp usage or contract efficiency)

    + DeFi analytics (token swaps and lending occur in internal calls)

### Missing/Malformed traces 

* these are traces that dont produce a proper trace tree/address for either ETL or ethereum env reasons 

* identify caused by ETL reasons is when `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces.trace_address is null`

* identify caused by ethereum issue is when `array_length(bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces.trace_address > 10` (suspicious deep nesting) or where 1 of the nested values is less than 0 (malformed/negative index)

### Failed traces 

* Failed traces represent internal calls or operations within a transaction that did not complete successfully. These failures can occur even if the overall transaction succeeded — because Ethereum allows for partial execution within a transaction.

* identify when `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces.error is not null`

### Inconsistent traces 

* its when trace_type is inconsistent with the rest of the trace metadata which is due to a mix of ETL issues and abnormal ethereum activity 

* identify inconsistent due to ETL error when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces`:

    + Failed traces with critical types

        ```
        WHERE trace_type IN ('call', 'create') AND error IS NOT NULL
        ```

    + Unexpected nulls

        ```
        WHERE trace_type = 'call' AND to_address IS NULL
        ```

* identify as semantic error when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.traces where trace_type = 'delegatecall' AND value > 0`  

### Duplicate logs 

* a log_index should be unique per block, not per transaction 

* due to ETL issue, duplicate log identified as when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs` block_number/log_index/address/topics/data have more than 1 row 

* there can be a bug in the blockchain due to reorg/indexing/data corruption issue, this can be identified as when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs` for a given block_number/log_index have more than 1 distinct address/topics/data 

### Faulty logs 

* those with malformed topics or no address where the log came from 

* identified as potential anomaly if find a clustering pattern when in `array_length(bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs.topics) > 4` 

* identified as ETL source issue when in `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs.address is null`

### Phantom token transfers 

* they are transfers that appear without a corresponding log --> this is due to decoding errors --> aka this is an ETL error not reflective of the blockchain ecosystem 

* they are identified by comparing `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.token_transfers` with `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs`:

    ```
    SELECT
        tk.block_hash,
        tk.block_number,
        tk.block_timestamp,
        tk.transaction_hash,
        tk.transaction_index,
        tk.event_hash,
        tk.address AS token_address,
        tk.from_address,
        tk.to_address,
        tk.quantity,
        l.log_index,
        l.topics
    FROM `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.token_transfers` tk
    LEFT JOIN `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.logs` l
            ON tk.transaction_hash = l.transaction_hash
            AND tk.block_number = l.block_number
            AND tk.address = l.address
            AND tk.event_hash = l.topics[SAFE_OFFSET(0)]
    WHERE tk.block_timestamp BETWEEN '2022-01-01 17:00:00' AND '2022-01-01 18:00:00'
    AND (
        -- l.transaction_hash IS NULL  -- Phantom transfer
        OR SAFE_CAST(tk.quantity AS NUMERIC) = 0  -- Zero-value transfer
    )
    ```

### Spam/test token transfers 

* token transfers probably done for testing code/protocol/contract etc 

* identified as `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.token_transfers.quantity = 0`

### Incorrect token metadata 

* token metadata is often inferred from on-chain contracts and off-chain sources (ex: Etherscan). they can lead to incorrect calcs and a sign of potential faulty contract deployment 

* tokens with bad metadata can have a negative impact on KPIs:

    + TVL (total value locked) --> Mispriced assets due to wrong decimals

    + volume --> inflated/deflated numbers 

    + token ranking --> fake tokens may appear in top ranks 

    + user activity --> misattribution of interactions to wrong tokens 

* to identify those with good vs bad metadata, the following query can help: 

    ```
    SELECT
        tk.address AS token_address,
        SAFE_CAST(tk.quantity AS NUMERIC) AS quantity,
        md.symbol,
        md.name,
        md.decimals,
        md.total_supply,
        CASE
            WHEN md.name IS NULL OR md.symbol IS NULL THEN 'Missing metadata'
            WHEN md.decimals IS NULL THEN 'Missing decimals'
            WHEN safe_cast(md.decimals as numeric) < 0 OR safe_cast(md.decimals as numeric) > 30 THEN 'Suspicious decimals'
            -- WHEN symbol_count > 1 THEN 'Duplicate symbol'
            ELSE 'Looks OK'
        END AS metadata_status
    FROM `bigquery-public-data.goog_blockchain_ethereum_mainnet_us.token_transfers` tk
    JOIN `bigquery-public-data.crypto_ethereum.tokens` md
    ON LOWER(tk.address) = LOWER(md.address)
    and tk.block_hash = md.block_hash
    WHERE tk.block_timestamp BETWEEN '2022-01-01 17:00:00' AND '2022-01-01 18:00:00'
    ```

* the data cleaning for this feature will require multiple model/layers for symbol unique detection can only be done over time and not within a single transaction 

* multi symbols could be categorized more as suspicious activity and potentially be included in anomaly/behavior analysis 

### Outliers 

* after data cleanup, should look at value, gas consumption and quantity where applicable to see if there are any outliers

* use IQR or z-score for evaluating outliers

* they are prob best to exclude for KPI calcs, but good to keep for analomalie analysis 

* they can also be useful for: 

    + whale tracking (high usage indicate major event)

    + flash load analysis

    + protocol launches or exploits