// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
 
  const L2VotingOnChainRequest = await hre.ethers.getContractFactory("L2VotingOnChainRequest");
  const ERC721_ADDRESS = "0x9C8fF314C9Bc7F6e59A9d9225Fb22946427eDC03"; // NounsDAO
  const SNAPSHOT_BLOCK = 17856136; //August 6, 2023
  
  const contract = await L2VotingOnChainRequest.deploy(ERC721_ADDRESS, SNAPSHOT_BLOCK);

  console.log("Deploying L2VotingOnChainRequest...");
  await contract.deployed();

  console.log(
    ` Deployed with address: ${contract.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
