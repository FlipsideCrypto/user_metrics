source("~/data_science/util/util_functions.R")
# file structure - 
# each category has a section for its queries

# airdrops ----

# mirror ----
mirror <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'MIR' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# psi ----
psi <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'PSI' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# anchor ----
anchor <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'ANC' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# LOOP ----
loop <- QuerySnowflake("
                       -- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'LOOP' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# mine ----
mine <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'MINE' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# stt1 ----
stt.1 <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'STT Vesting Public' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# stt2 ----
stt.2 <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'STT Vesting Marketing' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# stt3 ----
stt.3 <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'STT Vesting Private-Seed' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# vkr
vkr <- QuerySnowflake("-- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'VKR' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")

# stt4 ----
stt.4 <- QuerySnowflake("
                        -- For each token airdrop - LUNA, ANC, MINE, MIR, PSI, LOOP, and STT airdrops
-- provide a percentage breakdown of the actions taken, by address, within 90 days of receiving the airdrop.
-- We’d like the breakdown to cover the following actions:
--    -Held
--    -Subsequently purchased more of the airdropped token
--    -Transferred
--    -Staked
--    -Swapped
-- Airdrops
-- https://finder.extraterrestrial.money/columbus-5/address/terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm -- ANC
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2 -- MINE
-- https://finder.extraterrestrial.money/columbus-5/address/terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk -- LOOP
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h -- VKR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw -- MIR
-- https://finder.extraterrestrial.money/columbus-5/address/terra1992lljnteewpz0g398geufylawcmmvgh8l8v96 -- PSI
-- https://finder.extraterrestrial.money/columbus-5/address/terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p -- STT Airdrop Genesis
-- https://finder.extraterrestrial.money/columbus-5/address/terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma -- STT Vesting Public
-- https://finder.extraterrestrial.money/columbus-5/address/terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa -- STT Vesting Marketing
-- https://finder.extraterrestrial.money/columbus-5/address/terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk -- STT Vesting Private/Seed
-- Select the Token to analyze from the list below
-- ANC
-- MINE
-- LOOP
-- VKR
-- MIR
-- PSI
-- STT Airdrop Genesis
-- STT Vesting Public
-- STT Vesting Marketing
-- STT Vesting Private-Seed
with token_to_analyze as (
    select
        'STT Airdrop Genesis' as token
),
exchanges as (
    -- KuCoin - Deposits https://terra.engineer/en/terra_addresses/terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw
    (
        select
            'terra14l46jrdgdhaw4cejukx50ndp0hss95ekt2kfmw' as exchange_address
    )
    union
        -- Binance - Deposits https://terra.engineer/en/terra_addresses/terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5
        (
            select
                'terra1ncjg4a59x2pgvqy9qjyqprlj8lrwshm0wleht5' as exchange_address
        )
),
-- This is a collection of relavant token details for each token that we use below
token_details as (
    (
        select
            'terra146ahqn6d3qgdvmj8cj96hh03dzmeedhsf0kxqm' as airdrop_contract,
            'terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5' as staking_contract,
            'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' as token_contract,
            -- ANC-UST Pair
            'terra1gm5p3ner9x9xpwugn9sp6gvhd0lwrtkyrecdn3' as liquidity_contract,
            'ANC' as token
    )
    union
        (
            select
                'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' as airdrop_contract,
                'terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp' as staking_contract,
                'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' as token_contract,
                -- MINE-UST Pair
                'terra178jydtjvj4gw8earkgnqc80c3hrmqj4kw2welz' as liquidity_contract,
                'MINE' as token
        )
    union
        (
            select
                'terra1atch4d5t25csx7ranccl48udq94k57js6yh0vk' as airdrop_contract,
                -- LOOP has no staking contract yet
                'none' as staking_contract,
                'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' as token_contract,
                -- LOOP LOOP-UST Pair
                'terra106a00unep7pvwvcck4wylt4fffjhgkf9a0u6eu' as liquidity_contract,
                'LOOP' as token
        )
    union
        (
            select
                'terra1s5ww3afj9ym9k5ceu5m3xmea0t9tl7fmh7r40h' as airdrop_contract,
                'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' as staking_contract,
                'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' as token_contract,
                -- VKR-UST Pair
                'terra1e59utusv5rspqsu8t37h5w887d9rdykljedxw0' as liquidity_contract,
                'VKR' as token
        )
    union
        (
            select
                'terra1kalp2knjm4cs3f59ukr4hdhuuncp648eqrgshw' as airdrop_contract,
                'terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x' as staking_contract,
                'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' as token_contract,
                -- MIR-UST Pair
                'terra1amv303y8kzxuegvurh0gug2xe9wkgj65enq2ux' as liquidity_contract,
                'MIR' as token
        )
    union
        (
            select
                'terra1992lljnteewpz0g398geufylawcmmvgh8l8v96' as airdrop_contract,
                'terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j' as staking_contract,
                'terra12897djskt9rge8dtmm86w654g7kzckkd698608' as token_contract,
                -- PSI-UST Pair
                'terra163pkeeuwxzr0yhndf8xd2jprm9hrtk59xf7nqf' as liquidity_contract,
                'PSI' as token
        )
    union
        (
            (
                select
                    -- STT Airdrop Genesis
                    'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Airdrop Genesis' as token
            )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
            union
                (
                    select
                        -- STT Airdrop Genesis
                        'terra1q2qprmuva3m93vhjmc7vakhs0h2lelxzlt675p' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Airdrop Genesis' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Public
                    'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Public' as token
            )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
            union
                (
                    select
                        -- STT Vesting Public
                        'terra1s2yuugawj98gkpy6h9ua7ppss94sqgw2r7tyma' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Public' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Marketing
                    'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Marketing' as token
            )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
            union
                (
                    select
                        -- STT Vesting Marketing
                        'terra1ld47cz4t7gpt7ux4llee3le75y4rhqksw6xfpa' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Marketing' as token
                )
        )
    union
        (
            (
                select
                    -- STT Vesting Private-Seed
                    'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                    -- STT Staking Faction Lunatics
                    'terra1ruh00lyqux5g5zjf4gcg66clrkvk7u7e37ntut' as staking_contract,
                    -- STT
                    'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                    -- STT-UST Pair
                    'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                    'STT Vesting Private-Seed' as token
            )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Degens
                        'terra1z9et2n9ltdqle2s7qq0du2zwr32s3s8ulczh0h' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
            union
                (
                    select
                        -- STT Vesting Private-Seed
                        'terra1268e62h8r0fcr2nt0kplxp8jx5qalwq73a5fuk' as airdrop_contract,
                        -- STT Staking Faction Interstellars
                        'terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv' as staking_contract,
                        -- STT
                        'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' as token_contract,
                        -- STT-UST Pair
                        'terra19pg6d7rrndg4z4t0jhcd7z9nhl3p5ygqttxjll' as liquidity_contract,
                        'STT Vesting Private-Seed' as token
                )
        )
),
-- Contains all the airdrop recipients that recieved the token selected above.
airdrop_recipients as (
    select
        airdrop_recipient,
        token,
        first_airdrop_tokens_claimed,
        no_of_airdrop_claim_occurences,
        total_airdrop_tokens_claimed,
        -- The date when the first Airdrop was claimed.
        date_trunc('day', date) as start_date
    from
        (
            select
                block_timestamp as date,
                msg_value: sender :: string as airdrop_recipient,
                -- Example:
                -- case when msg_value: contract = 'terra1ud39n6c42hmtp2z0qmy8svsk7z3zmdkxzfwcf2' then 'MINE'
                -- Update the Token in token_to_analyze to change token to analyze
                case when msg_value: contract IN (
                    select
                        distinct(airdrop_contract)
                    from
                        token_details
                    where
                        token IN (
                            select
                                token
                            from
                                token_to_analyze
                        )
                ) then (
                    select
                        token
                    from
                        token_to_analyze
                ) else 'Unknown' end as token,
                msg_value: execute_msg: claim: amount / pow(10, 6) as first_airdrop_tokens_claimed,
                (count(*) OVER(PARTITION BY airdrop_recipient)) AS no_of_airdrop_claim_occurences,
                sum(
                    msg_value: execute_msg: claim: amount / pow(10, 6)
                ) OVER(PARTITION BY airdrop_recipient) as total_airdrop_tokens_claimed,
                rank() over (
                    partition BY airdrop_recipient
                    order by
                        block_timestamp,
                        msg_index asc
                ) as rank
            from
                terra.msgs
            where
                msg_value: execute_msg: claim is not null
                and tx_status = 'SUCCEEDED'
                and token <> 'Unknown'
        )
    where
        rank = 1 -- Get the first airdrop transaction timestamp for each address for each token
),
-- Contains all the airdrop recipients that chose to stake the token selected above.
stakers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED' --and msg_value :contract IN 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value: execute_msg: send: contract IN (
            select
                distinct(staking_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        ) -- and msg_value :execute_msg :send :contract = 'terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk' -- VKR STAKING
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to buy more of the token selected above.
buyers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_buying_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_bought,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_bought_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: ask_asset is not null
        and event_type = 'from_contract' -- and event_attributes :ask_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: ask_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to sell the token selected above.
sellers as (
    select
        distinct(event_attributes: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_selling_occurences,
        (
            sum(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_sold,
        (
            avg(
                event_attributes: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_sold_per_txn
    from
        terra.msg_events
        left join airdrop_recipients a on event_attributes: sender :: string = a.airdrop_recipient
    where
        tx_status = 'SUCCEEDED'
        and event_attributes: offer_asset is not null
        and event_type = 'from_contract' -- and event_attributes :offer_asset = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and event_attributes: offer_asset IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is not listed as an exchange above
transferrers_out_non_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_non_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_non_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_non_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and msg_value :execute_msg :transfer :recipient NOT IN (
            select
                exchange_address
            from
                exchanges
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that chose to transfer the token selected above to another address that is listed as an exchange above
transferrers_out_cex as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_out_cex,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_out_cex,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_out_per_txn_cex
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED'
        and msg_value :execute_msg :transfer :recipient IN (
            select
                exchange_address
            from
                exchanges
        )
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that received the token selected above from another address.
transferrers_in as (
    select
        distinct(
            msg_value: execute_msg: transfer: recipient :: string
        ) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_transfer_occurences_in,
        (
            sum(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_transferred_in,
        (
            avg(
                msg_value: execute_msg: transfer: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_transferred_in_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value: execute_msg: transfer is not null
        and tx_status = 'SUCCEEDED' -- and msg_value :contract = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' -- VKR TOKEN
        and msg_value: contract IN (
            select
                distinct(token_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that provided liquidity to the Token-UST Pool.
liquidity_providers as (
    select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_providing_liquidity_occurences,
        (
            sum(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as liquidity_provided,
        (
            avg(
                msg_value :execute_msg :provide_liquidity :assets [0] :amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_liquidity_provided_per_txn
    from
        terra.msgs
        left join airdrop_recipients a on msg_value: sender :: string = a.airdrop_recipient
    where
        msg_value :execute_msg :provide_liquidity is not null
        and tx_status = 'SUCCEEDED'
        and msg_value: contract IN (
            select
                distinct(liquidity_contract)
            from
                token_details
            where
                token IN (
                    select
                        token
                    from
                        token_to_analyze
                )
        )
        and block_timestamp >= a.start_date
),
-- Contains all the airdrop recipients that sent tokens to Terra Bridge
shuttle_bridge_transferrers as (
    select
        distinct(event_from) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_cex_bridge_transfer_occurences,
        (sum(event_amount) OVER(PARTITION BY address)) as tokens_transferred_cex_bridge,
        (avg(event_amount) OVER(PARTITION BY address)) as avg_tokens_transferred_cex_bridge_per_txn
    from
        terra.transfers
        left join airdrop_recipients a on event_from = a.airdrop_recipient
    where
        event_to_address_name ILIKE '%shuttle%'
        and event_currency in (
            select
                token
            from
                token_to_analyze
        )
        and block_timestamp >= a.start_date
)
select
    distinct(a.airdrop_recipient),
    a.token,
    a.start_date,
    -- Amount of Tokens
    a.first_airdrop_tokens_claimed,
    a.total_airdrop_tokens_claimed,
    coalesce(st.tokens_staked, 0) as tokens_staked,
    coalesce(b.tokens_bought, 0) as tokens_bought,
    coalesce(sl.tokens_sold, 0) as tokens_sold,
    coalesce(tout_cex.tokens_transferred_out_cex, 0) as tokens_transferred_out_cex,
    coalesce(tout_ncex.tokens_transferred_out_non_cex, 0) as tokens_transferred_out_non_cex,
    coalesce(tin.tokens_transferred_in, 0) as tokens_transferred_in,
    coalesce(lp.liquidity_provided, 0) as liquidity_provided,
    coalesce(sb.tokens_transferred_cex_bridge, 0) as tokens_transferred_cex_bridge,
    -- No of Occurences
    coalesce(a.no_of_airdrop_claim_occurences, 0) as no_of_airdrop_claim_occurences,
    coalesce(st.no_of_staking_occurences, 0) as no_of_staking_occurences,
    coalesce(b.no_of_buying_occurences, 0) as no_of_buying_occurences,
    coalesce(sl.no_of_selling_occurences, 0) as no_of_selling_occurences,
    coalesce(tout_cex.no_of_transfer_occurences_out_cex, 0) as no_of_transfer_occurences_out_cex,
    coalesce(
        tout_ncex.no_of_transfer_occurences_out_non_cex,
        0
    ) as no_of_transfer_occurences_out_non_cex,
    coalesce(tin.no_of_transfer_occurences_in, 0) as no_of_transfer_occurences_in,
    coalesce(lp.no_of_providing_liquidity_occurences, 0) as no_of_providing_liquidity_occurences,
    coalesce(sb.no_of_cex_bridge_transfer_occurences, 0) as no_of_cex_bridge_transfer_occurences,
    -- Average per Transaction
    coalesce(st.avg_tokens_staked_per_txn, 0) as avg_tokens_staked_per_txn,
    coalesce(b.avg_tokens_bought_per_txn, 0) as avg_tokens_bought_per_txn,
    coalesce(sl.avg_tokens_sold_per_txn, 0) as avg_tokens_sold_per_txn,
    coalesce(
        tout_cex.avg_tokens_transferred_out_per_txn_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_non_cex,
    coalesce(
        tout_ncex.avg_tokens_transferred_out_per_txn_non_cex,
        0
    ) as avg_tokens_transferred_out_per_txn_ncex,
    coalesce(tin.avg_tokens_transferred_in_per_txn, 0) as avg_tokens_transferred_in_per_txn,
    coalesce(lp.avg_liquidity_provided_per_txn, 0) as avg_liquidity_provided_per_txn,
    coalesce(sb.avg_tokens_transferred_cex_bridge_per_txn, 0) as avg_tokens_transferred_cex_bridge_per_txn,
    greatest(
        (
            (
                -- Tokens Claimed, Bought, Transferred In
                coalesce(total_airdrop_tokens_claimed, 0) + coalesce(tokens_bought, 0) + coalesce(tokens_transferred_in, 0)
            ) - (
                -- Tokens Sold, Transferred out, Bridged out
                coalesce(tokens_sold, 0) + coalesce(tokens_transferred_out_non_cex, 0) + coalesce(tokens_transferred_cex_bridge, 0) + coalesce(tokens_transferred_out_cex, 0)
            )
        ),
        0
    ) as tokens_held
from
    airdrop_recipients a
    left join stakers st on a.airdrop_recipient = st.address
    left join sellers sl on a.airdrop_recipient = sl.address
    left join buyers b on a.airdrop_recipient = b.address
    left join transferrers_out_non_cex tout_ncex on a.airdrop_recipient = tout_ncex.address
    left join transferrers_out_cex tout_cex on a.airdrop_recipient = tout_cex.address
    left join transferrers_in tin on a.airdrop_recipient = tin.address
    left join liquidity_providers lp on a.airdrop_recipient = lp.address
    left join shuttle_bridge_transferrers sb on a.airdrop_recipient = sb.address
order by
    start_date asc")




# summarize ---- 

airdrops <- rbind(anchor, mirror, mine, loop, psi, vkr, stt.1, stt.2, stt.3, stt.4)
setnames(airdrops, "airdrop_recipient", "address")


# activity ----

# metric_name: n_transactions
# n.transactions <- QuerySnowflake(
#   "WITH txns AS (
#     -- sent xfers
#     select
#     event_from as address,
#     count(tx_id) as n_txn
#     from
#     terra.transfers 
#     where block_timestamp > current_date - interval '90 days'
#     group by 1
#   
#   union
#   --received xfers
#     select
#     event_to as address,
#     count(tx_id) as n_txn
#     from
#     terra.transfers 
#     where block_timestamp > current_date - interval '90 days'
#     group by 1
#   
#   union
#   
#   --grab the sender from all msgs and msg_events
#   (
#     with msge as (
#       select coalesce(event_attributes:sender,event_attributes:\"0_sender\") as address,
#       count(tx_id) as n_txn
#       from terra.msg_events
#       where block_timestamp > current_date - interval '90 days'
#       group by 1),
#     msgs as (
#       select
#       msg_value:sender as address,
#       count(distinct(tx_id)) as n_txn_msgs
#       from 
#       terra.msgs where block_timestamp > current_date - interval '90 days'
#       group by 1
#     )
#     select 
#     coalesce(msgs.address,msge.address) as address,
#     coalesce(msgs.n_txn_msgs, msge.n_txn) as n_txn
#     from msge full join msgs
#     on msge.address = msgs.address
#     )
#   )
#   SELECT
#   address,
#   'n_transactions' AS metric_name,
#   sum(n_txn) AS metric_value
#   FROM txns
#   GROUP BY address"
# )

n.transactions <- QuerySnowflake("WITH txns AS (
    -- sent xfers
    select
    event_from as address,
    count(tx_id) as n_txn
    from
    terra.transfers 
    where block_timestamp > current_date - interval '90 days'
    group by 1
  
  union
  --received xfers
    select
    event_to as address,
    count(tx_id) as n_txn
    from
    terra.transfers 
    where block_timestamp > current_date - interval '90 days'
    group by 1
  
  union
    -- STAKING 
    select 
      delegator_address,
      count(tx_id) as n_txn
    from 
        terra.staking 
    where block_timestamp > current_date - interval '90 days'
      group by 1    

  union 
      -- bridge into terra
      select 
          msg_value:to_address::string as sender,
          count(tx_id) as n_txn
      from terra.msgs
    where msg_value:from_address::string = 'terra13yxhrk08qvdf5zdc9ss5mwsg5sf7zva9xrgwgc'
        and msg_value:amount[0]:denom::string = 'uluna'
        and tx_status = 'SUCCEEDED'
        and msg_value:amount[0]:amount::string/pow(10,6) > 0
    group by 1

  union 
      -- bridge from terra
      select 
          msg_value:from_address::string as sender,
          count(tx_id) as n_txn
      from terra.msgs
    where msg_value:to_address::string = 'terra13yxhrk08qvdf5zdc9ss5mwsg5sf7zva9xrgwgc'
        and msg_value:amount[0]:denom::string = 'uluna'
        and tx_status = 'SUCCEEDED'
        and msg_value:amount[0]:amount::string/pow(10,6) > 0
      group by 1
  
  union 
  --grab the sender from all msgs and msg_events
  (
    with msge as (
      select coalesce(event_attributes:sender,event_attributes:\"0_sender\") as address,
      count(tx_id) as n_txn
      from terra.msg_events
      where block_timestamp > current_date - interval '90 days'
      group by 1),
    msgs as (
      select
      msg_value:sender as address,
      count(distinct(tx_id)) as n_txn_msgs
      from 
      terra.msgs where block_timestamp > current_date - interval '90 days'
      group by 1
    )
    select 
    coalesce(msgs.address,msge.address) as address,
    coalesce(msgs.n_txn_msgs, msge.n_txn) as n_txn
    from msge full join msgs
    on msge.address = msgs.address
    )
  )
  SELECT
  address,
  'n_transactions' AS metric_name,
  sum(n_txn) AS metric_value
  FROM txns
  GROUP BY address")

n.transactions[, .N, by = metric_value >= 10]

# this one isn't for a metric but I'm going to put it in the data
address.age <- QuerySnowflake(
  "with contenders as (
  select distinct address from (
    select 
    distinct event_from as address
    from terra.transfers 
    where block_timestamp > current_date - interval '90 days'
  union
    select
    distinct coalesce(event_attributes:\"sender\",event_attributes:\"0_sender\") as address
    from terra.msg_events
    where block_timestamp > current_date - interval '90 days'
  )
 )
 -- firstactive
 select
 address,
 'address_age_days' as metric_name,
 min(first_action) as date,
 max(days_since_first_action) as metric_value
 from (
   select
   coalesce(cf.address,ct.address) as address,
   min(t.block_timestamp) as first_action,
   datediff('day',first_action,current_timestamp) as days_since_first_action
   from terra.transfers t
   join contenders cf on cf.address = t.event_from
   join contenders ct on ct.address = t.event_to
   group by 1
   
   union
   
   select
   distinct coalesce(event_attributes:\"sender\",event_attributes:\"0_sender\") as address,
   min(m.block_timestamp) as first_action,
   datediff('day',first_action,current_timestamp) as days_since_first_action
   from terra.msg_events m
   join contenders cf on cf.address = coalesce(m.event_attributes:\"sender\",m.event_attributes:\"0_sender\")
   join contenders ct on ct.address = coalesce(m.event_attributes:\"sender\",m.event_attributes:\"0_sender\")
   group by 1
  )
   group by 1;"
)

all.data <- merge(address.age[, list(address, address_age_days = metric_value)],
                  n.transactions[, list(address, n_transactions = metric_value)],
                  by = "address", all = TRUE)

#most recent action
days.since.active <- QuerySnowflake(
  "with latest as (
     -- sent xfers
    select
    event_from as address,
    max(block_timestamp) as latest
    from
    terra.transfers 
    where block_timestamp > current_date - interval '90 days'
    group by 1
  
  union
  --received xfers
    select
    event_to as address,
    max(block_timestamp) as latest
    from
    terra.transfers 
    where block_timestamp > current_date - interval '90 days'
    group by 1
  
  union
  
  --grab the sender from all msgs and msg_events
  (
    with msge as (
      select coalesce(event_attributes:sender,event_attributes:\"0_sender\") as address,
      max(block_timestamp) as latest_msge
      from terra.msg_events
      where block_timestamp > current_date - interval '90 days'
      group by 1),
    msgs as (
      select
      msg_value:sender as address,
      max(block_timestamp) as latest_msgs
      from 
      terra.msgs where block_timestamp > current_date - interval '90 days'
      group by 1
    )
    select 
    coalesce(msgs.address,msge.address) as address,
    coalesce(msgs.latest_msgs, msge.latest_msge) as latest
    from msge full join msgs
    on msge.address = msgs.address
    )
  ),
  blob as (
    select 
    address,
    max(latest) as latest
    from latest
    group by 1
  )
  select 
  address,
  latest,
  DATEDIFF('days', latest, current_timestamp) as days_since_last
  from blob;"
)

all.data <- merge(all.data,
                  days.since.active[, list(address, days_since_last_txn = days_since_last)],
                  by = "address", all = TRUE)

# # metric_name: max_days_btw_txn
# max.days.btw.txn <- QuerySnowflake(
#   "WITH thing1 AS (
#   select
#   event_from as address,
#   count(tx_id) as n_txn
#   from
#   terra.transfers 
#     where block_timestamp > current_date - interval '90 days'
#   group by 1
#   union
#   select
#     distinct coalesce(event_attributes:\"sender\",event_attributes:\"0_sender\") as address,
#     count(tx_id) as n_txn
#     from terra.msg_events
#     where block_timestamp > current_date - interval '90 days'
#   group by 1),
#   
#   thing2 AS (select
#   event_from as address,
#   block_timestamp
#   from
#   terra.transfers 
#     where block_timestamp > current_date - interval '90 days'
#     AND address IN (SELECT address FROM thing1 WHERE n_txn > 1)
#   group by 1, 2
#   union
#   select
#     distinct coalesce(event_attributes:\"sender\",event_attributes:\"0_sender\") as address,
#     block_timestamp
#     from terra.msg_events
#     where block_timestamp > current_date - interval '90 days'
#     AND address IN (SELECT address FROM thing1 WHERE n_txn > 1)
#   group by 1, 2
#   
#   ORDER BY address, block_timestamp),
#   
#   base AS (
# 	SELECT address, block_timestamp, LAG(block_timestamp, 1) OVER (PARTITION BY address ORDER BY block_timestamp) AS prv_timestamp
# 	FROM thing2
#   )
#   SELECT address, MAX(DATEDIFF('days', prv_timestamp, block_timestamp)) AS max_between_txn
#   FROM base
#   GROUP BY 1
#   ;"
# )


# metric_name: n_contracts
n.contracts <- QuerySnowflake(
  "select
  msg_value: sender :: string as address,
  count(distinct(coalesce(msg_value: contract, msg_value: execute_msg: send: contract))) AS n_contracts
  from 
  terra.msgs
  where block_timestamp > current_date - interval '90 days'
  and msg_module = 'wasm'
  group by 1"
)

all.data <- merge(all.data,
                  n.contracts,
                  by = "address", all = TRUE)



# Cash Out vs HODL ----

# metric_name: net_sent_to_shuttle_cex
net.from.cex <- QuerySnowflake("WITH to_cex AS (
                              SELECT 
                              event_from AS address,
                              sum(event_amount_usd) AS sent_to_cex,
                              count(distinct(tx_id)) AS n_txn_to_cex
                              FROM terra.transfers WHERE event_to_label_type = 'cex'
                              AND event_from_label_type IS NULL
                              AND block_timestamp > current_date - interval '90 days'
                              AND tx_status = 'SUCCEEDED'
                              GROUP BY address),
                              from_cex AS (
                              SELECT 
                              event_to AS address,
                              sum(event_amount_usd) AS rec_from_cex,
                              count(distinct(tx_id)) AS n_txn_from_cex
                              FROM terra.transfers WHERE event_from_label_type = 'cex'
                              AND event_to_label_type IS NULL
                              AND block_timestamp > current_date - interval '90 days'
                              AND tx_status = 'SUCCEEDED'
                              GROUP BY address)
                              
                              SELECT
                              coalesce(tc.address, fc.address) AS address,
                              coalesce(sent_to_cex, 0) AS sent_to_cex_usd,
                              coalesce(n_txn_to_cex, 0) AS n_txn_to_cex_usd,
                              coalesce(rec_from_cex, 0) AS rec_to_cex_usd,
                              coalesce(n_txn_from_cex, 0) AS n_txn_from_cex_usd,
                              coalesce(rec_from_cex, 0) - coalesce(sent_to_cex, 0) AS net_from_cex_usd
                              FROM to_cex tc
                              FULL OUTER JOIN from_cex fc ON tc.address = fc.address")




net.from.bridges <- QuerySnowflake("
WITH to_bridge AS (select
  event_from as address,
  count(tx_id) AS n_txn_to_bridge,
  sum(event_amount_usd) AS sent_to_bridge
  from terra.transfers
  where event_to = 'terra13yxhrk08qvdf5zdc9ss5mwsg5sf7zva9xrgwgc'
  AND tx_status = 'SUCCEEDED'
  AND block_timestamp > current_date - interval '90 days'
  AND event_from_label_type IS NULL
  GROUP BY address),
  from_bridge AS (
SELECT
		event_to as address,
		count(tx_id) AS n_txn_from_bridge,
  	sum(event_amount_usd) AS rec_from_bridge
from terra.transfers
where event_from = 'terra13yxhrk08qvdf5zdc9ss5mwsg5sf7zva9xrgwgc'
  AND tx_status = 'SUCCEEDED'
  AND block_timestamp > current_date - interval '90 days'
  AND event_to_label_type IS NULL 
group by address)

SELECT
coalesce(tb.address, fb.address) AS address,
coalesce(sent_to_bridge, 0) AS sent_to_bridge_usd,
coalesce(n_txn_to_bridge, 0) AS n_txn_to_bridge_usd,
coalesce(rec_from_bridge, 0) AS rec_to_bridge_usd,
coalesce(n_txn_from_bridge, 0) AS n_txn_from_bridge_usd,
coalesce(rec_from_bridge, 0) - coalesce(sent_to_bridge, 0) AS net_from_bridge_usd
FROM to_bridge tb
FULL OUTER JOIN from_bridge fb ON tb.address = fb.address
")




shuttle.cex <- merge(net.from.cex, net.from.bridges,
                     by = "address", all = TRUE)
ReplaceValues(shuttle.cex)

shuttle.cex[, net_from_shuttle_cex := net_from_cex_usd + net_from_bridge_usd]


all.data <- merge(all.data,
                  shuttle.cex,
                  by = "address", all = TRUE)



# metric_name: prop_luna_staked
# luna.staking <- QuerySnowflake("SELECT * FROM terra.staking")
# luna.staking[, xfer_date := as.Date(block_timestamp)]

luna.stake.balances <- QuerySnowflake(
"WITH maxdate as (
  select max(date) as date 
  from terra.daily_balances
  where date > current_date - 7
),

luna_staked AS (
SELECT address, balance AS staked_luna 
FROM terra.daily_balances
WHERE date = (select date from maxdate) - interval '1 day'
AND address_label IS NULL
AND balance_type = 'staked' 
AND currency = 'LUNA')

SELECT 
  bals.address, 
  balance AS liquid_luna, 
  staked_luna,
  staked_luna / (balance + staked_luna) AS staked_prop
FROM terra.daily_balances bals
FULL OUTER JOIN luna_staked ON bals.address = luna_staked.address
WHERE date = (select date from maxdate) - interval '1 day'
AND address_label IS NULL
AND balance_type = 'liquid' 
AND currency = 'LUNA'
AND staked_luna > 0;                                      
")

luna.stake.balances[is.na(liquid_luna), liquid_luna := 0]
luna.stake.balances <- luna.stake.balances[, list(liquid_luna = mean(liquid_luna),
                                                  staked_luna = mean(staked_luna)),
                                           by = address]

luna.stake.balances[, staked_prop := staked_luna / (staked_luna + liquid_luna)]

all.data <- merge(all.data,
                  luna.stake.balances,
                  by = "address", all = TRUE)


# metric_name: prop_drops_kept, repeat_protocol_claims, n_tokens_claimed
# query is in airdrop_tracking_queries.R


# degen ----

#metric_name: n_dex_trades
# source("degen_queries.R")

# degen queries by hfuhruhurr

# -------------------------------------------------------------------------------------------------------------------------------
#   -- GOAL #1 (Baby Degen):  Find addresses that have swapped in the last 90d.  
# --
#   -- GOAL #2 (Multi-tokenate):  Find addresses that have swapped at least 5 different tokens in the last 90d. 
# --
#   -- Need event-level transaction detail...use terra.msg_events.
# --
#   -- Grab the sender and recipient addresses for each event.  
# -- This info could be in one of many places...hence the COALESCE() lines.
# -- The unique values are those involved in swaps...executed by the UNPIVOT() lines.
# --
#   -- Grab the from_asset and to_asset info for each event.  
# -- The unique values are the tokens being swapped...executed by the UNPIVOT() lines.
# -------------------------------------------------------------------------------------------------------------------------------

any.dex.trade <- QuerySnowflake("
with 
swap_events as (
select 
  event_type,
  tx_id,
  coalesce(event_attributes:sender::string,
           event_attributes:\"0_sender\"::string,
           event_attributes:from::string,
           event_attributes:\"0_from\"::string)      as sender,
  coalesce(event_attributes:recipient::string,
           event_attributes:\"0_recipient\"::string,
           event_attributes:to::string,
           event_attributes:\"0_to\"::string)        as recipient,
  event_attributes:offer_asset::string             as from_asset,
  event_attributes:ask_asset::string               as to_asset

from 
  terra.msg_events 

where 
  tx_status = 'SUCCEEDED'
  and event_attributes:offer_asset is not null
  and block_timestamp >= current_date - interval '90 days'
)
select distinct 
  dude AS address,
  count(tx_id) as n_swaps
  
from 
  swap_events

unpivot (dude  for dude_type  in (sender    , recipient)) 
unpivot (token for token_type in (from_asset, to_asset ))
group by dude
")

# did.an.lp <- QuerySnowflake("
#                             with 
# liquidity_add_txs as (
# select 
#   msg_value:sender::string as provider,
#   tx_id                    ,
#   count(*)                 as n_msgs  -- multiple msgs doesn't mean multiple liquidity adds
#                                       -- eg, 1F9EB3666466DF90D003C44153AEA330852E28418FED5B8C8645E53C7D96B952
#                                       --     this tx did an increase_allowance on the nETH-Psi pool (expected) and on the Psi token (huh?)
#                                       --     and it appears to be an auto-generated add...should this count towards degeneracy?  
#   
# from 
#   terra.msgs
#   
# where 
#   tx_status = 'SUCCEEDED'
#   and block_timestamp::date = '11/1/2021' 
#   and (   msg_value:execute_msg:increase_allowance is not null   -- plain vanilla way of adding liquidity
#        or msg_value:execute_msg:zap_into_strategy  is not null)  -- fancy schmancy Apollo DAO way of adding liquidity (on your behalf, of course)
# 
# group by 1,2
# )
# select 
#   provider AS address, 
#   count(tx_id) as n_lp_deposits
# 
# from 
#   liquidity_add_txs 
# 
# group by 1")

did.an.lp <- QuerySnowflake(
  "select 
  coalesce(event_attributes: sender :: string,
         event_attributes: owner :: string) as address,
  count(distinct(tx_id)) as n_deposits
  from 
  terra.msg_events
  where block_timestamp > current_date - interval '90 days'
  and msg_module = 'wasm'
  and event_type = 'wasm'
  and (
    event_attributes:\"0_action\" in ('provide_liquidity','bond')
    OR event_attributes:action in ('increase_allowance')
  ) group by 1"
)


# any.dex.trade loads from 
all.data <- merge(all.data,
                  any.dex.trade,
                  by = "address", all = TRUE)


# metric_name: n_lp_deposits
# what can we add to this for the data download?
all.data <- merge(all.data,
                  did.an.lp,
                  by = "address", all = TRUE)


#transactions involving project gov tokens
n.tokens.used <- QuerySnowflake("WITH 
swap_events as (
  select 
  event_type,
  coalesce(event_attributes:sender::string,
           event_attributes:\"0_sender\"::string,
           event_attributes:from::string,
           event_attributes:\"0_from\"::string)      as sender,
  coalesce(event_attributes:recipient::string,
           event_attributes:\"0_recipient\"::string,
           event_attributes:to::string,
           event_attributes:\"0_to\"::string)        as recipient,
  event_attributes:offer_asset::string             as from_asset,
  event_attributes:ask_asset::string               as to_asset
  
  from 
  terra.msg_events 
  
  where 
  tx_status = 'SUCCEEDED'
  and event_attributes:offer_asset is not null
  and block_timestamp >= current_date - interval '90 days'
),
swapsss AS (
  select distinct 
  dude AS address,
  token 
  
  from 
  swap_events
  
  unpivot (dude  for dude_type  in (sender    , recipient)) 
  unpivot (token for token_type in (from_asset, to_asset ))
),
txns AS(
  select * from (select 
                 coalesce(event_attributes: sender:: string, event_attributes: \"0_sender\":: string) as address,
                 tx_id,
                 case when event_attributes: ask_asset:: string = 'uluna' then 'luna'
                 when event_attributes: ask_asset:: string = 'uusd' then 'ust' 
                 else event_attributes: ask_asset:: string end as to_asset, 
                 case when event_attributes: offer_asset:: string = 'uluna' then 'luna'
                 when event_attributes: offer_asset:: string = 'uusd' then 'ust' 
                 else event_attributes: offer_asset:: string end as from_asset
                 from terra.msg_events 
                 where block_timestamp > current_date - interval '90 days'
                 and event_type = 'wasm'
                 and event_attributes: ask_asset IS NOT NULL) where address is NOT NULL),
  
  everything AS (
    SELECT
    address, from_asset AS token
    FROM txns
    GROUP BY address, token
    UNION
    SELECT
    address, to_asset AS token
    FROM txns
    GROUP BY address, token  
    
    UNION
    
    select distinct
    msg_value: sender :: string as address,
    case when msg_value: contract :: string = 'terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76' then 'ANC'
    when msg_value: contract :: string = 'terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy' then 'MINE'
    when msg_value: contract :: string = 'terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6' then 'VKR'
    when msg_value: contract :: string = 'terra12897djskt9rge8dtmm86w654g7kzckkd698608' then 'MIR'
    when msg_value: contract :: string = 'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n' then 'PSI'
    when msg_value: contract :: string = 'terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5' then 'STT'
    when msg_value: contract :: string = 'terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4' then 'LOOP'
    end as token
    from 
    terra.msgs
    where block_timestamp > current_date - interval '90 days'
    and msg_module = 'wasm'
    and msg_value: contract IN ('terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76','terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy','terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6',
                                'terra12897djskt9rge8dtmm86w654g7kzckkd698608',
                                'terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n','terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5','terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4')
    
    union
    
    -- add in tokens and currencies transferred natively
    select distinct
    event_from as address,
    event_currency as token
    from terra.transfers
    where block_timestamp > current_date - interval '90 days'
    
    union
    
  select * from swapsss
  
  )
  SELECT
  address, count(distinct(token)) AS n_tokens
  FROM everything
  GROUP BY address")

#token.degen[, .N, by = n_tokens_used > 5]

all.data <- merge(all.data,
                  n.tokens.used[, list(address, n_tokens_used = n_tokens)],
                  by = "address", all = TRUE)


# governance ----
notable.tokens <- data.table(
  protocol = c("anchor","pylon","valkyrie","mirror","nexus","starterra","loop","spectrum"),
  token = c("ANC","MINE","VKR","MIR","PSI","STT","LOOP","SPEC"),
  token_contract = c("terra14z56l0fp2lsf86zy3hty2z47ezkhnthtr9yq76","terra1kcthelkax4j9x8d3ny6sdag0qmxxynl3qtcrpy",
                     "terra1dy9kmlm4anr92e42mrkjwzyvfqwz66un00rwr5","terra15gwkyepfc6xgca5t5zefzwy42uts8l2m4g40k6",
                     "terra12897djskt9rge8dtmm86w654g7kzckkd698608","terra13xujxcrc9dqft4p9a8ls0w3j0xnzm6y2uvve8n",
                     "terra1nef5jf6c7js9x6gkntlehgywvjlpytm7pcgkn4","terra1s5eczhe0h0jutf46re52x5z4r03c8hupacxmdr"),
  staking_contract = c("terra1f32xyep306hhcxxxf7mlyh0ucggc00rm2s9da5","terra1xu8utj38xuw6mjwck4n97enmavlv852zkcvhgp",
                       "terra1w6xf64nlmy3fevmmypx6w2fa34ue74hlye3chk","terra1wh39swv7nq36pnefnupttm2nr96kz7jjddyt2x",
                       "terra1xrk6v2tfjrhjz2dsfecj40ps7ayanjx970gy0j","terra1v6cagryg27qyk7alp7lq35fttkjyn8cmd73fgv",
                       NA,"terra1dpe4fmcz2jqk6t50plw0gqa2q3he2tj6wex5cl")
)



governance.votes <- core.gov.voting <- QuerySnowflake("select
  voter AS address, 
  count(distinct proposal_id) as n_gov_votes
from terra.gov_vote
where block_timestamp > current_date - interval '90 days'
group by address")

protocol.voting <- QuerySnowflake(
  "select
  event_attributes:contract_address::string as staking_contract,
  event_attributes:voter::string as voters,
  count( distinct tx_id ) as n_gov_votes
  from terra.msg_events
  where event_type = 'from_contract'
    and event_attributes:action = 'cast_vote'
    and block_timestamp > current_date - 90
  group by 1,2;"
)
protocol.voting <- merge(
  protocol.voting,
  notable.tokens[,list(staking_contract,protocol)],
  by = "staking_contract",
  all.x = T
)

gov.voting <- rbind(core.gov.voting[,list(protocol = "terracore", address, n_gov_votes)],
                protocol.voting[,list(protocol,address = voters, n_gov_votes)])
gov.voting.summary <- data.table::dcast(gov.voting, address ~ protocol, value.var = "n_gov_votes")
ReplaceValues(gov.voting.summary)
setnames(gov.voting.summary, names(gov.voting.summary)[-1], paste0(names(gov.voting.summary)[-1], "_gov_votes"))

gov.voting.summary <- merge(gov.voting.summary,
                            gov.voting[, list(n_gov_votes = sum(n_gov_votes)), by = address],
                            by = "address")

all.data <- merge(all.data,
                  gov.voting.summary,
                  by = "address", all = TRUE)


staking.events <- lapply(
  unique(notable.tokens$token), function(.token){
    print(.token)
    n.t <- notable.tokens[ token == .token ]
    .staking <- n.t$staking_contract
    .tokencontr <- n.t$token_contract
    to.return <- QuerySnowflake(paste0(
      "select
        distinct(msg_value: sender :: string) as address,
        (count(*) OVER(PARTITION BY address)) AS no_of_staking_occurences,
        (
            sum(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as tokens_staked,
        (
            avg(
                msg_value: execute_msg: send: amount / pow(10, 6)
            ) OVER(PARTITION BY address)
        ) as avg_tokens_staked_per_txn
    from
        terra.msgs
    where
        tx_status = 'SUCCEEDED' 
        and msg_value: contract = '",.tokencontr,"'
        and msg_value: execute_msg: send: contract  = '",.staking,"'
        and block_timestamp >= current_date - interval '90 days'
"))
    to.return$token <- .token
    return(to.return)
  })
staking.events <- rbindlist(staking.events)


tmp.gov.staking.1 <- data.table::dcast(staking.events[, list(address, no_of_staking_occurences, token)],
                                       address ~ token, value.var = "no_of_staking_occurences", fun.aggregate = sum)
setnames(tmp.gov.staking.1, names(tmp.gov.staking.1)[-1], paste0("n_gov_stakes_", names(tmp.gov.staking.1)[-1]) )

tmp.gov.staking.2 <- data.table::dcast(staking.events[, list(address, tokens_staked, token)],
                                       address ~ token, value.var = "tokens_staked", fun.aggregate = sum)
setnames(tmp.gov.staking.2, names(tmp.gov.staking.2)[-1], paste0("tokens_gov_staked_", names(tmp.gov.staking.2)[-1]) )


all.data <- merge(all.data,
                  merge(tmp.gov.staking.1, tmp.gov.staking.2, by = "address", all = TRUE),
                  by = "address", all = TRUE)



# tbd on altering this for the final export:
# staking.events <- rbind(
#   staking.events[,list(n_projects_staked = uniqueN(token)), by = address ] %>%
#     .[,list(address,metric_name = "n_projects_staked",metric_value = n_projects_staked)],
#   staking.events[,list(total_gov_staking_events = sum(no_of_staking_occurences)), by = address ] %>%
#     .[,list(address,metric_name = "n_gov_staking_events",metric_value = total_gov_staking_events)],
#   data.table::melt(staking.events,id.vars = c("address","token"),variable.name = "metric_name",value.name = "metric_value") %>%
#     .[,list(address,metric_name = paste(token,metric_name,sep = "_"),metric_value)]
# )

# arrange airdrops to fit into the "big file of all datas"
airdrops[, token2 := ifelse(substr(token, 1, 4) %in% c("MINE", "LOOP"), tolower(substr(token, 1, 4)), tolower(substr(token, 1, 3)))]
names(airdrops)

tmp.airdrops <- data.table::melt(airdrops[, list(address,
                                                 token = toupper(token2),
                                                 tokens_held,
                                                 total_airdrop_tokens_claimed,
                                                 no_of_airdrop_claim_occurences,
                                                 first_airdrop_tokens_claimed)], id.vars = c("address", "token"))
tmp.airdrops[variable == "tokens_held", variable := "airdrop_tokens_held"]
tmp.airdrops[variable == "total_airdrop_tokens_claimed", variable := "airdrop_n_tokens_claimed"]
tmp.airdrops[variable == "no_of_airdrop_claim_occurences", variable := "n_airdrop_claims"]
tmp.airdrops[variable == "first_airdrop_tokens_claimed", variable := "first_airdrop_claimed"]

airdrops.to.save <- data.table::dcast(tmp.airdrops,
                address ~ token + variable, value.var = "value", fun.aggregate = sum)

all.data <- merge(all.data,
      airdrops.to.save,
      by = "address", all = TRUE)

# calculate metrics ----

# governance
# rock the vote
gov1 <- gov.voting.summary[, list(address, 
                                metric_name = "n_governance_votes",
                                metric_value = n_gov_votes)]
# gov degen
gov2 <- staking.events[, list( metric_name = "n_projects_staked", 
                               metric_value = uniqueN(token)),
                       by = address ]

# terra activist
gov3 <- merge(staking.events[, .N, by = list(token2 = tolower(token), address)],
              airdrops[, .N, by = list(token2, address)], 
              by = c("token2", "address"), all = FALSE) %>%
  .[, list(metric_name = "n_airdrop_and_gov_stakes", 
           metric_value = .N), by = address]


# 1, 2, 3
# gov degen
# terra activist
# rock the vote


# airdrops
#claimed > 2 airdrops
airdrop1 <- airdrops[, list(metric_name = "n_airdrops_claimed",
                            metric_value = sum(no_of_airdrop_claim_occurences)), 
                     by = address]

# claimed the same protocol more than once
airdrop2 <- airdrops[, sum(no_of_airdrop_claim_occurences), by = "token2,address"] %>%
  .[V1 > 1] %>%
  .[, list(metric_name = "repeat_protocol_claims", metric_value = .N), by = address]


# claim at least x different tokens
airdrop3 <- airdrops[, list(metric_name = "n_protocols_claimed", metric_value = uniqueN(token2)), by = address]


# degeneracy
# at least one dex trade
degen1 <- any.dex.trade[, list(address, metric_name = "n_dex_trades", 
                               metric_value = n_swaps)]

# at least 5 tokens (only 5 people wwhhhat?)
degen2 <- n.tokens.used[, list(address, metric_name = "n_tokens_used", 
                                     metric_value = n_tokens)]

# lp
degen3 <- did.an.lp[, list(address, metric_name = "n_lp_deposits", metric_value = n_deposits)]


# activity
# at least 10 txns
activity1 <- n.transactions[, list(address, metric_name, metric_value)]

# awake at the wheel
activity2 <- days.since.active[,list(address,metric_name = "days_since_last_txn",
                                     metric_value = days_since_last)]

# projects (contracts):
activity3 <- n.contracts[, list(address, metric_name = "n_contracts", 
                               metric_value = n_contracts)]

# cash out vs hodl
# more from shuttle / cex than to
cash.vs.hodl1 <- shuttle.cex[, list(metric_name = "net_from_shuttle_cex", metric_value = sum(net_from_shuttle_cex)), by = address]


# luna staked
cash.vs.hodl2 <- luna.stake.balances[, list(metric_name = "prop_luna_staked", 
                                            metric_value = staked_prop), by = address]

# can't dump won't dump
dumper <- airdrops[, list(prop_held = sum(tokens_held) / sum(total_airdrop_tokens_claimed)), by = "address,token2"][!is.na(prop_held)]
cash.vs.hodl3 <- dumper[, list(metric_name = "prop_drops_kept", 
                               metric_value = mean(prop_held)), by = address]
cash.vs.hodl3[metric_value > 1, metric_value := 1]

# from here to the bottom is just organizing the final data set
metric.data.m <- rbind(activity1,
                       activity2,
                       activity3,
                       airdrop1,
                       airdrop2,
                       airdrop3,
                       degen1,
                       degen2,
                       degen3,
                       gov1,
                       gov2,
                       gov3,
                       cash.vs.hodl1,
                       cash.vs.hodl2,
                       cash.vs.hodl3)
metric.data.m <- rbind(metric.data.m,
                       data.table(address = unique(metric.data.m[address %notin% cash.vs.hodl1$address]$address),
                                  metric_name = "net_from_shuttle_cex", metric_value = 0))


# load the score details:
score.criteria <- fread("score_criteria.csv")

# fill in the %s's:
score.criteria$score_description <- sapply(1:nrow(score.criteria), function(i) {
  print(i)
  to.return <- sprintf(score.criteria[i]$score_description, score.criteria[i]$critera_for_score, ifelse(score.criteria[i]$critera_for_score > 1, "s", ""))
  print(to.return)
  return(to.return)
})


# calculate scores
metric.data.m <- merge(metric.data.m, score.criteria, by = "metric_name")
metric.data.m[, metric_score := ifelse(criteria_direction == "greater",
                                      ifelse(metric_value >= ifelse(critera_for_score >= 50, critera_for_score/100, critera_for_score), points, 0),
                                      ifelse(metric_value < critera_for_score, points, 0))]



# summarize scores
score.data <- rbind(metric.data.m[, list(metric_name = "Total Score", metric_value = sum(metric_score, na.rm = TRUE)), by = address],
                    metric.data.m[, list(metric_value = sum(metric_score, na.rm = TRUE)), by = list(address, metric_name = category)])


score.data <- score.data[!is.na(address) & substr(address, 1, 5) == "terra" & 
                   substr(address, 1, 12) != "terravaloper" & (metric_value > 0 | metric_name != "Total Score")]

# make a wide table to make a smaller file
metric.data <- dcast.data.table(metric.data.m[address %in% score.data$address], 
                                address ~ metric_name, value.var = "metric_value", fun.aggregate = sum)

# summarize by category
category.medians <- score.data[, list(median_score = median(metric_value), 
                                      mean_score = mean(metric_value)), by = metric_name]
# summarize by metric
metric.medians <- metric.data.m[, list(median_score = median(metric_value), mean_score = mean(metric_value)), by = metric_name]
metric.score.medians <- metric.data.m[, list(mean_score = mean(metric_score), 
                                             prop_achieved = sum(metric_score >= 1) / uniqueN(score.data$address),
                                             n_achieved = sum(metric_score >= 1)), by = metric_name]

# wide metric score file to save
metric.score.data <- dcast.data.table(metric.data.m[address %in% score.data$address], 
                                      address ~ metric_name, value.var = "metric_score", fun.aggregate = sum)

# pre-calculate data for the histogram plot
plot.data <- score.data[metric_name == "Total Score", .N, by = metric_value][order(metric_value)]


# final bits of data:
scores <- data.table::dcast(score.data, address ~ metric_name, value.var = "metric_value", fun.aggregate = sum)
metric.score.data <- merge(scores[, list(address, `Total Score`)], metric.score.data, by = "address")

n.scores <- nrow(scores[`Total Score` > 0])

# fin:
# save(score.criteria, 
#      scores,
#      metric.score.data,
#      plot.data,
#      n.scores,
#      file = "data.RData")
# 
# 
# write.csv(all.data, file = "all_data.csv", row.names = FALSE)

# fin:
switch(
  Sys.info()["user"],
  "fcaster" = {
    save(score.criteria, 
         scores,
         metric.score.data,
         plot.data,
         n.scores,
         file = "/srv/shiny-server/lunatics/data.RData")
    write.csv(all.data, file = "/srv/shiny-server/lunatics/all_data.csv", row.names = FALSE)
  },
  {
    save(score.criteria, 
         scores,
         metric.score.data,
         plot.data,
         n.scores,
         file = "data.RData")
    write.csv(all.data, file = "all_data.csv", row.names = FALSE)
  }
)






