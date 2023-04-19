with allmints as (
SELECT NFT_TO_ADDRESS as user_address, 
  NFT_ADDRESS as nf_token_contract, 
  PROJECT_NAME as nft_project, 
  COUNT(*) as n_mints
  FROM polygon.core.ez_nft_mints
WHERE 1 = 1
  AND BLOCK_TIMESTAMP >= '{{start_date}}'
  AND block_timestamp <= '{{end_date}}'
GROUP BY user_address
  -- comment below to go across projects
  , NFT_ADDRESS, PROJECT_NAME
)

select user_address,
nf_token_contract,
nft_project,
sum(n_mints) as n_mints
from allmints
group by 1,2,3; 