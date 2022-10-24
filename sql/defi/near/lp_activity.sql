WITH lp_stake AS (
  Select Distinct 
  tx_hash,
  DEPOSIT / pow(10,24) as near_amount
  from NEAR.CORE.FACT_ACTIONS_EVENTS_FUNCTION_CALL 
  WHERE block_timestamp >= (current_date - 90)
  AND method_name in ('deposit_and_stake', 'internal_deposit_and_stake', 'internal_manager_deposit_and_stake',
  'manager_deposit_and_stake', 'manual_stake', 'stake', 'stake_all')
),
  total_stakes as (
  SELECT p.tx_signer as trader,
  p.TX_RECEIVER as protocol,
  count(distinct p.tx_hash) as num_stake_transactions,
  sum(lp_stake.near_amount) as near_stake_amt
  FROM near.core.fact_transactions  p
  inner JOIN lp_stake ON lp_stake.tx_hash = p.tx_hash
  WHERE p.block_timestamp >= (current_date - 90)
  and p.tx_status != 'Fail'
  group by 1,2
),
lp_unstake as (
select tx_hash, 
    coalesce(PARSE_JSON(args):amount, PARSE_JSON(args):min_expected_near, PARSE_JSON(args):min_amount_out, NULL) as unstake,
  case when contains(unstake, 'e') then 0
  when contains(unstake, ',') then 0
  when contains(unstake, 'o') then 0
  when contains(unstake, 's') then 0
  when contains(unstake, ' ') then 0
  else unstake :: number / pow(10,24)
  end as unstake_clean
from NEAR.CORE.FACT_ACTIONS_EVENTS_FUNCTION_CALL 
where method_name in ('complete_manual_unstake', 'decrease_stake', 'direct_unstake', 'inner_unstake', 'instant_unstake', 'internal_unstake',
  'liquid_unstake', 'manual_unstake', 'unstake', 'unstake_all') 
),
  total_unstakes as (
  SELECT p.tx_signer as trader,
  p.TX_RECEIVER as protocol,
  count(distinct p.tx_hash) as num_unstake_transactions,
  sum (case when contains(tx:receipt[0]:outcome:logs :: string, 'unstaking ') and contains(tx:receipt[0]:outcome:logs :: string, '. Spent') 
        then SUBSTRING(tx:receipt[0]:outcome:logs :: string, CHARINDEX('unstaking ', tx:receipt[0]:outcome:logs :: string) + Len('unstaking ')
               , CHARINDEX('. Spent',tx:receipt[0]:outcome:logs :: string) - CHARINDEX('unstaking ', tx:receipt[0]:outcome:logs :: string) - Len('unstaking ')) :: number / pow(10,24)
  else coalesce(lp_unstake.unstake_clean, 0 ) end)
        as near_unstake_amt
  FROM near.core.fact_transactions  p
  inner JOIN lp_unstake ON lp_unstake.tx_hash = p.tx_hash
  WHERE p.block_timestamp BETWEEN CURRENT_DATE -5 AND CURRENT_DATE
      and p.tx_status != 'Fail'
  GROUP BY 1,2
) 
select 
  coalesce(a.trader, b.trader) as trader,
  coalesce(a.protocol, b.protocol) as protocol,
  a.num_stake_transactions,
  a.near_stake_amt,
  b.num_unstake_transactions,
  b.near_unstake_amt
  from total_stakes a
  full join total_unstakes b 
on a.trader = b.trader and a.protocol = b.protocol


