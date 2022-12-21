SELECT
    voter AS user_address,
    'osmosis' AS protocol,
    COUNT(*) AS n_gov_votes
FROM
    osmosis.core.fact_governance_votes
WHERE
    block_timestamp :: DATE >= CURRENT_DATE - 90
GROUP BY
    voter,
    protocol
