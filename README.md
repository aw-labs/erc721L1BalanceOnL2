
# Deploy and verify command
ERC721 contracts and block id on L1 must be specified in order for a snapshot-like implementation to be validated on L1.

```shell
npx hardhat run scripts/deploy.js 
npx hardhat verify --network goerliOptimism [CONTRACT ADDRESS] 0x9C8fF314C9Bc7F6e59A9d9225Fb22946427eDC03 17856136
```
