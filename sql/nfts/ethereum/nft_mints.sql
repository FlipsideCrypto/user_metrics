-- user_address | nf_token_contract | nft_project | n_mints

SELECT NFT_TO_ADDRESS as user_address, 
  NFT_ADDRESS as nf_token_contract, 
  PROJECT_NAME as nft_project, 
  COUNT(*) as n_mints
  FROM ethereum.core.ez_nft_transfers 
WHERE 1 = 1
  AND NFT_FROM_ADDRESS = '0x0000000000000000000000000000000000000000' 
  AND BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
    CURRENT_DATE())
GROUP BY user_address
  -- comment below to go across projects
  , NFT_ADDRESS, PROJECT_NAME
