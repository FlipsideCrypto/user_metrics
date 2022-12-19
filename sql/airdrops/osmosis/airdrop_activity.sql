SELECT 
  receiver AS user_address,
  'osmosis' AS protocol, 
  currency AS token_contract, 
  t.project_name AS token_symbol,
  count(*) AS n_airdrops_claimed, 
  SUM(amount / POW(10, l.decimal)) AS claimed_token_volume, 
  SUM((amount / POW(10, l.decimal))*price) AS claimed_usd_volume
FROM osmosis.core.fact_airdrop l 
INNER JOIN osmosis.core.dim_tokens t ON l.currency = t.address
INNER JOIN osmosis.core.dim_prices p ON date_trunc('hour', l.block_timestamp) = p.recorded_at
GROUP BY user_address, protocol, token_contract, token_symbol