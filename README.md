# Contract Level Credentials

This project is an entry for the [Cheqd Verifiable AI Hackathon 2025](https://dorahacks.io/hackathon/cheqd-verifiable-ai/ideaism), and demonstrates how to mint an onchain credential linked to a [Cheqd DID](https://docs.cheqd.io/product/studio/dids/create-did) through [Chainlink Functions](https://chain.link/functions) for users who have completed Sybil-resistant KYC with a licensed entity through [Contract Level Compliance](https://github.com/contractlevel/compliance).

## Table of Contents

- [Contract Level Credentials](#contract-level-credentials)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Chainlink Functions](#chainlink-functions)
  - [Usage](#usage)
  - [Testing](#testing)
  - [Deployments (Eth Sepolia)](#deployments-eth-sepolia)

## Overview

Users who want to mint a Contract Level Credential must pass a `cheqd did identifier string` to the `DIDRequestManager` contract, and pay in `LINK`. The Contract Level infrastructure then checks if the user has completed Sybil-resistant KYC with a licensed entity. If the user's compliant status has been confirmed, a call is made to the Cheqd API, via Chainlink Functions, to fetch publicKey data about the user's passed `cheqd did`. The Chainlink Functions callback will then mint a Contract Level Credential (see `LevelDID` contract) to the user.

Contract Level Credentials are "semi-soulbound" NFTs, with data fetched from the Cheqd API saved in contract storage. Cheqd DID public key owners can then sign a message of confirmation, linking their Cheqd DID to their Contract Level Credential.

Contract Level Credentials are "semi-soulbound" because they can be transferred for use in onchain applications, but can only be transferred back to the original owner.

## Chainlink Functions

The code that is run by the Chainlink Functions DON to call the Cheqd API and handle the response can be found in `functions/source.js`. A condensed equivalent of this is stored as a constant in the `DIDRequestManager` contract (to save on gas).

The following will upload the `CHEQD_API_KEY` in a `.env` file, that will be hosted by the DON for 24 hours.

```
node functions/uploadSecrets.js
```

## Usage

The onchain entry point into the system is `DIDRequestManager::requestCompliantStatus()`.

1. User must approve the `DIDRequestManager` to spend LINK tokens, covering the fee of Contract Level Compliance.
2. User must pass the Cheqd DID identifier string when calling `DIDRequestManager::requestCompliantStatus()`.
3. The system will then check the compliance status of the user - if they have completed Sybil-resistant KYC with a licensed entity:
4. A callback will automatically be made, calling the Cheqd API via Chainlink Functions to fetch data about a DID.
5. Chainlink Functions will then return the response, minting a unique onchain NFT, representing the Cheqd DID to the compliant user, with the DID's associated public key as the `tokenURI`.

## Testing

Run unit tests with:

```
forge test --mt test_did
```

## Deployments (Eth Sepolia)

[DIDRequestManager](https://sepolia.etherscan.io/address/0x4386a5535101c255fc6f246e8dfef75a180839df#code)

[LevelDID](https://sepolia.etherscan.io/address/0x3251fa43986c9c7d2d9797ec15f4fb2860172314#code)

[requestCompliantStatus tx](https://sepolia.etherscan.io/tx/0xe59cc44450c0a0cddabe0e3bba501ae4b453dc6afd746ffd1092da27fb723998)

[mintDID tx](https://sepolia.etherscan.io/tx/0xfab1f1e721164cb05b6776fcdf01e06e58bab5994626b2af98af598a6f2053ce)

[CLA tx](https://sepolia.etherscan.io/tx/0x6785d31e107c10a16501bd6072cd505d1c703166373c587e3bf4f1a8430815e0)

[CLF tx](https://functions.chain.link/sepolia/4467#/side-drawer/request/0xf01d80519c4b720db876d296dd023948415d5b8afd74c645da167d05f714bcc9)
