# Contract Level DID

This project is an entry for the [Cheqd Verifiable AI Hackathon 2025](https://dorahacks.io/hackathon/cheqd-verifiable-ai/ideaism), and demonstrates how to mint an onchain DID (Decentralized Identifier) with [Cheqd](https://docs.cheqd.io/product/studio/dids/create-did) through [Chainlink Functions](https://chain.link/functions) for users who have completed Sybil-resistant KYC with a licensed entity through [Contract Level Compliance](https://github.com/contractlevel/compliance).

## Chainlink Functions Secrets

The following will upload the `CHEQD_API_KEY` in a `.env` file, that will be hosted by the DON for 24 hours.

```
node functions/uploadSecrets.js
```

## Usage

The onchain entry point into the system is `DIDRequestManager::requestCompliantStatus()`.

1. User must approve the `DIDRequestManager` to spend LINK tokens, covering the fee of Contract Level Compliance.
2. The system will then check the compliance status of the user - if they have completed Sybil-resistant KYC with a licensed entity:
3. A callback will automatically be made, calling the Cheqd API via Chainlink Functions to create a new DID.
4. Chainlink Functions will then return the response, minting a unique onchain NFT, representing the Cheqd DID to the compliant user.

## Testing

Run unit tests with:

```
forge test --mt test_did
```

## Deployments (Eth Sepolia)

[DIDRequestManager](https://sepolia.etherscan.io/address/0x3fad1b42b710ee9ECe30cdBC900Fd095366579cE#code)

[LevelDID](https://sepolia.etherscan.io/address/0xE4C1292B13CF51B0ce678195E8069f2F3AF56ea7#code)

[requestCompliantStatus tx](https://sepolia.etherscan.io/tx/0x72e617d53c64dca754cb2dfc8e3e1d62b896c44c326691f6aec35d8ad691f176)
