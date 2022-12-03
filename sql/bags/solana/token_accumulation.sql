WITH i AS (
	SELECT tx_to AS user_address
	, mint AS token_contract
	, mint AS token_symbol
	, COUNT(1) AS n_xfer_in
	, SUM(amount) AS xfer_in_token_volume
	, SUM(0) AS xfer_in_usd_volume
	FROM solana.core.fact_transfers
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3
), o AS (
	SELECT tx_from AS user_address
	, mint AS token_contract
	, mint AS token_symbol
	, COUNT(1) AS n_xfer_out
	, SUM(amount) AS xfer_out_token_volume
	, SUM(0) AS xfer_out_usd_volume
	FROM solana.core.fact_transfers
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3
)
SELECT COALESCE(i.user_address, o.user_address) AS user_address
, COALESCE(i.token_contract, o.token_contract) AS token_contract
, COALESCE(i.token_symbol, o.token_symbol) AS token_symbol
, COALESCE(i.n_xfer_in, 0) AS n_xfer_in
, COALESCE(o.n_xfer_out, 0) AS n_xfer_out
, COALESCE(i.xfer_in_token_volume, 0) AS xfer_in_token_volume
, COALESCE(i.xfer_in_usd_volume, 0) AS xfer_in_usd_volume
, COALESCE(o.xfer_out_token_volume, 0) AS xfer_out_token_volume
, COALESCE(o.xfer_out_usd_volume, 0) AS xfer_out_usd_volume
FROM i
FULL OUTER JOIN o
	ON i.user_address = o.user_address
	AND i.token_contract = o.token_contract
	AND i.token_symbol = o.token_symbol

