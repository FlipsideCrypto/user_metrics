SELECT 
  event_inputs:recipient::string as user_address,
  count(distinct(tx_hash)) AS n_claims,
  sum(event_inputs:amount::numeric / pow(10,18)) as token_volume
  from optimism.core.fact_event_logs
  WHERE 
  block_timestamp > '2022-05-30'
  AND 
  origin_function_signature = '0x2e7ba6ef' -- claim
  AND 
  contract_address = lower('0xFeDFAF1A10335448b7FA0268F56D2B44DBD357de') -- distr contract
  AND
  user_address NOT IN (
   SELECT address 
   FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS
   WHERE blockchain = 'optimism')
  GROUP BY user_address
  

