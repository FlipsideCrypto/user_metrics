
CASE WHEN marketplace in ('yawww', 'solanart', 'hadeswap', 'solport', 'coral cube') THEN '0% Marketplace'
WHEN marketplace in ('opensea', 'magic eden v1', 'solana monkey business marketplace', 'magic eden v1') THEN 'Royalty Marketplace' END marketplace_type,




SELECT (post.value - pre.value) * POWER (10, -9) AS dff
, COALESCE(dff, 0) / s.sales_amount AS pct_m
, a.value:pubkey::string AS pubkey
, s.*
FROM solana.core.fact_nft_sales s
LEFT JOIN solana.core.fact_transactions t 
    ON t.tx_id = s.tx_id
LEFT JOIN TABLE(FLATTEN(account_keys)) a
    ON a.value:pubkey::string = 'Fz7HjwoXiDZNRxXMfLAAJLbArqjCTVWrG4wekit2VpSd'
LEFT JOIN TABLE(FLATTEN(t.pre_balances)) pre
    ON pre.index = a.index
LEFT JOIN TABLE(FLATTEN(t.post_balances)) post
    ON post.index = a.index
WHERE s.block_timestamp >= '2022-11-01'
    AND t.block_timestamp >= '2022-11-01'
    AND s.marketplace = 'solanart'
    AND s.succeeded
ORDER BY pct_m ASC
-- LIMIT 100

-- solanart
-- 39fEpihLATXPJCQuSiXLUSiCbGchGYjeL39eyXh3KbyT
SELECT CONCAT('https://solana.fm/tx/', s.tx_id) AS sfm_link
, l.label
, s.*
FROM solana.core.fact_nft_sales s
JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= '2022-05-01'
    AND s.block_timestamp <= '2022-05-02'
    AND s.marketplace = 'solanart'
    AND s.succeeded
LIMIT 100

SELECT s.*
FROM solana.core.fact_nft_sales s
LEFT JOIN solana.core.fact_transfers t 
    ON t.tx_id = s.tx_id
WHERE s.block_timestamp >= '2022-07-01'
    AND s.block_timestamp <= '2022-08-01'
    AND t.tx_id IS NULL
    AND s.marketplace = 'yawww'
LIMIT 100

-- solanart
WITH b0 AS (
    SELECT s.tx_id
    , s.sales_amount
    , s.mint
    , SUM(CASE WHEN tx_to = '39fEpihLATXPJCQuSiXLUSiCbGchGYjeL39eyXh3KbyT' THEN t.amount ELSE 0 END) AS m_amt
    , SUM(CASE WHEN tx_to = '39fEpihLATXPJCQuSiXLUSiCbGchGYjeL39eyXh3KbyT' OR amount > sales_amount * 0.5 THEN 0 ELSE amount END) AS r_amt
    FROM solana.core.fact_nft_sales s
    JOIN solana.core.fact_transfers t
        ON t.tx_id = s.tx_id
        AND t.mint = 'So11111111111111111111111111111111111111112'
    WHERE s.block_timestamp >= '2022-11-01'
        AND s.block_timestamp <= '2022-11-05'
        AND t.block_timestamp >= '2022-11-01'
        AND t.block_timestamp <= '2022-11-05'
        AND s.marketplace = 'solanart'
        AND s.succeeded
    GROUP BY 1, 2, 3
)
SELECT CONCAT('https://solana.fm/tx/', tx_id) AS sfm_link
, CONCAT('https://solscan.io/token/', mint) AS mint_link
, tx_id
, sales_amount
, m_amt
, r_amt
, ROUND(m_amt / sales_amount, 5) AS m_pct
, ROUND(r_amt / sales_amount, 5) AS r_pct
FROM b0

https://solana.fm/tx/5uoq1G9wBzuei7WS8MxN7XZwVoD3KuHTJzTZGphpvXmG42tTL5nXuJB43W7BanSLP7zRzc5R6TQNZmMNQ74L4vES


Updates
Dashboard on royalties and thread
Version 0.1 of SolarScored is out
Working on Business Intelligence Report
Problems Encountered
Priorities
Concerns
Excitements



SELECT *
FROM solana.core.fact_transfers
WHERE t.block_timestamp >= '2022-05-01'
    AND t.block_timestamp <= '2022-05-05'
    AND tx_id = '5uoq1G9wBzuei7WS8MxN7XZwVoD3KuHTJzTZGphpvXmG42tTL5nXuJB43W7BanSLP7zRzc5R6TQNZmMNQ74L4vES'

WITH prices AS (
    SELECT date_trunc('week', recorded_hour)::date AS date
    , AVG(close) AS price
    FROM crosschain.core.fact_hourly_prices
    WHERE id = 'solana'
  	AND close IS NOT NULL
    GROUP BY 1
), amount AS (
    SELECT date_trunc('week', block_timestamp)::date AS date
    , SUM(amount) AS sol_volume
    FROM solana.core.fact_transfers t
    WHERE mint = 'So11111111111111111111111111111111111111111'
  		AND NOT tx_to IN (
            'F8Vyqk3unwxkXukZFQeYyGmFfTG3CAX4v24iyrjEYBJV'
          , '9BVcYqEQxyccuwznvxXqDkSJFavvTyheiTYk231T1A8S'
          , '3uTzTX5GBSfbW7eM9R9k95H7Txe32Qw3Z25MtyD2dzwC'
          , '5Xm6nU1Bi6UewCrhJQFk1CAV97ZJaRiFw4tFNhUbXy3u'
  		)
  		AND NOT tx_from IN (
            'F8Vyqk3unwxkXukZFQeYyGmFfTG3CAX4v24iyrjEYBJV'
          , '9BVcYqEQxyccuwznvxXqDkSJFavvTyheiTYk231T1A8S'
          , '3uTzTX5GBSfbW7eM9R9k95H7Txe32Qw3Z25MtyD2dzwC'
          , '5Xm6nU1Bi6UewCrhJQFk1CAV97ZJaRiFw4tFNhUbXy3u'
  		)
    GROUP BY 1
)
SELECT a.date
, a.sol_volume
, (a.sol_volume * p.price) AS usd_volume
FROM amount a
JOIN prices p ON p.date = a.date


SELECT *
FROM solana.core.fact_swaps
WHERE block_timestamp >= '2022-11-08'
    AND tx_id = '66DAgKyZ4qccKdtb4hdLkDpGbppGym4jPxTfqxS8DKLbBw5atrWN6QS2mLrrHPSrUmbUcsWKgYQs3wye2yowpr1i'

SELECT *
FROM solana.core.fact_transfers
WHERE block_timestamp >= CURRENT_DATE - 90
    AND mint = 'So11111111111111111111111111111111111111111'
    -- AND tx_to = 'F8Vyqk3unwxkXukZFQeYyGmFfTG3CAX4v24iyrjEYBJV'
ORDER BY amount DESC
LIMIT 100

WITH nft_sales AS (
    SELECT block_timestamp::date AS date
    , 'NFT Sale' AS tx_type
    , SUM(sales_amount) AS sol_volume
    FROM solana.core.fact_nft_sales s
    WHERE block_timestamp >= '2022-01-01'
    GROUP BY 1, 2
), swaps AS (
    SELECT block_timestamp::date AS date
    , 'Token Swap' AS tx_type
    , SUM(CASE WHEN swap_from_mint = 'So11111111111111111111111111111111111111112' THEN swap_from_amount ELSE swap_to_amount END) AS sol_volume
    FROM solana.core.fact_swaps
    WHERE block_timestamp >= '2022-01-01'
    GROUP BY 1, 2
), prices AS (
    SELECT recorded_hour::date AS date
    , AVG(close) AS price
    FROM crosschain.core.fact_hourly_prices
    WHERE id = 'solana'
    GROUP BY 1
)
SELECT date_trunc('week', COALESCE(n.date, w.date)) AS week
, SUM( COALESCE(n.sol_volume, 0) ) AS nft_volume_sol
, SUM( COALESCE(s.sol_volume, 0) ) AS swap_volume_sol
, SUM( COALESCE(n.sol_volume, 0) + COALESCE(s.sol_volume, 0) ) AS tot_volume_sol
, SUM( price * COALESCE(n.sol_volume, 0) ) AS nft_volume_usd
, SUM( price * COALESCE(s.sol_volume, 0) ) AS swap_volume_usd
, SUM( price * (COALESCE(n.sol_volume, 0) + COALESCE(s.sol_volume, 0)) ) AS tot_volume_usd
FROM nft_sales n
FULL OUTER JOIN swaps s
    ON s.date = n.date
LEFT JOIN prices p
    ON p.date = COALESCE(n.date, s.date)
GROUP BY 1

SELECT s.*
, a.value:pubkey::string AS pubkey
, (post.value - pre.value) * POWER (10, -9) AS dff
FROM solana.core.fact_nft_sales s
JOIN solana.core.fact_transactions t 
    ON t.tx_id = s.tx_id
LEFT JOIN TABLE(FLATTEN(account_keys)) a
    ON a.value:pubkey::string = 'Fz7HjwoXiDZNRxXMfLAAJLbArqjCTVWrG4wekit2VpSd'
LEFT JOIN TABLE(FLATTEN(t.pre_balances)) pre
    ON pre.index = a.index
LEFT JOIN TABLE(FLATTEN(t.post_balances)) post
    ON post.index = a.index
WHERE s.block_timestamp >= '2022-11-01'
    AND t.block_timestamp >= '2022-11-01'
    AND s.marketplace = 'yawww'

WITH buys AS (
    SELECT purchaser AS user_address
    , SUM(sales_amount) AS buy_volume
    FROM solana.core.fact_nft_sales
    WHERE block_timestamp >= CURRENT_DATE - 180
        AND succeeded
    GROUP BY 1
), sells AS (
    SELECT seller AS user_address
    , SUM(sales_amount) AS sell_volume
    FROM solana.core.fact_nft_sales
    WHERE block_timestamp >= CURRENT_DATE - 180
        AND succeeded
    GROUP BY 1
), mints AS (
    SELECT purchaser AS user_address
    , SUM(mint_price) AS mint_volume
    FROM solana.core.fact_nft_sales
    WHERE block_timestamp >= CURRENT_DATE - 180
        AND succeeded
        AND mint_currency = 'So11111111111111111111111111111111111111111'
        AND mint_price <= 15
    GROUP BY 1
)
SELECT COALESCE(b.user_address, s.user_address, m.user_address) AS user_address
, COALESCE(b.buy_volume, 0) + COALESCE(s.sell_volume, 0) + COALESCE(s.mint_volume, 0) AS volume
FROM buys b 
FULL OUTER JOIN sells s
    ON s.user_address = b.user_address
FULL OUTER JOIN mints m
    ON m.user_address = COALESCE(b.user_address, s.user_address)

SELECT *
FROM solana.core.fact_nft_mints
WHERE block_timestamp >= CURRENT_DATE - 2
AND succeeded
LIMIT 11


SELECT CONCAT('https://solana.fm/tx/', e.tx_id) AS sfm_link
, ARRAY_SIZE(e.inner_instruction:instructions)
, e.tx_id
, e.block_id
, e.block_timestamp::date AS date
, e.inner_instruction:instructions[0]:parsed:info:mint::string AS mint
, s.sales_amount
, CASE WHEN e.inner_instruction:instructions[0]:parsed:info:lamports > 0 THEN 0 WHEN inner_instruction:instructions[3]:parsed:info:lamports > 0 THEN 3 ELSE 5 END AS ind
, COALESCE(e.inner_instruction:instructions[ind]:parsed:info:lamports * POWER(10, -9), 0) AS price_0
, COALESCE(e.inner_instruction:instructions[ind + 1]:parsed:info:lamports * POWER(10, -9), 0) AS yawww_fee
, COALESCE(e.inner_instruction:instructions[ind + 2]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(e.inner_instruction:instructions[ind + 3]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(e.inner_instruction:instructions[ind + 4]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(e.inner_instruction:instructions[ind + 5]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(e.inner_instruction:instructions[ind + 6]:parsed:info:lamports * POWER(10, -9), 0) AS collection_royalty
, price_0 + yawww_fee + collection_royalty AS price
, CASE WHEN price = 0 THEN 0 ELSE yawww_fee / price END AS pct_m
, CASE WHEN price = 0 THEN 0 ELSE collection_royalty / price END AS pct_r
, CASE 
WHEN mint = '2ZkSXXKvdxCCkHYkhfL3xmGvioMQoERCMPVzxmRjVF2K' THEN 'Liberty Square'
WHEN mint = '3TmpAxD2Z4zPfFVR7uNQMFw4tj7sNSwc2MzSFyjoV2Np' THEN 'Heroes Of Astron'
WHEN mint = '9XX3iGGCVaqivVkgVk8ci6SF3zMRbKnxp1fQhJFXmsam' THEN 'The Resurrected'
WHEN mint = 'Afw1QQLzHAFEUWJCriRunLzz3PL4v1ZDQvs1izk29Wvi' THEN 'Heroes Of Astron'
ELSE INITCAP(l.label) END AS collection
, e.inner_instruction
, t.inner_instruction
, e.instruction
FROM solana.core.fact_events e
JOIN solana.core.fact_nft_sales s
    ON s.tx_id = e.tx_id
JOIN solana.core.fact_transactions t
    ON t.tx_id = e.tx_id
LEFT JOIN solana.core.dim_labels l
    ON l.address = inner_instruction:instructions[0]:parsed:info:mint::string
WHERE e.block_timestamp >= '2022-06-04 13:49:14'
AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'
AND e.succeeded
AND mint IS NOT NULL
AND price < 1000
AND ROUND(pct_m, 5) = 0.0
-- AND pct_r > 0
ORDER BY pct_r DESC, e.block_timestamp DESC, e.tx_id
LIMIT 100


SELECT *
FROM solana.core.fact_transfers
WHERE block_timestamp >= '2022-12-06'
    AND tx_id = '5trNueei7P3ukTaHBQSZBirhfbxgetF9D53DMvFHZRfNH8JwKdnjVjTV2zrG56idwvYbtquGieXSHRKSEzV4EZgz'




WITH prices AS (
    SELECT date_trunc('week', recorded_hour)::date AS date
    , AVG(close) AS price
    FROM crosschain.core.fact_hourly_prices
    WHERE id = 'solana'
    GROUP BY 1
), amount (
    SELECT date_trunc('week', block_timestamp) AS date
    , SUM(amount) AS sol_amount
    FROM solana.core.fact_transfers t
    WHERE mint = 'So11111111111111111111111111111111111111112'
    GROUP BY 1
)
SELECT p.date
, a.sol_volume
, (a.sol_amount * p.price) AS usd_volume
FROM amount a
LEFT JOIN prices p ON p.date = a.date

SELECT date
FROM solana.core.fact_transfers t

LIMIT 100


SELECT CONCAT('https://solana.fm/tx/', e.tx_id) AS sfm_link
, ARRAY_SIZE(inner_instruction:instructions)
, e.tx_id
, e.block_id
, e.block_timestamp::date AS date
, inner_instruction:instructions[0]:parsed:info:mint::string AS mint
, COALESCE(inner_instruction:instructions[ind]:parsed:info:lamports * POWER(10, -9), 0) AS price_0
, COALESCE(inner_instruction:instructions[ind + 1]:parsed:info:lamports * POWER(10, -9), 0) AS yawww_fee
, COALESCE(inner_instruction:instructions[ind + 2]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(inner_instruction:instructions[ind + 3]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(inner_instruction:instructions[ind + 4]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(inner_instruction:instructions[ind + 5]:parsed:info:lamports * POWER(10, -9), 0) 
    + COALESCE(inner_instruction:instructions[ind + 6]:parsed:info:lamports * POWER(10, -9), 0) AS collection_royalty
, price_0 + yawww_fee + collection_royalty AS price
, CASE WHEN price = 0 THEN 0 ELSE yawww_fee / price END AS pct_m
, CASE WHEN price = 0 THEN 0 ELSE collection_royalty / price END AS pct_r
, CASE 
WHEN mint = '2ZkSXXKvdxCCkHYkhfL3xmGvioMQoERCMPVzxmRjVF2K' THEN 'Liberty Square'
WHEN mint = '3TmpAxD2Z4zPfFVR7uNQMFw4tj7sNSwc2MzSFyjoV2Np' THEN 'Heroes Of Astron'
WHEN mint = '9XX3iGGCVaqivVkgVk8ci6SF3zMRbKnxp1fQhJFXmsam' THEN 'The Resurrected'
WHEN mint = 'Afw1QQLzHAFEUWJCriRunLzz3PL4v1ZDQvs1izk29Wvi' THEN 'Heroes Of Astron'
ELSE INITCAP(l.label) END AS collection
, inner_instruction
, instruction
FROM solana.core.fact_events e
JOIN solana.core.fact_nft_sales s
    ON s.tx_id = e.tx_id
LEFT JOIN solana.core.dim_labels l ON l.address = inner_instruction:instructions[0]:parsed:info:mint::string
WHERE e.block_timestamp >= '2022-06-04 13:49:14'
AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'
AND e.succeeded
AND mint IS NOT NULL
AND price < 1000
AND ROUND(pct_m, 5) = 0.0
//AND pct_r > 0
ORDER BY pct_r DESC, e.block_timestamp DESC, e.tx_id
LIMIT 100





SELECT MAX(ARRAY_SIZE(inner_instruction:instructions))
FROM solana.core.fact_events e
LEFT JOIN solana.core.dim_labels l ON l.address = inner_instruction:instructions[0]:parsed:info:mint::string
WHERE e.block_timestamp >= '2022-07-04 13:49:14'
AND inner_instruction:instructions[0]:parsed:info:mint::string IS NOT NULL
AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'

SELECT date_trunc('month', e.block_timestamp)::date AS date
, SUM(COALESCE(inner_instruction:instructions[5]:parsed:info:lamports * POWER(10, -9), 0)) AS price_0
, SUM(COALESCE(inner_instruction:instructions[6]:parsed:info:lamports * POWER(10, -9), 0)) AS yawww_fee
, SUM(COALESCE(inner_instruction:instructions[7]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[8]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[9]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[10]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[11]:parsed:info:lamports * POWER(10, -9), 0)) AS collection_royalty
, price_0 + yawww_fee + collection_royalty AS price
, yawww_fee / price AS pct_m
, collection_royalty / price AS pct_r
FROM solana.core.fact_events e
WHERE e.block_timestamp >= '2022-07-04 13:49:14'
    AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'
    AND price < 1000
GROUP BY 1

WITH b0 AS (
    SELECT date_trunc('month', e.block_timestamp)::date AS date
    , COALESCE(inner_instruction:instructions[5]:parsed:info:lamports * POWER(10, -9), 0) AS price_0
    , COALESCE(inner_instruction:instructions[6]:parsed:info:lamports * POWER(10, -9), 0) AS yawww_fee
    , COALESCE(inner_instruction:instructions[7]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[8]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[9]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[10]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[11]:parsed:info:lamports * POWER(10, -9), 0) AS collection_royalty
    , price_0 + yawww_fee + collection_royalty AS price
    , ROUND(yawww_fee / price, 4) AS pct_m
    , ROUND(collection_royalty / price, 4) AS pct_r
    FROM solana.core.fact_events e
    WHERE e.block_timestamp >= '2022-06-01'
        AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'
)
SELECT date
, pct_m
, COUNT(1) AS n
FROM b0
GROUP BY 1, 2


SELECT date_trunc('month', block_timestamp)::date AS date
, COUNT(1) AS n
FROM solana.core.fact_nft_sales
WHERE marketplace = 'yawww'
GROUP BY 1



SELECT date_trunc('month', e.block_timestamp)::date AS date
, SUM(COALESCE(inner_instruction:instructions[5]:parsed:info:lamports * POWER(10, -9), 0)) AS price_0
, SUM(COALESCE(inner_instruction:instructions[6]:parsed:info:lamports * POWER(10, -9), 0)) AS yawww_fee
, SUM(COALESCE(inner_instruction:instructions[7]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[8]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[9]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[10]:parsed:info:lamports * POWER(10, -9), 0) + COALESCE(inner_instruction:instructions[11]:parsed:info:lamports * POWER(10, -9), 0)) AS collection_royalty
, price_0 + yawww_fee + collection_royalty AS price
, yawww_fee / price AS pct_m
, collection_royalty / price AS pct_r
FROM solana.core.fact_events e
WHERE e.block_timestamp >= '2022-07-04 13:49:14'
    AND instruction:programId = '5SKmrbAxnHV2sgqyDXkGrLrokZYtWWVEEk5Soed7VLVN'
    AND price < 1000
GROUP BY 1



SELECT s.marketplace
-- , t.tx_to
, s.tx_id
, l.label
, CONCAT('https://solana.fm/tx/', s.tx_id) AS sfm_link
, ARRAY_SIZE(tr.instructions) AS as_in
, ARRAY_SIZE(tr.instructions[0]:instructions) AS as_in0
, *
FROM solana.core.fact_nft_sales s
-- JOIN solana.core.fact_transfers t
--     ON t.tx_id = s.tx_id
--     AND t.tx_to = '5z1vT6R1HcgvzDpto63rrhgVF4CjA4Sho6DbN58Pwzw3'
JOIN solana.core.dim_labels l
    ON l.address = s.mint
    AND l.label = 'grimzdao'
WHERE s.block_timestamp >= '2022-10-01'
    -- AND t.block_timestamp >= '2022-10-01'
    AND s.marketplace ILIKE '%yaw%'


hayleyngreenfield@gmail.com

Is there anything you think I could / should do in these areas to make sure he's productive (or future people are productive)
There was space for me to help grow Ben's skillset.
Should we do more BI stuff?

We're enjoying it (sustainable)
Right incentives (making money)
'

SELECT CONCAT('https://solana.fm/tx/', tx_id) AS sfm_link
, *
FROM solana.core.fact_nft_sales s 
JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= CURRENT_DATE - 3
    AND marketplace = 'hadeswap'
    AND l.label = 'Okay Bears'
LIMIT 100


SELECT l.label
, s.tx_id
, *
FROM solana.core.fact_nft_sales s
JOIN solana.core.fact_transfers t
    ON t.tx_id = s.tx_id
    AND t.tx_to = '5z1vT6R1HcgvzDpto63rrhgVF4CjA4Sho6DbN58Pwzw3'
JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= CURRENT_DATE - 90
    AND t.block_timestamp >= CURRENT_DATE - 90
    AND s.tx_id IN (
        '5JpNhDGvqTjs7efXr5H2DbZPyQjN7yXHpaUDr8d3ba4BnMXZj8p2hzekJKG872UfDLcS9WugExyBtRkFsNYQhhmY',
        '3EgBVWgqjA5fGDGLgEC4fmbrg2LrPP37MqdHyj8yyaYTuBnsLCdetorwyssvCf9yLq74YJ2U4juZ3pp7Wb93SRjc',
        '4qeihebwmvB8ot37DdXUYe3aavqyyNcRTqJM4VoPDLtX7PUJjf8UH2AAXbjjBFQ2QW1CXQCXivPucGwRCMzghNUn',
        '5zFmimXF8wpMHhXusRiccgb7w7PEhCGkSjbTLQ2UKzAZ8Qd54eQY3dZa83w1X12DKoHmsdpSWtia1CrL4bufyYJz',
        '45SczJ13kx96N8me7er3Xmgx5BA8VHA42yELckhjgDPsjcVkYDRGeHDSuQUNzjVstgc3ShwgjocDJvqC3JKFc1UR',
        '2RchxUjZP6uEBQxAvKzQb6fnHviibzNcNQBAWZSPXpzN3TLwrsu9RK5TPvirHj4VpHn4kGR2H9YyNBnBjhtTYTXw',
        '22YceKsL4Sbrh2aowUaa47GdoX9H7XnBg6cizy68YNUQx7yAbEFURedEVhgJ1R9tRBWz1vX4gSNqEBdoHyeApSoD',
        '2f72km7dsV2kJx96WFdaHHTW6DmFHSJpRuC3WQxjqUoHFzoD6vE3g6wKkvFd6Jzy3F4SVGFqaaQgGqBBjA3Rkum5',
        '22uQAfeM33BJyYwJyGjaNCHpb2Kj8mfa4wegMQ2WdtfzBcyYSq8wxYAvTis6yWs1c62JtxdaBNNSNu4YxsEAnxW1',
        'wuBUpHfpVorY2ntDzhdensuKRcTLnL2KARCUtJQ21ZGQEHcWV5SX8nh8efn1iF5jpAuDizhNTEJDy3LErGfoR9d',
        '53i7inULH7gurCjRHcQxtxuXchU6SmQgeBNnuD6DAFqiC2ohDPBN3K8vt4SQCq2U3NvhRgNz8mgbKKTHDmejVv2x',
        '4rRfz7JcJrLfJ8vsKEpmbxMPVGUdYi11CATv87TANLMrs8hTVjkfsGdfnp8pmM1BvcZUFVozHWmA5vJw7pxxfGZp',
        '3GU2qWxNKRNZFJWSHGGar8PTeE7osXKiCxTVP4sWpjFU7g5KhsCwccZtY2zjyHK44Y5WjLHzdCojRzfz59PH3gVc',
        'xeAzSv3S87p9xHyZdScKtmvUZFTxtvYf5Lye7iw1LEPtEEv5X9JjBvHeRnUdYF5SCJRrExsu2jb6TaoPDbYUM95',
        '3iZDdfE5zvykLdPKfrq18vdBE9vKW2hQsnLePphcgG87XchPLk6XubpwXhVnqB7ZJzfJ6Fs7iet2d7hm716ebUsZ',
        '3HnshEg45APZ1QEAjBQoFDkgm4YWhhkua6xtkXyF1WPEBDo8E359zpovGGwXiUND4oXT4F3hDSZk58J9xP38G99D',
        '3tqUBXMFEm8wUZcnc7xkMGBmiqoczJkJhYf7LHL6gwV3vFAL1h7EGFzNBu4XE7KWjURVAcQ99GjYsEvo2784XW8Y',
        '5BaLbjaez8FUVf5rAydL3Y86RbE6pPDknLjiKyVjuCF9PWGPaWcLjeqjhA7uvnCXhTLNtVFxphyD8jn9JgcSWFbW',
        'JzGZ7qqrB8zhcnVi3uSNYFkJV2xWFHSwmiR7qgsohepFkP8k8VfaAm2Yyv2UK6BNkSJm8BwHR9eENUEwdKiq8Mq',
        '5DdQDFNS3CmVSUfG8hUNXZgb6A7v2NtCBZAAQmhZPNysiJxqXbJGTAR3gPGxbCVk2qiswnrQzpFoadSGKqpQurdE',
        '5QKs6gZaFbeRTmEvJJ4PQNCvtryciUrYctjkh1GLb6HrmxpJWPeg3fRX2nnxZB6bSoYagiqWcbpFYmSFAGPgoURo',
        '423BsEvD3yMjd16JiCayusXbYay2i8g4uajfQxHYU8urvm9RkaPzu5YWHaMFk2XXvRrUDcM3n4D2d21BeYqygToU',
        '4D57auoxQizjQVUsZBijyGD5xDmqEYiv16aLDJDjLFWXWC3HgkFTyzMS9sCySswY4VhQK1BDDGVrbD2bzBFimYLf',
        '5jdz3XBFZ6L2CiiyvufhRF1Vp7dGhXdagrU5gkb1rMko6JKkcX1nCWExP646iot6vTHuj43nK9p7VUpwRBb2Wa5i',
        '45Fzc4fJCDqzJH2WLUV2U3YJf87At7Z3YgsyvevvKJ9cuwVXTVETaAr3hCk6ZKdC3hc4CWmYaC8ZUBzzWFQ3Q8kw',
        'iLSXKH3eFoGSh2ANy69AFaLG1NPA4LKZcLtzjgpe31TGaJj7fRwz5eiEqA1b681ZbkivRq3VZwRxdK8z3RF7dvf',
        'WTmKhrXnHtWqmSbMrDpjx2PBikTkGJD2GnXKZbQq3mgvUXt6hCbzTrNRbZdkZQRfgrMMLMVWK9vbub6o98d2dUQ',
        'Bw3NrJ3hs9MKCmMX2vHnYLJj8MNQKbQnvwkYYNpV7SG7pE4hbUhf49es7SAsRyQejQiJztTQiEPAnoUYejPGNFh',
        '2v7MQ3AGNpDtUn5q2nZhX8Gcm6UBt4nHSu5CZvnJ1hfr8NGYbiZz98wU9WDtadHRoMaDiHuiFbzknzWiswaQrgZK',
        '2CrvgP1ynMAVPjeycp9K7nVe8AtX5g3wrtosskAaQLHVyXZh1RtVEDBS2PcA6vq71h89eAKhRYNsJpkyNxsgH886',
        '3vdajZTb4jQp4XjmEP71uVvxeLdUJHCVgoGEGDReWnZqFRxnRxT3HDL9N6QQe14ereuwHPsgzfSaPChqhLwCfx1m',
        '4raA9X2hD6RNshwk1qjktcF1gKZrzRKjS2Ggzhjt6hgF821pZGcobq2UWh5k8vbeVye8EXuX846unTpfKbc3wHXA',
        '3RGEVDxdghyLKNk1aQfwVBzTEtWJJrg83r7E3PM4DWig22QARQGMDKTpfosA5VUWh9RNrbJ6kFrx5amvw31A6rZG',
        'yPgUWTjBw8HWZ18Usn5RZEjeWPsd1TehFD3e4uq3KGwnUQptvPdFzgdsPkqc95VeLR9LnQFGtYie3baLkUBZA13',
        '54m4w8yVpj324upaAJe3uwKT1kTFDW6DLEH7tKaAhmYYYdXqJmZSWiR2gUZQF5UnRC3M9nTcnEoM8SVz3guvfh9L',
        '24gyG5wGfp9e8dmhefG2krDcT1VLAa5KzhGK8RCHoAQE8Vf7jsixdeswhyTXapD9BMX9Ga5bPpYVWrUs2QE2VdPr',
        '4pyvRNCi5yWM8Jhp3Ff3GDYeiKCwC9FVSBYyr92NWerav3Cuk1RktBFUb3xeKxie6xmauyJgpK5jFXpGSnvjRJsB',
        '4XUSUMwx7VUjdKAVCRuo6MLAdZZqxWxq9kJvZrv63EbjxyUkaSFAVnBUvkKBJV5XTrN7vdMQD7PyTdVHfeezvyby',
        '5r5e6LntFgHC7QnFJrygmeZKfLDCvBBdwaee6zRAvVXx8bcPg8iUyxUJC7dvxorEtNK7xifCH4rovdZ9hP2jLFBR',
        '3MhactaRa7XAuyYve7EjQk62MXNcfre25ENgWM9XPjNAdYj9JASPRCyNzhVMsxTdSBGQX97pnEYoLKEAb8xjwD6D',
        '4nB6462kW7a1sSCJzUDRtMHFHaWYqk5SfnW61hbmUbxTAn4ce2L9vtzPbWLkmYrhXRqze7RHekZNSAUEdnRohgrQ',
        '5jxxtZ87Y1GwuUYtFVHipgutTYUiLthp6REAMjPVaAfQyFaCRbFkXNXwQkVjZrFawcPaASpSqM8xQGiuPvYM7ptM',
        '57eApXip2BsmFyyUh9py7ARbS6MBbgnqVNSHop9t3jVoFsukakHGoQKVPPZVpwWJEvbePTrThaE9r8kQQQZ31vPq',
        '3kvQJsBu4hq1zkLfSY1j3UJhAqiwcf8MHRVmKAkiYxyULtvMTsQ4Wi6aU7Mixnp2UrpnyFkhu7JXUqi4L4Mthtp1',
        '3m7kAif6cwT5X6qinwH1kKRuTDKxJRtjW2RydsW3WenHqcLiPsQ4jKpiEu2AnVgrXrUm4yhLiGZwjK8bPNuCuncz',
        '4rE6C2JBEKpJkMybcuyik6v4Fps7JvZchBrVXzsvHnBLviYovJDYZ6TDb2LoYPRN66D4cZDLKMuD7XmnFrd9cY9f',
        '58u6pXhzX8zpPoZ9ZrWWnnuc4KUg2q2oa9GtHh19wLTbWmVkzKtYpoRLi3ZU29gsFiQXBPPw72MGyxYwXKa4kWNf',
        '541uGAip6K2WxDgxp5nNtDBbFcuBXb7FCaeSbY7t9MLttyeXtCFhzp4n52vQQuSrPqUXZZwfH1uMo826S3f6dcZo',
        'sq9Tw5vbEaLPauv2Qc5PavSNTGpopqvsJrCgtAYLUtTCV6wRx2Mhz1ogcFWrYFYxYJbLj3DeQMFh51AzLYyq1BV',
        '9HJaE5TrU2QCRmsNP6twrkCateUEesWFoNjTTyxM11FdxxkWHyaePH8UFVeuRvEcmZ94oUAvHzoNFHJegz4p2o9',
        '3SYyc4JkrcCFvU6GjjJyDq7MWfcp1HVcd59d4gR4EsfdxuqeZcQ6KomhRPamRY2qRPozuAPR5uXQW22hpNHPHL8c',
        '5tPE45YpVD7LHmYvB4WRcpCwFHvGZV7sKwzZFKkS3Gd23aKSD2GnWQuuDnnV8YXh9Xvg7XhxBzk9nVY7RLEmEaSP',
        'tuMpRaXBWc92ygcqgfgjSZjwvxpgm247AWtFxwg6d3iRPmGHPjSpB8wojefiMHHA4TeyQtFizJcUczpoVsFgcNU',
        '3Eg3g1JB18EsZn3iCHpZAm5QiTSjCn6BDdeZbCqiZ5AmMwohNdENrewySDeYNDyLMfGAvox6wuDno21ghgNJ4pR',
        '4MYzNmhSxQhZ9vu1n4H9cFfyuqQHTqNNo3ExNkh6x5XQTR5EprzNRNKwsgHvzznRrMeGdv5yWSoZJGvM4dL2eZiB',
        '2KEYGUHXEh5N3MhajtbkfDtf9pq26Wqi2QcJMS4gjWEpw5KEc2pPKUuDkj3ef4yfTNK7VJQfLhG16tuyEGA8vZ5G',
        'fALSk5BGE3m3QpGwr9Fch2uqweRSLm6PrsJqoHKGnHmrCh28sdTNvSHVBW86NihT2joYkvjxrxH1gq9Qd1sFtEQ',
        '3nqyc1fPzQ1CvHhj1t8rGFqjVV9vh5ehBUrJdrGrUg3t8xa1ifNR5pE2vf66oqQgzHDTRpNw45a95vt49WdbyQUF'
    )


'Bring back thread competition (open it up the whole company)
Bring back NFT Deal Score


SELECT marketplace
, SUM(sales_amount) AS amt
FROM solana.core.fact_nft_sales s
WHERE block_timestamp >= '2022-08-01'
    AND sales_amount < 1000
GROUP BY 1
ORDER BY 2 DESC


SELECT CONCAT('https://solana.fm/tx/', tx_id) AS sfm_link
, l.label
, s.*
FROM solana.core.fact_nft_sales s 
JOIN solana.core.dim_labels l 
    ON l.address = s.mint
WHERE block_timestamp >= CURRENT_DATE - 7
    AND marketplace = 'hadeswap'
LIMIT 100

WITH tx AS (
    SELECT DISTINCT s.tx_id
    , block_timestamp::date AS date
    , COALESCE(m.token_name, 'Other') AS token_name
    , s.mint
    , sales_amount
    , purchaser
    FROM solana.core.fact_nft_sales s
    JOIN solana.core.dim_nft_metadata m ON m.mint = s.mint
    WHERE block_timestamp >= '2022-01-01'
        AND block_timestamp <= '2022-01-02'
        AND m.token_name = 'Okay Bears'
        AND marketplace LIKE 'magic eden v1'
        AND succeeded
        AND sales_amount > 0
), base AS (
    SELECT t.tx_id
    , SUM(CASE WHEN tx_to = 'rFqFJ9g7TGBD8Ed7TPDnvGKZ5pWLPDyxLcvcH2eRCtt' AND t.mint = 'So11111111111111111111111111111111111111112' THEN amount ELSE 0 END) AS m_amt
    , SUM(CASE WHEN tx_to <> 'rFqFJ9g7TGBD8Ed7TPDnvGKZ5pWLPDyxLcvcH2eRCtt' AND t.mint = 'So11111111111111111111111111111111111111112' AND amount < (sales_amount * 0.5) THEN amount ELSE 0 END) AS r_amt
    FROM solana.core.fact_transfers t
    JOIN tx ON tx.tx_id = t.tx_id
    WHERE block_timestamp >= '2022-01-01'
    GROUP BY 1
), b0 AS (
	SELECT tx.tx_id
    , date
    , mint
    , token_name
    , sales_amount
    -- , s_amt
    , m_amt
    , r_amt
    , ROUND(sales_amount - COALESCE(r_amt, 0) - COALESCE(m_amt, 0),4) AS s_amt
    -- , ROUND(sales_amount - COALESCE(s_amt, 0) - COALESCE(m_amt, 0),4) AS r_amt_calc
    , s_amt / sales_amount AS s_pct
    , m_amt / sales_amount AS m_pct
    , r_amt / sales_amount AS r_pct
    FROM tx
    JOIN base b ON b.tx_id = tx.tx_id
)
, b1 AS (
    SELECT token_name
    , date_trunc('month', date) AS month
    , SUM(sales_amount) AS sales_amount
    , SUM(s_amt) AS s_amt
    , SUM(m_amt) AS m_amt
    , SUM(r_amt) AS r_amt
    , MEDIAN(s_pct) AS s_pct
    , MEDIAN(m_pct) AS m_pct
    , MEDIAN(r_pct) AS r_pct
    , 100 * AVG(CASE WHEN b0.r_amt = 0 THEN 1.0 ELSE 0.0 END) AS pct_no_royalty
    FROM b0
    GROUP BY 1, 2
)
SELECT *
, 100 * (r_amt / sales_amount) AS royalty_pct
FROM b1




SELECT CONCAT('https://solscan.io/tx/', tx_id) AS sol_link
, *
FROM solana.core.fact_nft_mints
WHERE mint_currency = 'So11111111111111111111111111111111111111111'
    AND mint_price <= 15
ORDER BY mint_price DESC
LIMIT 100


-- 
WITH tx AS (
    SELECT DISTINCT s.tx_id
    , block_timestamp::date AS date
    , COALESCE(m.token_name, 'Other') AS token_name
    , s.mint
    , sales_amount
    , purchaser
    FROM solana.core.fact_nft_sales s
    JOIN solana.core.dim_nft_metadata m ON m.mint = s.mint
    WHERE block_timestamp >= '2022-01-01'
        -- AND m.token_name = 'Okay Bears'
        AND marketplace = 'magic eden v2'
        AND succeeded
        AND sales_amount > 0
), mint AS (
    SELECT date_trunc('month', block_timestamp)::date AS month
    , SUM(mint_price) AS mint_volume
    FROM solana.core.fact_nft_mints m
    WHERE month >= '2022-01-01'
        AND mint_currency = 'So11111111111111111111111111111111111111111'
        AND mint_price <= 15
    GROUP BY 1
)
, base AS (
    SELECT t.tx_id
    , SUM(CASE WHEN tx_to = 'rFqFJ9g7TGBD8Ed7TPDnvGKZ5pWLPDyxLcvcH2eRCtt' AND t.mint = 'So11111111111111111111111111111111111111112' THEN amount ELSE 0 END) AS m_amt
    , SUM(CASE WHEN tx_to <> 'rFqFJ9g7TGBD8Ed7TPDnvGKZ5pWLPDyxLcvcH2eRCtt' AND t.mint = 'So11111111111111111111111111111111111111112' AND amount < (sales_amount * 0.5) THEN amount ELSE 0 END) AS r_amt
    FROM solana.core.fact_transfers t
    JOIN tx ON tx.tx_id = t.tx_id
    WHERE block_timestamp >= '2022-01-01'
    GROUP BY 1
), b0 AS (
	SELECT tx.tx_id
    , date
    , mint
    , token_name
    , sales_amount
    -- , s_amt
    , m_amt
    , r_amt
    , ROUND(sales_amount - COALESCE(r_amt, 0) - COALESCE(m_amt, 0),4) AS s_amt
    -- , ROUND(sales_amount - COALESCE(s_amt, 0) - COALESCE(m_amt, 0),4) AS r_amt_calc
    , s_amt / sales_amount AS s_pct
    , m_amt / sales_amount AS m_pct
    , r_amt / sales_amount AS r_pct
    FROM tx
    JOIN base b ON b.tx_id = tx.tx_id
)
, b1 AS (
    SELECT date_trunc('month', date) AS month
    , SUM(sales_amount) AS sales_amount
    , SUM(s_amt) AS s_amt
    , SUM(m_amt) AS m_amt
    , SUM(r_amt) AS r_amt
    , MEDIAN(s_pct) AS s_pct
    , MEDIAN(m_pct) AS m_pct
    , MEDIAN(r_pct) AS r_pct
    , 100 * AVG(CASE WHEN b0.r_amt = 0 THEN 1.0 ELSE 0.0 END) AS pct_no_royalty
    FROM b0
    GROUP BY 1
)
SELECT b1.*
, 100 * (r_amt / sales_amount) AS royalty_pct
, m.mint_volume
FROM b1
JOIN mint m ON m.month = b1.month



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


SELECT s.*
FROM solana.core.fact_nft_sales s
LEFT JOIN solana.core.dim_labels l
    ON l.address = s.mint
WHERE s.block_timestamp >= '2022-08-01'
    AND l.address IS NULL
    AND sales_amount < 1000
ORDER BY COALESCE(sales_amount, 0) DESC
LIMIT 100


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
