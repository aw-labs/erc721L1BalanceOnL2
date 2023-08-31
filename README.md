# Overview
This contract allows the number of specific ERC721 holdings on L1 to be checked from L2.

# Deploy and verify command
ERC721 contracts and block id on L1 must be specified in order for a snapshot-like implementation to be validated on L1.

```shell
npx hardhat run scripts/deploy.js 
npx hardhat verify --network goerliOptimism [CONTRACT ADDRESS]
```

# Deployed contract

Optimism goerli: 0x9697aA1661283845489209be97E5eE37532bd897
