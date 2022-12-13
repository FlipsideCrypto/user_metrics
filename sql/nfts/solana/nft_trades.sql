WITH hourly_price AS (
    SELECT recorded_hour AS hour
    , AVG(close) AS price
    FROM solana.core.fact_token_prices_hourly
    WHERE symbol = 'SOL'
        AND provider = 'coingecko'
    GROUP BY 1
), daily_price AS (
    SELECT recorded_hour::date AS date
    , AVG(close) AS price
    FROM solana.core.fact_token_prices_hourly
    WHERE symbol = 'SOL'
        AND provider = 'coingecko'
    GROUP BY 1
), monthly_price AS (
    SELECT date_trunc('month', recorded_hour)::date AS month
    , AVG(close) AS price
    FROM solana.core.fact_token_prices_hourly
    WHERE symbol = 'SOL'
        AND provider = 'coingecko'
    GROUP BY 1
), buys AS (
    SELECT purchaser AS user_address
    , REPLACE(REPLACE(marketplace, ' v1', ''), ' v2', '') AS marketplace
    , mint AS nf_token_contract
    , COALESCE(l.address_name, 'Other') AS nft_project
    , '' AS token_contract
    , mint AS token_symbol
    , COUNT(1) AS n_buys
    , SUM(sales_amount * COALESCE(h.price, d.price, m.price, 0)) AS buy_usd_volume
    FROM solana.core.fact_nft_sales s
    LEFT JOIN solana.core.dim_labels l ON l.address = s.mint
    LEFT JOIN hourly_price h
        ON h.hour = date_trunc('hour', s.block_timestamp)
    LEFT JOIN daily_price d
        ON d.date = s.block_timestamp::date
    LEFT JOIN monthly_price m
        ON m.month = date_trunc('month', s.block_timestamp)::date
    WHERE s.block_timestamp >= current_date - {{metric_days}}
    GROUP BY 1, 2, 3, 4, 5, 6
), sells AS (
    SELECT seller AS user_address
    , REPLACE(REPLACE(marketplace, ' v1', ''), ' v2', '') AS marketplace
    -- , mint AS nf_token_contract
  	, COALESCE(l.address_name, 'Other') AS nf_token_contract
    , COALESCE(l.address_name, 'Other') AS nft_project
    , '' AS token_contract
    , 'SOL' AS token_symbol
    , COUNT(1) AS n_sells
    , SUM(sales_amount * COALESCE(h.price, d.price, m.price, 0)) AS sell_usd_volume
    FROM solana.core.fact_nft_sales s
    LEFT JOIN solana.core.dim_labels l ON l.address = s.mint
    LEFT JOIN hourly_price h
        ON h.hour = date_trunc('hour', s.block_timestamp)
    LEFT JOIN daily_price d
        ON d.date = s.block_timestamp::date
    LEFT JOIN monthly_price m
        ON m.month = date_trunc('month', s.block_timestamp)::date
    WHERE s.block_timestamp >= current_date - {{metric_days}}
    GROUP BY 1, 2, 3, 4, 5, 6
)
SELECT COALESCE(b.user_address, s.user_address) AS user_address
, COALESCE(b.marketplace, s.marketplace) AS marketplace
, COALESCE(b.nf_token_contract, s.nf_token_contract) AS nf_token_contract
, COALESCE(b.nft_project, s.nft_project) AS nft_project
, COALESCE(b.token_contract, s.token_contract) AS token_contract
, COALESCE(b.token_symbol, s.token_symbol) AS token_symbol
, COALESCE(b.n_buys, 0) AS n_buys
, COALESCE(b.buy_usd_volume, 0) AS buy_usd_volume
, COALESCE(s.n_sells, 0) AS n_sells
, COALESCE(s.sell_usd_volume, 0) AS sell_usd_volume
FROM buys b
FULL OUTER JOIN sells s 
    ON s.user_address = b.user_address
    AND s.marketplace = b.marketplace
    AND s.nf_token_contract = b.nf_token_contract
    AND s.nft_project = b.nft_project
    AND s.token_contract = b.token_contract
    AND s.token_symbol = b.token_symbol
