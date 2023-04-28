SELECT tx_signer AS user_address
, tx_receiver AS nf_token_contract
, COALESCE(project_name, '') AS nft_project
, COUNT(1) AS n_mints
FROM NEAR.CORE.EZ_NFT_MINTS 
WHERE block_timestamp >= current_date - 180
GROUP BY 1, 2, 3