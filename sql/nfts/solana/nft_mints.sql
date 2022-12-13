
SELECT purchaser AS user_address
, '' AS nf_token_contract
, COALESCE(l.address_name, 'Other') AS nft_project
, COUNT(1) AS n_mints
FROM solana.core.fact_nft_mints m
LEFT JOIN solana.core.dim_labels l ON l.address = m.mint
WHERE m.block_timestamp >= current_date - {{metric_days}}
GROUP BY 1, 2, 3
