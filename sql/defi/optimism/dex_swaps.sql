-- this is a big janky but should work!
WITH swaps AS (
SELECT
tx_hash,
coalesce(event_inputs:sender::string, event_inputs:recipient::string) AS user_address

FROM
OPTIMISM.CORE.FACT_EVENT_LOGS

WHERE
block_timestamp > current_date - 180
AND
lower(event_name) = 'swap'
AND
(event_inputs:sender IS NOT NULL
OR
event_inputs:recipient IS NOT NULL)
)
SELECT
user_address,
count(distinct(tx_hash)) AS n_swaps
FROM
swaps
WHERE
user_address NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS where blockchain = 'optimism')
GROUP BY
user_address

