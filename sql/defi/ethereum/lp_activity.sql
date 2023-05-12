/*
Given a set of known liquidity pools, identify transfers to and from liquidity pools at the protocol level, 
as:
deposits = [transfers into liquidity pool] w/ tx hash NOT IN [dex swaps]
withdraws = [transfers out from liquidity pool] w/ tx hash NOT IN [dex swaps]
using TX-HASH as the simplest anti-join; 
NOTE: multi-calls, aggregators, routers, vaults can all get missed.
Also, some garbage coins have deposits but no known price information.
USD Volume comes from hourly price table where hour = max, i.e., most recent.

user_address | protocol | n_deposits | n_withdrawals | dep_usd_volume | wdraw_usd_volume
*/

-- LIQUIDITY POOL DEPOSITS/WITHDRAWS *************

   /* Identifies transfers to/from LPs of tokens that are NOT trades (not in DEX Trades) 
    known issues: Vaults like Gamma.xyz Uni v3 strategies */

with deposits AS ( 
SELECT FROM_ADDRESS as USER_ADDRESS, TO_ADDRESS as pool_address, CONTRACT_ADDRESS, symbol, sum(AMOUNT) as amount_deposited_lp, count(*) as num_deposits  
FROM ethereum.core.ez_token_transfers
WHERE TO_ADDRESS IN (SELECT POOL_ADDRESS FROM ethereum.core.dim_dex_liquidity_pools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM ethereum.core.ez_dex_swaps)
and block_timestamp > current_date - 90
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, symbol, TO_ADDRESS
), 

withdraws AS (
SELECT TO_ADDRESS as USER_ADDRESS, FROM_ADDRESS as pool_address, CONTRACT_ADDRESS, symbol, sum(AMOUNT) as amount_withdrawn_lp, count(*) as num_withdrawals
FROM ethereum.core.ez_token_transfers 
WHERE FROM_ADDRESS IN (SELECT POOL_ADDRESS FROM ethereum.core.dim_dex_liquidity_pools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM ethereum.core.ez_dex_swaps)
and block_timestamp > current_date - 90
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, symbol, FROM_ADDRESS 
),

lp_combined AS (
SELECT * FROM deposits NATURAL FULL OUTER JOIN withdraws
),

select_pool_details AS (
SELECT POOL_ADDRESS, POOL_NAME, PLATFORM
FROM 
ethereum.core.dim_dex_liquidity_pools 
),

  priced_lp_actions AS (
SELECT * FROM lp_combined NATURAL FULL OUTER JOIN 
(SELECT TOKEN_ADDRESS as CONTRACT_ADDRESS, PRICE FROM ethereum.core.fact_hourly_token_prices
WHERE HOUR = (SELECT MAX(HOUR) FROM ethereum.core.fact_hourly_token_prices))
NATURAL FULL OUTER JOIN select_pool_details 
 )

SELECT user_address, platform as protocol, 
sum(num_deposits) as n_deposits,
sum(num_withdrawals) as n_withdrawals,
sum(amount_deposited_lp * price) as dep_usd_volume,
sum(amount_withdrawn_lp * price) as wdraw_usd_volume
FROM priced_lp_actions
WHERE user_address IS NOT NULL -- rare fluke in garbage coin with no price.
GROUP BY user_address, protocol
ORDER BY USER_ADDRESS DESC