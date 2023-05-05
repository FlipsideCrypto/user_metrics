--user_address | token_contract | token_symbol | tw_token_balance

WITH block_tracked AS (
   SELECT USER_ADDRESS as address,
           CONTRACT_ADDRESS as token_address,
 			SYMBOL,
           BLOCK_NUMBER as block,
           PREV_BAL as old_value,
           CURRENT_BAL as new_value,
           lag(block, 1, (SELECT MAX(BLOCK_NUMBER) FROM ETHEREUM.CORE.EZ_BALANCE_DELTAS)) over (partition by address, token_address, SYMBOL order by block DESC) as holder_next_block
      FROM ETHEREUM.CORE.EZ_BALANCE_DELTAS
    WHERE BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
    CURRENT_DATE()) 
  AND new_value IS NOT NULL
  -- for balance at a specific block height 
  --    AND BLOCK_NUMBER <= block_height
-- for balance of a specific token 
 --     AND CONTRACT_ADDRESS = LOWER('insert_token_address')
       ),
  
   time_points AS (
-- scale down time points by 1,000 to reduce integer overflow risk
                -- use 1 for any amount, otherwise use NEW_VALUE
       SELECT *, (NEW_VALUE * (holder_next_block - block) )/1000 as time_points
    FROM block_tracked
    ),
  -- Aggregation here assumes no minimum required points.
 user_tp AS(SELECT address, token_address, SYMBOL, sum(time_points) as time_weighted_score
FROM time_points
GROUP BY address, token_address, SYMBOL
ORDER BY time_weighted_score DESC
)
  
SELECT address as user_address, token_address as token_contract, SYMBOL as token_symbol, time_weighted_score as tw_token_balance,
  CASE
    WHEN address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('gnosis safe address')) THEN 'gnosis safe'
    WHEN address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('contract address')) THEN 'contract'
    WHEN address IN (SELECT DISTINCT address FROM crosschain.core.ADDRESS_LABELS WHERE label_type = 'cex') THEN 'EOA-cex'
    WHEN address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('active on ethereum last 7')) THEN 'EOA'
    ELSE 'EOA-0tx'
END as address_type
FROM user_tp

