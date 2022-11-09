with base_tx as (
select distinct tx_hash, tx_signer
  from NEAR.CORE.FACT_TRANSACTIONS 
  where tx_receiver = 'app.nearcrowd.near'  and tx_signer not in ('app.nearcrowd.near' )
  and block_timestamp > (current_date -90)
)
select 
b.tx_signer as user_address,
count(distinct b.tx_hash) as n_txs,
sum(case when a.method_name in ('claim_assignment') then 1 else 0 end) as n_assignment_claims,
sum(case when a.method_name in ('apply_for_assignment') then 1 else 0 end) as n_assignment_applications,
sum(case when a.method_name in ('submit_approved_solution') then 1 else 0 end) as n_submissions,
sum(case when a.method_name in ('submit_review') then 1 else 0 end) as n_reviews,
sum(case when a.method_name in ('claim_reward') then 1 else 0 end) as n_reward_claims,
sum(case when a.method_name not in ('claim_assignment','apply_for_assignment','submit_approved_solution','submit_review','claim_reward') then 1 else 0 end) as n_other
from "NEAR"."CORE"."FACT_ACTIONS_EVENTS_FUNCTION_CALL" a
inner join base_tx b
on a.tx_hash = b.tx_hash
group by 1
