import { HardhatRuntimeEnvironment } from "hardhat/types"
import { ethers } from "hardhat"

async function main() {
  const [account] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", account.address);
  console.log("Account balance:", (await account.getBalance()).toString());
  const DotoliTokenAddress = '0xFd78b26D1E5fcAC01ba43479a44afB69a8073716';

  const DotoliStaking = await ethers.getContractFactory("DotoliStaking");
  const staking = await DotoliStaking.deploy(DotoliTokenAddress, DotoliTokenAddress);
  await staking.deployed();
  console.log("DotoliStaking address : ", staking.address);
  console.log("Account balance:", (await account.getBalance()).toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});