with wdraws AS (
SELECT
tx_id, 
event_data:from::string AS xfer_from,
event_data:id::string AS nft_id
FROM
FLOW.CORE.fact_events
where 
block_timestamp > current_date - 90
AND
tx_id not in (SELECT tx_id from flow.core.ez_nft_sales)
AND
event_type = 'Withdraw'
AND
(

(event_data:from  = '0xe1f2a091f7bb5245' AND event_contract = 'A.0b2a3299cc857e29.TopShot')
OR
(event_data:from  IN ('0xe4cf4bdc1751c65d', '0x44c6a6fd2281b6cc') AND event_contract = 'A.e4cf4bdc1751c65d.AllDay')
OR
(event_data:from  IN ('0x87ca73a41bb50ad5', '0xb6f2481eba4df97b') AND event_contract = 'A.87ca73a41bb50ad5.Golazos')
OR
(event_data:from  = '0x329feb3ab062d289' AND event_contract =  'A.329feb3ab062d289.UFC_NFT')
)

)
  
SELECT
event_data:to::string AS user_address,
event_contract AS nft_collection,
count(fe.tx_id) AS n_rips, 
count(distinct(event_data:id::string)) AS n_nft_ids_ripped
FROM
FLOW.CORE.fact_events fe
JOIN wdraws on fe.tx_id = wdraws.tx_id AND fe.event_data:id::string = wdraws.nft_id
WHERE
event_contract IN ('A.0b2a3299cc857e29.TopShot', 'A.e4cf4bdc1751c65d.AllDay', 'A.329feb3ab062d289.UFC_NFT', 'A.87ca73a41bb50ad5.Golazos')
AND
event_type = 'Deposit'
GROUP BY 
user_address, nft_collection


