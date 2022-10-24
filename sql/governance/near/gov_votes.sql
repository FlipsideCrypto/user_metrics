with base_txs as 
(
select distinct tx_hash from near.core.fact_actions_events_function_call where method_name in ('vote','act_proposal')
  -- vote is for votes on main near governance website
  -- act_proposal is for votes on dao activities
  and block_timestamp >= (current_date - 90)
)
select 
tx_signer as trader,
TX_RECEIVER as protocol,
count(distinct tx_hash) as n_votes
from near.core.fact_transactions a
where tx_hash in (select distinct tx_hash from base_txs)
  and TX_STATUS = 'Success'
  and tx_receiver not like '%sandbox%'
group by 1,2
