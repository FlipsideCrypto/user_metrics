WITH wdraws AS (SELECT
to_address AS user_address,
tt.contract_address AS token_contract,
symbol AS token_symbol,
count(tt.tx_hash) AS n_withdrawals,
sum(raw_amount) / pow(10, decimals) AS wdraw_token_volume,
sum(raw_amount) / pow(10, decimals) * price AS wdraw_usd_volume
FROM
bsc.core.fact_token_transfers tt
JOIN bsc.core.FACT_HOURLY_TOKEN_PRICES pp 
ON date_trunc('hour', tt.block_timestamp) = pp.hour
AND tt.contract_address = pp.token_address
WHERE
block_timestamp > current_date - 180
AND
from_address IN
(SELECT address 
 FROM crosschain.core.ADDRESS_LABELS
 WHERE blockchain = 'bsc' AND label_type = 'cex' AND label_subtype = 'hot_wallet')
AND
to_address NOT IN (
 SELECT address 
 FROM crosschain.core.ADDRESS_LABELS
 WHERE blockchain != 'bsc')
GROUP BY user_address, token_contract, token_symbol, decimals, price),

deps AS (
SELECT
from_address AS user_address,
tt.contract_address AS token_contract,
symbol AS token_symbol,
count(tt.tx_hash) AS n_deposits,
sum(raw_amount) / pow(10, decimals) AS dep_token_volume,
sum(raw_amount) / pow(10, decimals) * price AS dep_usd_volume
FROM
bsc.core.fact_token_transfers tt
JOIN bsc.core.FACT_HOURLY_TOKEN_PRICES pp 
ON date_trunc('hour', tt.block_timestamp) = pp.hour
AND tt.contract_address = pp.token_address
WHERE
block_timestamp > current_date - 180
AND
to_address IN
(SELECT address 
 FROM crosschain.core.ADDRESS_LABELS
 WHERE blockchain = 'bsc' AND label_type = 'cex' AND label_subtype = 'deposit_wallet')
AND
from_address NOT IN (
 SELECT address 
 FROM crosschain.core.ADDRESS_LABELS
 WHERE blockchain != 'bsc')
GROUP BY user_address, token_contract, token_symbol, decimals, price
 )
SELECT
COALESCE(ds.user_address, ws.user_address) AS user_address,
'tbd' AS exchange_name,
COALESCE(ds.token_contract, ws.token_contract) AS token_contract,
SPLIT_PART(COALESCE(ds.token_contract, ws.token_contract), '.', 2) AS token_symbol,

COALESCE(n_deposits, 0) AS n_deposits,
COALESCE(n_withdrawals, 0) AS n_withdrawals,

COALESCE(dep_token_volume, 0) AS dep_token_volume,
COALESCE(dep_usd_volume, 0) AS dep_usd_volume,
COALESCE(wdraw_token_volume, 0) AS wdraw_token_volume,
COALESCE(wdraw_usd_volume, 0) AS wdraw_usd_volume

FROM deps ds
FULL OUTER JOIN wdraws ws ON ds.user_address = ws.user_address
AND ds.token_contract = ws.token_contract
