-- user_address | nf_token_contract | nft_project | nft_count

with relevant_nfts AS (
SELECT * FROM ethereum.core.ez_nft_transfers
WHERE BLOCK_NUMBER <= 
-- At a specific Block Height, default current 
-- {{BLOCK_MAX}} 
(SELECT MAX(BLOCK_NUMBER) FROM ethereum.core.ez_nft_transfers)
  ORDER BY BLOCK_NUMBER DESC
),

owners AS (
SELECT 
BLOCK_NUMBER, NFT_ADDRESS,
PROJECT_NAME,
  TOKENID,
  NFT_TO_ADDRESS as owner,
row_number() over (partition by PROJECT_NAME, NFT_ADDRESS, TOKENID order by BLOCK_NUMBER DESC) as row_number
FROM relevant_nfts
)

SELECT owner AS user_address, NFT_ADDRESS AS nf_token_contract, PROJECT_NAME as nft_project, SUM(row_number) as nft_count, 
    CASE
    WHEN user_address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('gnosis safe address')) THEN 'gnosis safe'
    WHEN user_address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('contract address')) THEN 'contract'
    WHEN user_address IN (SELECT DISTINCT address FROM crosschain.core.ADDRESS_LABELS WHERE label_type = 'cex') THEN 'EOA-cex'
    WHEN user_address IN (SELECT DISTINCT address FROM CROSSCHAIN.CORE.ADDRESS_TAGS WHERE BLOCKCHAIN = 'ethereum' AND TAG_NAME IN ('active on ethereum last 7')) THEN 'EOA'
    ELSE 'EOA-0tx'
END as address_type
  FROM owners 
where row_number = 1
GROUP BY user_address, nf_token_contract, nft_project