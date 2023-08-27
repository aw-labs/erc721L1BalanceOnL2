require('dotenv').config()
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')

module.exports = {
  solidity: "0.8.17",
  defaultNetwork: 'goerliOptimism',
  networks: {
    hardhat: {
      chainId: 420,
    },
    goerliOptimism: {
      url: process.env.RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      gasPrice: 20000000000 // 20 gwei
    },
  },
  etherscan: {
    apiKey: {
      goerliOptimism: process.env.SCAN_API_KEY
    },
    customChains: [
      {
        network: "goerliOptimism",
        chainId: 420,
        urls: {
          apiURL: "https://api-goerli-optimism.etherscan.io/api",
          browserURL: "https://goerli-optimism.etherscan.io"
        }
      }
    ]
  }
}
