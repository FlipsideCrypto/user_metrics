with token_prices as (
	select distinct token_contract, 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	group by 1,2
),
n_sells as (
  SELECT DISTINCT a.trader, 
  a.platform as protocol,
  a.token_in_contract as token_contract,
  a.token_in as token_symbol,
  count(distinct a.swap_id) as n_sells,
  sum(a.amount_in) as sell_token_volume,
  sum(a.amount_in * b.PRICE_USD) as sell_usd_volume
    FROM near.core.ez_dex_swaps a
  	LEFT JOIN token_prices b 
    on a.token_in_contract = b.token_contract and TRUNC(a.block_timestamp,'hour') = b.timestamp_h
  WHERE a.block_timestamp >= (current_date - 90)
  GROUP BY 1,2,3,4
),
n_buys as (
  SELECT DISTINCT a.trader, 
  a.platform as protocol,
  a.token_out_contract as token_contract,
  a.token_out as token_symbol,
  count(distinct a.swap_id) as n_buys,
  sum(a.amount_out) as buy_token_volume,
  sum(a.amount_out * b.PRICE_USD) as buy_usd_volume
    FROM near.core.ez_dex_swaps a
  	LEFT JOIN token_prices b 
    on a.token_out_contract = b.token_contract and TRUNC(a.block_timestamp,'hour') = b.timestamp_h
  WHERE a.block_timestamp >= (current_date - 90)
  GROUP BY 1,2,3,4
)
SELECT 
  coalesce(buy.trader,sell.trader) as user_address,
  coalesce(buy.protocol,sell.protocol) as protocol,
  coalesce(buy.token_contract,sell.token_contract) as token_contract,
  coalesce(buy.token_symbol,sell.token_symbol) as token_symbol,
  buy.n_buys,
  sell.n_sells,
  buy.buy_token_volume,
  buy.buy_usd_volume,
  sell.sell_token_volume,
  sell.sell_usd_volume
FROM n_buys buy
full JOIN n_sells sell 
  ON buy.trader = sell.trader 
  and buy.protocol = sell.protocol 
  and buy.token_contract = sell.token_contract 
  and buy.token_symbol = sell.token_symbol

