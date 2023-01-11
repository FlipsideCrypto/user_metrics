SELECT
    voter AS user_address,
    'axelar' AS protocol,
    COUNT(*) AS n_gov_votes
FROM
    axelar.core.fact_governance_votes
WHERE
    block_timestamp :: DATE >= CURRENT_DATE - 90
GROUP BY
    voter,
    protocol
