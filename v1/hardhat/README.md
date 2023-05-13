# Revenue Share Vault

## Development
```
yarn install
yarn compile
yarn test
```

## Deployment
* Set the corresponding env variables as in .envrc.example
* Then run yarn deploy with specific tags of deploy script, i.e.
```
yarn deploy --tags RevenueShareVaultRibbonEarnMock --gasprice 30000000000
```

## Etherscan verify
```
hardhat --network goerli etherscan-verify [--api-key <apikey>] [--apiurl <https://api-goerli.etherscan.io>] [--sleep]
```

## Docs
* [High level design](https://docs.google.com/document/d/12nkopFwwz0xqZGNzzpnlJ63a--mSYwqaBId5bz2a2Do/edit?usp=sharing)
* [docgen](https://github.com/cinchprotocol/contracts/blob/main/v1/hardhat/docs/index.md)
