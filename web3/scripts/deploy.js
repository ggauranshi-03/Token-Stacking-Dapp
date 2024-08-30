const hre = require("hardhat");

async function main() {
  //STAKING CONTRACT
  const tokenStaking = await hre.ethers.deployContract("TokenStaking");
  await tokenStaking.waitForDeployment();
  //TOKEN CONTRACT
  const springTokens = await hre.ethers.deployContract("SpringTokens");
  await springTokens.waitForDeployment();
  //CONTRACT ADDRESS
  console.log(tokenStaking.target); //0xA154253EbbFd5ac336a61A5AcC36f341F52ebefF
  console.log(springTokens.target); //0x700f2e41052bdA10BDC68599A095928DAe6CDa28
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
