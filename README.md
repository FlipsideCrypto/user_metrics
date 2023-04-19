# user_metrics

## :wave: Introduction 
This repo is a source for anyone looking to construct user metrics or scores for blockchain users. User metrics are grouped into six categories: 

- General Activity
- DeFi
- Governance
- NFTs
- Bags
- Airdrops 

Each of these categories contain standard metrics that are applied across chains to the extent that metric is applicable to the given blockchain. 

## :black_square_button: Blockchains
This repo contains user metric SQL queries for the following blockchains: 

- Algorand
- Axelar
- Cosmos
- Ethereum
- Flow
- NEAR
- Osmosis 
- Solana

Additional blockchains will be supported in the future as their data is ingested into the Flipside Crypto data warehouses. 

## :file_folder: Folder Structure

The main folder of this repo contains two primary folders, sql and apps. The sql folder contains queries used to power applications and has the following folder structure:

SQL Folder Structure:

> category
>> chain
>>> metric
>>>> metric_name.sql
>> chain
>>> metric
>>>> metric_name.sql

Apps Folder Structure: 

> chain
>> www 

## :tada: Application Links

[Optimist Score](https://science.flipsidecrypto.xyz/optimist/) 

[Solar Scored](https://science.flipsidecrypto.xyz/solarscored/)

[Flow Scored](https://science.flipsidecrypto.xyz/flowscored/)
