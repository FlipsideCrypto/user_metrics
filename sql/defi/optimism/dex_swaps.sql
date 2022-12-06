
WITH swaps AS (
SELECT
tx_hash,
ORIGIN_FROM_ADDRESS AS user_address

FROM
OPTIMISM.CORE.FACT_EVENT_LOGS

WHERE
block_timestamp > current_date - 180
AND
(lower(event_name) LIKE '%swap%'
 OR
 tx_hash IN (select tx_hash FROM OPTIMISM.VELODROME.EZ_SWAPS WHERE block_timestamp > current_date - 180) )
AND
ORIGIN_FROM_ADDRESS NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS where blockchain = 'optimism')
)

SELECT
user_address,
count(distinct(tx_hash)) AS n_swaps
FROM
swaps
GROUP BY 
user_address
