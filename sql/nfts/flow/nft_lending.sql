WITH listings AS (
SELECT 
event_data:flowtyStorefrontAddress::string AS user_address,
count(tx_id) AS n_listings,
  count(distinct(event_data:nftID || event_data:nftType)) AS n_nfts_listed
FROM "FLOW"."CORE"."FACT_EVENTS"
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.5c57f79c6694797f.Flowty'
and event_type = 'ListingAvailable'
GROUP BY user_address),

borrows AS (
select
event_data:borrower::string AS user_address,
count(tx_id) AS n_borrows,
count(distinct(event_data:nftID || event_data:nftType)) AS n_nfts_borrowed
FROM "FLOW"."CORE"."FACT_EVENTS"
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.5c57f79c6694797f.Flowty'
and event_type = 'FundingAvailable'
GROUP BY user_address
),

lends AS (
select
event_data:lender::string AS user_address,
count(tx_id) AS n_lends,
count(distinct(event_data:nftID || event_data:nftType)) AS n_nfts_lent
FROM "FLOW"."CORE"."FACT_EVENTS"
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.5c57f79c6694797f.Flowty'
and event_type = 'FundingAvailable'
GROUP BY user_address
),

repays AS (
select
event_data:borrower::string AS user_address,
count(tx_id) AS n_repayments,
count(distinct(event_data:nftID || event_data:nftType)) AS n_nfts_repaid
FROM "FLOW"."CORE"."FACT_EVENTS"
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.5c57f79c6694797f.Flowty'
and event_type = 'FundingRepaid'
GROUP BY user_address
)

SELECT
COALESCE(ll.user_address, bb.user_address, nn.user_address, rr.user_address) AS user_address,
COALESCE(n_listings, 0) AS n_listings,
COALESCE(n_nfts_listed, 0) AS n_nfts_listed,
COALESCE(n_borrows, 0) AS n_borrows,
COALESCE(n_nfts_borrowed, 0) AS n_nfts_borrowed,
COALESCE(n_lends, 0) AS n_lends,
COALESCE(n_nfts_lent, 0) AS n_nfts_lent,
COALESCE(n_repayments, 0) AS n_repayments,
COALESCE(n_nfts_repaid, 0) AS n_nfts_repaid

FROM listings ll
FULL OUTER JOIN borrows bb ON ll.user_address = bb.user_address
FULL OUTER JOIN lends nn ON ll.user_address = nn.user_address
FULL OUTER JOIN repays rr ON ll.user_address = rr.user_address

