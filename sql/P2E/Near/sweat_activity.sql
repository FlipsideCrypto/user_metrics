with logs AS (
  SELECT
  block_timestamp,
  tx_hash,
  status_value,
  replace(value, 'EVENT_JSON:') as json,
  regexp_substr(status_value, 'Success') as reg_success, 
  try_parse_json(json):standard as standard,
  try_parse_json(json):event as event,
  try_parse_json(json):data as data_logs
 FROM near.core.fact_receipts,
  table(flatten(input => logs))
  WHERE 1=1
  AND block_timestamp >= (current_Date -90)
  AND receiver_id = 'token.sweat'
  AND reg_success is not null 
),
sweat_transfer AS (
  SELECT 
  block_timestamp,
  tx_hash,
  -- json,
  standard, 
  event,
  value:amount/pow(10,18) as sweat,
  value:owner_id as owner_id,
  value:old_owner_id as old_owner_id, -- ft_transfer
  value:new_owner_id as new_owner_id, -- ft_transfer
  nvl(old_owner_id, 'mint') as from_address,
  nvl(new_owner_id, owner_id) as to_address
FROM logs,
  table(flatten(input => data_logs))
WHERE sweat > 0 
)
SELECT 
distinct
case when from_address = 'mint' then owner_id::string
when from_address = 'tge-lockup.sweat' then to_address::string
when TO_ADDRESS like '%deposits.grow.sweat%' then from_address::string
end as user_address,
count(distinct tx_hash) as n_transactions,
sum(case when from_address = 'mint' then sweat else 0 end) as sweat_minted,
sum(case when from_address = 'tge-lockup.sweat' then sweat else 0 end) as sweat_unlocked_tge,
sum(case when TO_ADDRESS like '%deposits.grow.sweat%' then sweat else 0 end) as sweat_staked
FROM sweat_transfer
where user_address not in ('token.sweat', 'treasury.sweat', 'ecosystem.sweat', 'sweatcoltd.sweat', 'publicsale.sweat', 'oracle.sweat', 'community.sweat')
GROUP BY 1
