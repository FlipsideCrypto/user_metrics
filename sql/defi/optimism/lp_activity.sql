with token_deposits AS ( 
SELECT FROM_ADDRESS as USER_ADDRESS, 
sum(raw_amount/pow(10,prices.decimals)) as amount_deposited_lp, 
sum((raw_amount/pow(10,prices.decimals)) * price) as amount_deposited_usd,
count(*) as num_deposits  
FROM OPTIMISM.CORE.FACT_TOKEN_TRANSFERS xfers
JOIN optimism.core.fact_hourly_token_prices prices
ON date_trunc('hour',xfers.block_timestamp) = prices.hour and 
prices.token_address = xfers.contract_address
where prices.hour >= current_date - 180
and BLOCK_TIMESTAMP >= current_date - 180
 AND TO_ADDRESS IN (select distinct contract_address from optimism.core.ez_dex_swaps where block_timestamp > current_Date - 180) AND 
TX_HASH NOT IN (Select distinct tx_hash from optimism.core.ez_dex_swaps where block_timestamp > current_Date - 180)
GROUP BY USER_ADDRESS
), 

token_withdraws AS (
SELECT TO_ADDRESS as USER_ADDRESS, 
sum(raw_amount/pow(10,prices.decimals)) as amount_withdrawn_lp, 
sum((raw_amount/pow(10,prices.decimals)) * price) as amount_withdrawn_usd,
count(*) as num_withdrawals
FROM OPTIMISM.core.FACT_TOKEN_TRANSFERS xfers
JOIN OPTIMISM.core.fact_hourly_token_prices prices
ON date_trunc('hour',xfers.block_timestamp) = prices.hour and 
prices.token_address = xfers.contract_address
where prices.hour >= current_date - 180
and xfers.BLOCK_TIMESTAMP >= current_date - 180
AND FROM_ADDRESS IN (select distinct contract_address from optimism.core.ez_dex_swaps where block_timestamp > current_Date - 180) AND 
TX_HASH NOT IN (Select distinct tx_hash from optimism.core.ez_dex_swaps where block_timestamp > current_Date - 180)
GROUP BY USER_ADDRESS
),
lp_combined AS (
      SELECT coalesce(a.user_address,b.user_address) as user_address,
  num_deposits,
  num_withdrawals,
  amount_deposited_usd,
  amount_withdrawn_usd
  FROM token_deposits a
   FULL OUTER JOIN token_withdraws b
   on a.user_address = b.user_address
)

SELECT user_address, 
sum(num_deposits) as n_deposits,
sum(num_withdrawals) as n_withdrawals,
sum(amount_deposited_usd) as deposit_volume_usd,
sum(amount_withdrawn_usd) as withdrawal_volume_usd
FROM lp_combined
WHERE user_address IS NOT NULL -- rare fluke in garbage coin with no price.
GROUP BY user_address