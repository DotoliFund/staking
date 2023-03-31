import { HardhatRuntimeEnvironment } from "hardhat/types"
import { ethers } from "hardhat"

async function main() {
  const [test_account_1] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", test_account_1.address);
  console.log("Account balance:", (await test_account_1.getBalance()).toString());
  const DotoliTokenAddress = '0x3CE9C63607A24785b83b3d6B3245846d402fB49b';

  const DotoliStaking = await ethers.getContractFactory("DotoliStaking");
  const staking = await DotoliStaking.deploy(DotoliTokenAddress, DotoliTokenAddress);
  await staking.deployed();
  console.log("DotoliStaking address : ", staking.address);
  console.log("Account balance:", (await test_account_1.getBalance()).toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});