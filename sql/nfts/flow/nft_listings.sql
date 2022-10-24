WITH listings AS (
  select
  event_data:seller::string AS user_address,
  count(tx_id) AS listings
  FROM flow.core.fact_events
  WHERE 
  event_contract IN ('A.c1e4f4f4c4257510.TopShotMarketV3', 'A.c38aea683c0c4d38.Market')
  AND 
  event_type = 'MomentListed'
  AND
  block_timestamp >= current_date - 90
  AND
  tx_succeeded = TRUE
  GROUP BY user_address
  
  UNION
  
  select
event_data:storefrontAddress::string AS user_address,
count(tx_id) AS listings
FROM flow.core.fact_events
WHERE 
event_contract IN ('A.4eb8a10cb9f87357.NFTStorefront', 'A.4eb8a10cb9f87357.NFTStorefrontV2')
AND 
event_type = 'ListingAvailable'
AND
block_timestamp >= current_date - 90
AND
tx_succeeded = TRUE
GROUP BY user_address

UNION

select
  event_data:seller::string AS user_address,
  count(tx_id) AS listings
  FROM flow.core.fact_events
  WHERE 
  event_contract = 'A.85b075e08d13f697.OlympicPinMarket'
  AND 
  event_type = 'PieceListed'
  AND
  block_timestamp >= current_date - 90
  AND
  tx_succeeded = TRUE
  GROUP BY user_address
  
)

SELECT
user_address,
sum(listings) AS n_listings
FROM
listings
WHERE
user_address NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
AND
user_address NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
GROUP BY user_address
