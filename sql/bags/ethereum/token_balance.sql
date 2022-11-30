WITH block_tracked AS (
    SELECT USER_ADDRESS as address,
           CONTRACT_ADDRESS as token_address,
           symbol as token_symbol,
           BLOCK_NUMBER as block,
	       BLOCK_TIMESTAMP,
           PREV_BAL as old_value,
           CURRENT_BAL as new_value
    FROM ETHEREUM.CORE.EZ_BALANCE_DELTAS
    WHERE 1 = 1
 -- for balance at a specific block height 
  --    AND BLOCK_NUMBER <= block_height
-- for balance of a specific token 
 --     AND CONTRACT_ADDRESS = LOWER('insert_token_address')

  ),
-- group by holder-token
-- order by block desc
-- pick most recent block
-- get holders w/ address type label in case it is a contract
token_holder AS (
SELECT *, ROW_NUMBER() over (partition by address, token_address, token_symbol order by block DESC) as rownum
FROM block_tracked
)
  
SELECT  address as user_address, token_address as token_contract, token_symbol, new_value as token_balance,
  block as last_balance_change_block, block_timestamp as last_balance_change_date
FROM token_holder
    WHERE rownum = 1
    