select 
tx_signer as user_address,
count(distinct tx_hash) as n_listings
from "NEAR"."CORE"."FACT_TRANSACTIONS"
where tx_hash in (select distinct tx_hash from "NEAR"."CORE"."FACT_ACTIONS_EVENTS_FUNCTION_CALL" where method_name = 'nft_approve')
and block_timestamp >= (CURRENT_DATE - 90)
and tx_signer not in (select distinct address from crosschain.core.address_labels where blockchain = 'near')
and tx_status = 'Success'
group by 1
