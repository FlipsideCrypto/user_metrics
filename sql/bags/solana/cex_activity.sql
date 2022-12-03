WITH w AS (
	SELECT t.tx_to AS user_address
	, l.label AS exchange_name
	, t.mint AS token_contract
	, t.mint AS token_symbol
	, COUNT(1) AS n_withdrawals
	, SUM(amount) AS wdraw_token_volume
	, SUM(0) AS wdraw_usd_volume
	FROM solana.core.fact_transfers t
	JOIN solana.core.dim_labels l
  		ON l.address = t.tx_from
  		AND l.label_type = 'cex'
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3, 4
), d AS (
	SELECT t.tx_from AS user_address
	, l.label AS exchange_name
	, t.mint AS token_contract
	, t.mint AS token_symbol
	, COUNT(1) AS n_deposits
	, SUM(amount) AS dep_token_volume
	, SUM(0) AS dep_usd_volume
	FROM solana.core.fact_transfers t
	JOIN solana.core.dim_labels l
  		ON l.address = t.tx_to
  		AND l.label_type = 'cex'
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3, 4
)
SELECT COALESCE(w.user_address, d.user_address) AS user_address
, COALESCE(w.exchange_name, d.exchange_name) AS exchange_name
, COALESCE(w.token_contract, d.token_contract) AS token_contract
, COALESCE(w.token_symbol, d.token_symbol) AS token_symbol
, COALESCE(d.n_deposits, 0) AS n_deposits
, COALESCE(w.n_withdrawals, 0) AS n_withdrawals
, COALESCE(d.dep_token_volume, 0) AS dep_token_volume
, COALESCE(d.dep_usd_volume, 0) AS dep_usd_volume
, COALESCE(w.wdraw_token_volume, 0) AS wdraw_token_volume
, COALESCE(w.wdraw_usd_volume, 0) AS wdraw_usd_volume
FROM w
FULL OUTER JOIN d ON d.user_address = w.user_address
	AND d.exchange_name = w.exchange_name
	AND d.token_contract = w.token_contract
	AND d.token_symbol = w.token_symbol
