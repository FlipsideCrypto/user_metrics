SELECT
    voter AS user_address,
    'cosmos' AS protocol,
    COUNT(*) AS n_gov_votes
FROM
    cosmos.core.fact_governance_votes
WHERE
    block_timestamp :: DATE >= CURRENT_DATE - 90
GROUP BY
    voter,
    protocol
