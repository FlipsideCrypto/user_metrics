SELECT voter AS user_address
, program_name
, COUNT(1) AS n_gov_votes
FROM solana.core.fact_proposal_votes
WHERE block_timestamp >= {{start_date}} AND block_timestamp <= {{end_date}}
GROUP BY 1, 2
