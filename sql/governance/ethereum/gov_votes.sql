SELECT VOTER as user_address, SPACE_ID as protocol, COUNT(*) as n_gov_votes 
FROM ETHEREUM.CORE.EZ_SNAPSHOT
  WHERE VOTE_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
    CURRENT_DATE())
GROUP BY VOTER, SPACE_ID