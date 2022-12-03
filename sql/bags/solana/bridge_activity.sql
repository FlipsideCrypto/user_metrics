WITH tx AS (
	SELECT DISTINCT tx_id, l.label AS bridge_name
	FROM solana.core.fact_events e
	JOIN solana.core.dim_labels l
		ON l.address = e.program_id
		AND l.label_subtype = 'bridge'
	WHERE e.block_timestamp >= current_date - {{metric_days}}
), i AS (
	SELECT t.tx_to AS user_address
	, tx.bridge_name
	, t.mint AS token_contract
	, t.mint AS token_symbol
	, COUNT(1) AS n_in
	, SUM(amount) AS in_token_volume
	, SUM(0) AS in_usd_volume
	FROM solana.core.fact_transfers t
	JOIN tx ON tx.tx_id = t.tx_id
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3, 4
), o AS (
	SELECT t.tx_from AS user_address
	, tx.bridge_name
	, t.mint AS token_contract
	, t.mint AS token_symbol
	, COUNT(1) AS n_out
	, SUM(amount) AS out_token_volume
	, SUM(0) AS out_usd_volume
	FROM solana.core.fact_transfers t
	JOIN tx ON tx.tx_id = t.tx_id
	WHERE block_timestamp >= current_date - {{metric_days}}
	GROUP BY 1, 2, 3, 4
)
SELECT COALESCE(i.user_address, o.user_address) AS user_address
, COALESCE(i.bridge_name, o.bridge_name) AS bridge_name
, COALESCE(i.token_contract, o.token_contract) AS token_contract
, COALESCE(i.token_symbol, o.token_symbol) AS token_symbol
, COALESCE(i.n_in, 0) AS n_in
, COALESCE(o.n_out, 0) AS n_out
, COALESCE(i.in_token_volume, 0) AS in_token_volume
, COALESCE(i.in_usd_volume, 0) AS in_usd_volume
, COALESCE(o.out_token_volume, 0) AS out_token_volume
, COALESCE(o.out_usd_volume, 0) AS out_usd_volume
FROM i
FULL OUTER JOIN o ON o.user_address = i.user_address
	AND o.bridge_name = i.bridge_name
	AND o.token_contract = i.token_contract
	AND o.token_symbol = i.token_symbol