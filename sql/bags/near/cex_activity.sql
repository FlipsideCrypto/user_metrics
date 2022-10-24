with deposits as (
  select 
  a.tx_signer as user_address,
  b.project_name as exchange_name,
  count(distinct a.tx_hash) as n_deposits,
  sum(a.deposit) / pow(10,24) as near_tokens_deposited
  from near.core.fact_transfers a
  inner join (select distinct address, project_name 
  				from crosschain.core.address_labels 
  				where blockchain = 'near' and label_subtype = 'deposit_wallet') b
  on a.tx_receiver = b.address
  where 
  block_timestamp >= (current_date - 90)
  group by 1,2
),
withdraws as (
  select tx_receiver as user_address,
  project_name as exchange_name,
  count(distinct tx_hash) as n_withdraws,
  sum(deposit) / pow(10,24) as near_tokens_withdrawn
  from near.core.fact_transfers a
  inner join (select distinct address, project_name 
  				from crosschain.core.address_labels 
  				where blockchain = 'near' and label_subtype = 'hot_wallet') b
  on a.tx_signer = b.address
  where 
  block_timestamp >= (current_date - 90)
  group by 1,2
)
select coalesce(a.user_address, b.user_address) as user_address,
coalesce(a.exchange_name, b.exchange_name) as exchange_name,
a.n_deposits,
a.near_tokens_deposited,
b.n_withdraws,
b.near_tokens_withdrawn
from deposits a
full join withdraws b 
on a.user_address = b.user_address and a.exchange_name = b.exchange_name
