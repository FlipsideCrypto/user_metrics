with rawmints as (
select
*,
case when topics[0] = '0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62' then 'erc-1155'
     when (topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' 
       and topics[3] IS NOT NULL) then 'erc-721'
     else 'erc-20' end as token_standard
from optimism.core.fact_event_logs
where topics[0] in (
  '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
  '0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62'
)
and 
block_timestamp >= current_date - 180
and event_inputs:from = '0x0000000000000000000000000000000000000000'
having token_standard IN ('erc-721','erc-1155')
)

select 
event_inputs:to :: string as user_address,
contract_address as nf_token_contract,
count(distinct (tx_hash) ) as n_mints
from rawmints
group by 1,2