-- explorer
WITH signers AS (
    SELECT tx_id
    , signers[0]::string AS user_address
    FROM solana.core.fact_transactions
    WHERE block_timestamp >= CURRENT_DATE - 90
    GROUP BY 1, 2
)
SELECT user_address
, COUNT(DISTINCT COALESCE(l.label, e.program_id)) AS n_unique_programs
FROM solana.core.fact_events e
JOIN signers s ON s.tx_id = e.tx_id
LEFT JOIN solana.core.dim_labels l 
    ON l.address = e.program_id
WHERE e.block_timestamp >= CURRENT_DATE - 90
GROUP BY 1

-- Staker - How much SOL have they staked?
WITH b0 AS (
    SELECT *
    , ROW_NUMBER() OVER (PARTITION BY stake_authority ORDER BY block_timestamp DESC) AS rn
    FROM solana.core.ez_staking_lp_actions
)
SELECT stake_authority AS user_address
, post_tx_staked_balance * POWER(10, -9) AS staked_sol
FROM b0
WHERE rn = 1



-- Bridgor - How many times are they bridging assets onto Solana (from a bridge or CEX)?
WITH tx AS (
    SELECT DISTINCT tx_id
    FROM solana.core.fact_events e
    JOIN solana.core.dim_labels l
        ON l.address = e.program_id
        AND l.label_subtype = 'bridge'
    WHERE e.block_timestamp >= CURRENT_DATE - 2
)
SELECT CASE WHEN tx.tx_id IS NULL THEN label_type ELSE 'bridge' END AS clean_label
, COUNT(1) AS n
FROM solana.core.fact_transfers t
LEFT JOIN tx ON tx.tx_id = t.tx_id
LEFT JOIN solana.core.dim_labels l
    ON l.address = t.tx_from
    AND (l.label_type = 'cex' OR l.label_subtype = 'bridge' )
WHERE t.block_timestamp >= CURRENT_DATE - 2
    AND (tx.tx_id IS NOT NULL OR l.label_type IS NOT NULL)
GROUP BY 1
ORDER BY 2 DESC




WITH tx AS (
    SELECT DISTINCT tx_id
    FROM solana.core.fact_events e
    JOIN solana.core.dim_labels l
        ON l.address = e.program_id
        AND l.label_subtype = 'bridge'
    WHERE e.block_timestamp >= CURRENT_DATE - 90
)
SELECT tx_to
, COUNT(1) AS n_bridge
, SUM(CASE WHEN mint = 'So11111111111111111111111111111111111111112' THEN amount ELSE 0 END) AS sol_bridge_amt
FROM solana.core.fact_transfers t
LEFT JOIN tx ON tx.tx_id = t.tx_id
LEFT JOIN solana.core.dim_labels l
    ON l.address = t.tx_from
    AND (l.label_type = 'cex' OR l.label_subtype = 'bridge' )
WHERE t.block_timestamp >= CURRENT_DATE - 90
    AND (tx.tx_id IS NOT NULL OR l.label_type IS NOT NULL)
GROUP BY 1
ORDER BY 3 DESC

SELECT *
FROM solana.core.dim_labels
WHERE label_type = 'nft'
    AND label_subtype = 'nf_token_contract'
LIMIT 100

SELECT *
FROM solana.core.fact_nft_sales s
JOIN solana.core.fact_transactions t
    ON t.tx_id = s.tx_id
LEFT JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= CURRENT_DATE - 1
    AND t.block_timestamp >= CURRENT_DATE - 1
    AND l.label IS NULL
ORDER BY s.sales_amount DESC
LIMIT 100


SELECT *
FROM solana.core.fact_nft_sales s
JOIN solana.core.fact_transactions t
    ON t.tx_id = s.tx_id
LEFT JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= CURRENT_DATE - 1
    AND t.block_timestamp >= CURRENT_DATE - 1
    AND l.label IS NULL
ORDER BY s.sales_amount DESC
LIMIT 100

SELECT *
FROM solana.core.fact_nft_sales s
WHERE s.block_timestamp >= '2022-11-30'
    AND s.block_timestamp <= '2022-12-01'
ORDER BY s.sales_amount DESC
LIMIT 100


SELECT g.total_score
, s.result_url
, *
FROM bi_analytics.bronze.hevo_grades g
JOIN bi_analytics.bronze.hevo_submissions s ON s.id = g.submission_id
JOIN bi_analytics.bronze.hevo_claims c ON c.id = s.claim_id
JOIN bi_analytics.bronze.hevo_bounties b ON b.id = c.bounty_id
-- JOIN bi_analytics.bronze.hevo_campaigns ca ON ca.id = b.campaign_id
WHERE b.created_at >= '2022-10-01'
    AND intended_payment_currency = 'RUNE'
ORDER BY b.created_at DESC, g.total_score DESC



SELECT ca.title
, ca.project_name
, ca.end_date::date AS date
, g.total_score
, *
FROM bi_analytics.bronze.hevo_grades g
JOIN bi_analytics.bronze.hevo_submissions s ON s.id = g.submission_id
JOIN bi_analytics.bronze.hevo_claims c ON c.id = s.claim_id
JOIN bi_analytics.bronze.hevo_bounties b ON b.id = c.bounty_id
-- JOIN bi_analytics.bronze.hevo_campaigns ca ON ca.id = b.campaign_id
WHERE ca.project_name ILIKE '%THOR%'
    AND ca.end_date >= '2022-10-01'
ORDER BY ca.end_date, ca.title, g.total_score DESC


SELECT *
FROM bi_analytics.bronze.hevo_bounty_collections
LIMIT 100


SELECT project_name
, COUNT(1) AS n
FROM bi_analytics.bronze.hevo_campaigns ca
GROUP BY 1
ORDER BY 2 DESC

SELECT *
FROM bi_analytics.bronze.hevo_campaigns ca
WHERE project_name = 'THORChain'
ORDER BY ca.end_date, ca.title DESC
