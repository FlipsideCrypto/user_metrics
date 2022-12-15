/*
Given a set of airdrops, return an airdrop-user specific table detailing (up to a block height) 
user current balance (as of block height), last_block where balance changed; the amount of airdrop token they claimed
the amount they bought, sold, deposited in known liquidity pools, withdrawn from lps, received from EOAs, sent to EOAs, 
and a 
*/

-- airdrop | user_address | token_balance | last_block_balance_change 
-- | claimed_token_amount | amount_bought | amount_sold 
-- |  amount_deposited_lp | amount_withdrawn_lp 
-- | simple_amount_in | simple_amount_out 
-- | action_class

-- AIRDROP TOKENS *************
        
         -- fill template to add tokens 
        /* UNION
         -- TOKEN Claim
         SELECT LOWER('CONTRACT_ADDRESS') as CONTRACT_ADDRESS, 'TOKENSYMBOL' as SYMBOL, 
          LOWER('AIRDROP_CLAIM_FUNCTION_SIGNATURE') as ORIGIN_FUNCTION_SIGNATURE 
          FROM DUAL
         */

with airdrops AS (
  -- SOS Claim
SELECT LOWER('0x3b484b82567a09e2588a13d54d032153f0c0aee0') as CONTRACT_ADDRESS,'SOS' as SYMBOL, LOWER('0xabf2ebd8') as ORIGIN_FUNCTION_SIGNATURE FROM DUAL 
UNION
  -- Uniswap Claim 
  SELECT LOWER('0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984') as CONTRACT_ADDRESS,'UNI' as SYMBOL, LOWER('0x2e7ba6ef') as ORIGIN_FUNCTION_SIGNATURE FROM DUAL 
UNION
 -- FORTH Claim
 SELECT LOWER('0xf497b83cfbd31e7ba1ab646f3b50ae0af52d03a1') as CONTRACT_ADDRESS, 'FORTH' as SYMBOL, LOWER('0x2e7ba6ef') as ORIGIN_FUNCTION_SIGNATURE FROM DUAL
UNION
 -- ENS Claim
 SELECT LOWER('0xc18360217d8f7ab5e7c516566761ea12ce7f9d72') as CONTRACT_ADDRESS, 'ENS' as SYMBOL, LOWER('0x76122903') as ORIGIN_FUNCTION_SIGNATURE FROM DUAL
UNION
 -- HOP Claim
 SELECT LOWER('0xc5102fe9359fd9a28f877a67e36b0f050d81a3cc') as CONTRACT_ADDRESS, 'HOP' as SYMBOL, LOWER('0x76122903') as ORIGIN_FUNCTION_SIGNATURE FROM DUAL
),


-- AIRDROP CLAIMANTS *************
 
airdrop_claimants AS (
SELECT TX_HASH, CONTRACT_ADDRESS, FROM_ADDRESS, TO_ADDRESS, SYMBOL as token_symbol, ORIGIN_FUNCTION_SIGNATURE, AMOUNT, AMOUNT_USD
  FROM ethereum.core.ez_token_transfers
WHERE CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS FROM airdrops) AND 
ORIGIN_FUNCTION_SIGNATURE IN (SELECT ORIGIN_FUNCTION_SIGNATURE FROM airdrops) 
-- if block height analysis is being done 
  --  AND BLOCK_NUMBER <= 15890000
),

airdrop_claims AS (
SELECT TO_ADDRESS as user_address, contract_address, token_symbol as token_symbol, 
SUM(AMOUNT) as claimed_token_volume 
FROM airdrop_claimants
GROUP BY user_address, contract_address, token_symbol
), 

-- ALL CLAIMANTS CURRENT AIRDROP TOKEN BALANCE ***********

 claimant_balances AS (
SELECT USER_ADDRESS,
           CONTRACT_ADDRESS,
           token_symbol,
           token_balance 
FROM (
    SELECT USER_ADDRESS,
           CONTRACT_ADDRESS,
           symbol as token_symbol,
           CURRENT_BAL as token_balance, 
  ROW_NUMBER() over (
      partition by USER_ADDRESS, CONTRACT_ADDRESS, token_symbol order by BLOCK_NUMBER DESC) as rownum
    FROM ETHEREUM.CORE.EZ_BALANCE_DELTAS
    WHERE 
-- if block height analysis is being done 
-- BLOCK_NUMBER <= 15890000 AND 
CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS from airdrops)
    AND USER_ADDRESS IN (SELECT user_address FROM airdrop_claims)
    QUALIFY rownum = 1
  )
),

-- ALL CLAIMANT AIRDROP TOKEN TRANSFERS *************

        /* NOTE: this includes trades and deposit/withdrawals of liquidity,
           which need to be parsed out. */
  
transfers AS (
SELECT TX_HASH, FROM_ADDRESS, TO_ADDRESS, CONTRACT_ADDRESS, SYMBOL as token_symbol, 
AMOUNT
FROM ethereum.core.ez_token_transfers WHERE 
CONTRACT_ADDRESS IN (SELECT contract_address FROM airdrop_claims) AND
(FROM_ADDRESS IN (SELECT user_address FROM airdrop_claims) OR 
 TO_ADDRESS IN (SELECT user_address FROM airdrop_claims))   
  -- if block height analysis is being done 
-- AND BLOCK_NUMBER <= 15890000
     ),
  
  -- add TYPE of address for transfers 
airdrop_claimant_token_transfers AS ( 
SELECT TX_HASH, FROM_ADDRESS, 
  CASE
    WHEN FROM_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('gnosis safe address')) THEN 'gnosis safe'
    WHEN FROM_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('contract address')) THEN 'contract'
    WHEN FROM_ADDRESS IN (SELECT DISTINCT address FROM flipside_prod_db.crosschain.address_labels WHERE label_type = 'cex') THEN 'EOA-cex'
    WHEN FROM_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('active on ethereum last 7')) THEN 'EOA'
    WHEN FROM_ADDRESS = '0x0000000000000000000000000000000000000000' then 'burn-address'
    ELSE 'EOA-0tx'
END as FROM_ADDRESS_TYPE,
TO_ADDRESS, 
  CASE
    WHEN TO_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('gnosis safe address')) THEN 'gnosis safe'
    WHEN TO_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('contract address')) THEN 'contract'
    WHEN TO_ADDRESS IN (SELECT DISTINCT address FROM flipside_prod_db.crosschain.address_labels WHERE label_type = 'cex') THEN 'EOA-cex'
    WHEN TO_ADDRESS IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('active on ethereum last 7')) THEN 'EOA'
    WHEN TO_ADDRESS = '0x0000000000000000000000000000000000000000' then 'burn-address'  
  ELSE 'EOA-0tx'
END as TO_ADDRESS_TYPE,
 CONTRACT_ADDRESS, token_symbol,
AMOUNT
FROM transfers
  ),

-- ALL CLAIMANT AIRDROP TOKEN TRADES *************

    /* get buys and sells at user-token level for ONLY airdrop tokens!
     known issues: Trade Routers like 1Inch */

airdrop_claimant_token_trades AS (
SELECT TX_HASH, ORIGIN_FROM_ADDRESS as user_address, PLATFORM as protocol, TOKEN_IN, SYMBOL_IN, AMOUNT_IN,
TOKEN_OUT, SYMBOL_OUT, AMOUNT_OUT
FROM ETHEREUM.CORE.EZ_DEX_SWAPS
WHERE 
  -- if block height analysis is being done 
--BLOCK_NUMBER <= 15890000 AND 
user_address IN (SELECT user_address FROM airdrop_claims) AND 
(TOKEN_IN IN (SELECT CONTRACT_ADDRESS FROM airdrops) OR 
 TOKEN_OUT IN (SELECT CONTRACT_ADDRESS FROM airdrops))  
),


buys AS (
SELECT USER_ADDRESS, TOKEN_OUT as CONTRACT_ADDRESS, 
SYMBOL_OUT as token_symbol, SUM(AMOUNT_OUT) as amount_bought
FROM airdrop_claimant_token_trades 
WHERE CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS FROM airdrops)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL  
),

sales AS (
SELECT USER_ADDRESS, TOKEN_IN as CONTRACT_ADDRESS, 
SYMBOL_IN as token_symbol, SUM(AMOUNT_IN) as amount_sold
FROM airdrop_claimant_token_trades
WHERE CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS FROM airdrops)
GROUP BY USER_ADDRESS,CONTRACT_ADDRESS, token_symbol 
),

trades_combined AS (
SELECT * FROM buys NATURAL FULL OUTER JOIN sales 
), 

-- LIQUIDITY POOL DEPOSITS/WITHDRAWS *************

   /* Identifies transfers to/from LPs of tokens that are NOT trades (not in DEX Trades) 
    known issues: Vaults like Gamma.xyz Uni v3 strategies */

select_lps AS (
SELECT POOL_ADDRESS, POOL_NAME, PLATFORM, 
TOKEN0, TOKEN0_SYMBOL, TOKEN1, TOKEN1_SYMBOL 
FROM 
ethereum.core.dim_dex_liquidity_pools WHERE
TOKEN0 IN (SELECT CONTRACT_ADDRESS from airdrops) OR 
TOKEN1 IN (SELECT CONTRACT_ADDRESS from airdrops)
), 

deposits AS ( 
SELECT FROM_ADDRESS as USER_ADDRESS, CONTRACT_ADDRESS, token_symbol, sum(AMOUNT) as amount_deposited_lp  
FROM transfers 
WHERE TO_ADDRESS IN (SELECT POOL_ADDRESS FROM select_lps) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM airdrop_claimant_token_trades)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL 
), 

withdraws AS (
SELECT TO_ADDRESS as USER_ADDRESS, CONTRACT_ADDRESS, token_symbol, sum(AMOUNT) as amount_withdrawn_lp  
FROM transfers 
WHERE FROM_ADDRESS IN (SELECT POOL_ADDRESS FROM select_lps) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM airdrop_claimant_token_trades)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL 
),

lp_combined AS (
SELECT * FROM deposits NATURAL FULL OUTER JOIN withdraws
), 

-- CLAIMANT AIRDROP TOKEN SIMPLE TRANSFERS TO/FROM EOAs ************* 

simple_transfer_out AS (
SELECT FROM_ADDRESS as USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL, 
SUM(AMOUNT) as simple_amount_out
  FROM airdrop_claimant_token_transfers
  WHERE 
FROM_ADDRESS IN (SELECT user_address FROM airdrop_claims) AND 
TO_ADDRESS_TYPE IN ('EOA', 'EOA-0tx')
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL
),

simple_transfer_in AS (
SELECT TO_ADDRESS as USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL, 
SUM(AMOUNT) as simple_amount_in
  FROM airdrop_claimant_token_transfers
  WHERE 
TO_ADDRESS IN (SELECT user_address FROM airdrop_claims) AND 
FROM_ADDRESS_TYPE IN ('EOA', 'EOA-0tx')
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, TOKEN_SYMBOL
),

simple_transfers_combined AS (
SELECT * FROM simple_transfer_in NATURAL FULL OUTER JOIN simple_transfer_out
),

-- COMBINE EVERYTHING SO FAR *************
      /*
      NOTE: a user might be a claimant of 1 airdrop token and a trader of another they didn't claim
      They would be in this table with 0 claimed_volume but non-zero bought/sold or other. 
      We remove these at the end by filtering down to only the user-airdrop pairs where the user
      claimed that airdrop!   
      */

claims_actions AS (
SELECT * 
FROM  claimant_balances NATURAL FULL OUTER JOIN 
      airdrop_claims NATURAL FULL OUTER JOIN 
      trades_combined NATURAL FULL OUTER JOIN
      lp_combined NATURAL FULL OUTER JOIN 
      simple_transfers_combined 
  WHERE claimed_token_volume IS NOT NULL 
  ),

-- POST AIRDROP CLASSIFICATION SYSTEM **************

     /*
     Note: unused conditions included for clarity of theme & specificity if conditions 
     are re-ordered. CASE WHEN will always return the FIRST condition that is true;   
        - Keepooooor: Claimed and sat on it w/o providing liquidity  
            - token_balance >= CLAIMED_TOKEN_VOLUME
            - amount_bought = 0
            - amount_sold = 0
            - amount_deposited_lp = 0
            
        - Dumpooooor: Claimed and sold everything w/o providing liquidity (if received from another EOA, Maximizer)
            - token_balance = 0
            - amount_bought = 0
            - amount_sold >= CLAIMED_TOKEN_VOLUME
            - simple_amount_in = 0 
            - amount_deposited_lp = 0
        
        - Market Maker: Provided liquidity, may or may not have withdrawn and sold later.  
            - amount_deposited_lp > 0 
            
        - Trader: Bought and Sold Hop, without having provided liquidity.
            - amount_bought > 0
            - amount_sold > 0
            - amount_deposited_lp = 0
            
        - Airdrop Maximizer: Received tokens from another EOA AND sold, never providing liquidity nor buying.
            - amount_bought = 0
            - amount_sold > 0
            - simple_amount_in > 0
            - amount_deposited_lp = 0
        
        - Intermediary: never bought, never provided liquidity; transferred equal or more than it claimed to another EOA. Possibly affiliated with an Airdrop Maximizer.
            - simple_amount_out >= CLAIMED_TOKEN_VOLUME 
            - amount_bought = 0 
            - amount_deposited_lp = 0
            
        - N/A: Anyone else, potentially doing a variety of maneuvers and not cleanly fitting into another category. 
    */


SELECT *, 
   CASE 
   WHEN token_balance >= claimed_token_volume AND amount_bought IS NULL AND amount_sold IS NULL AND amount_deposited_lp IS NULL THEN 'Keepooor'
   WHEN token_balance = 0 AND amount_bought IS NULL AND amount_sold >= claimed_token_volume AND simple_amount_in IS NULL AND amount_deposited_lp IS NULL THEN 'Dumpooor'
   WHEN amount_deposited_lp > 0 THEN 'Market Maker'
   WHEN amount_bought > 0 AND amount_sold > 0 AND amount_deposited_lp IS NULL THEN 'Trader'
   WHEN amount_bought IS NULL AND amount_sold > 0 AND simple_amount_in > 0 AND amount_deposited_lp IS NULL THEN 'Maximizooor'
   WHEN simple_amount_out >= claimed_token_volume AND amount_bought IS NULL THEN 'Intermediary'
   ELSE 'Undefined'
   END as category 
FROM claims_actions



