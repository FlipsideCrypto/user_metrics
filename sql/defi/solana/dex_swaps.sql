WITH a AS (
    SELECT swapper AS user_address
    , SPLIT(swap_program, ' ')[0]::string AS protocol
    , SPLIT(swap_program, ' ')[0]::string AS token_contract
    , swap_from_mint AS token_symbol
    , SUM(1) AS n_buys
    , SUM(swap_from_amount) AS buy_token_volume
    , SUM(swap_from_amount) AS buy_usd_volume
    FROM solana.core.fact_swaps
    WHERE block_timestamp >= {{start_date}} AND block_timestamp <= {{end_date}}
    GROUP BY 1, 2, 3, 4
), b AS (
    SELECT swapper AS user_address
    , SPLIT(swap_program, ' ')[0]::string AS protocol
    , SPLIT(swap_program, ' ')[0]::string AS token_contract
    , swap_to_mint AS token_symbol
    , SUM(1) AS n_sells
    , SUM(swap_to_amount) AS sell_token_volume
    , SUM(swap_to_amount) AS sell_usd_volume
    FROM solana.core.fact_swaps
    WHERE block_timestamp >= {{start_date}} AND block_timestamp <= {{end_date}}
    GROUP BY 1, 2, 3, 4
)
SELECT COALESCE(a.user_address, b.user_address) AS user_address
, COALESCE(a.protocol, b.protocol) AS protocol
, COALESCE(a.token_contract, b.token_contract) AS token_contract
, COALESCE(a.token_symbol, b.token_symbol) AS token_symbol
, COALESCE(a.n_buys, 0) AS n_buys
, COALESCE(b.n_sells, 0) AS n_sells
, COALESCE(a.buy_token_volume, 0) AS buy_token_volume
, COALESCE(a.buy_usd_volume, 0) AS buy_usd_volume
, COALESCE(b.sell_token_volume, 0) AS sell_token_volume
, COALESCE(b.sell_usd_volume, 0) AS sell_usd_volume
FROM a
FULL OUTER JOIN b 
    ON b.user_address = a.user_address
    AND b.protocol = a.protocol
    AND b.token_contract = a.token_contract
    AND b.token_symbol = a.token_symbol
