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


with deposits AS ( 
SELECT FROM_ADDRESS as USER_ADDRESS, platform, TO_ADDRESS as pool_address, symbol, sum(AMOUNT) as amount_deposited_lp, count(*) as num_deposits, sum(amount_usd) as  dep_usd_volume
FROM optimism.core.ez_token_transfers tr
  left join (select distinct contract_address, platform from optimism.core.ez_dex_swaps) pl
  on tr.TO_ADDRESS = pl.contract_address
WHERE TO_ADDRESS IN (SELECT contract_address FROM optimism.core.ez_dex_swaps) AND 
TX_HASH NOT IN (SELECT TX_HASH FROM optimism.core.ez_dex_swaps)
and block_timestamp > current_date - 90
GROUP BY USER_ADDRESS, platform, symbol, TO_ADDRESS
), 

withdraws AS (
SELECT TO_ADDRESS as USER_ADDRESS, platform, FROM_ADDRESS as pool_address, symbol, sum(AMOUNT) as amount_withdrawn_lp, count(*) as num_withdrawals, sum(amount_usd) as  wdraw_usd_volume
FROM optimism.core.ez_token_transfers tr
left join (select distinct contract_address, platform from optimism.core.ez_dex_swaps) pl
  on tr.from_address = pl.contract_address
WHERE FROM_ADDRESS IN (SELECT contract_address FROM optimism.core.ez_dex_swaps) AND 
TX_HASH NOT IN (SELECT TX_HASH FROM optimism.core.ez_dex_swaps)
and block_timestamp > current_date - 90
GROUP BY USER_ADDRESS, platform, symbol, FROM_ADDRESS 
),

lp_combined AS (
SELECT * FROM deposits NATURAL FULL OUTER JOIN withdraws
)

SELECT user_address, platform as protocol, 
sum(num_deposits) as n_deposits,
sum(num_withdrawals) as n_withdrawals,
sum(dep_usd_volume) as dep_usd_volume,
sum(wdraw_usd_volume) as wdraw_usd_volume
FROM lp_combined
WHERE user_address IS NOT NULL -- rare fluke in garbage coin with no price.
GROUP BY user_address, protocol
ORDER BY USER_ADDRESS DESC