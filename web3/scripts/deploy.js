const hre = require("hardhat");

async function main() {
  //STAKING CONTRACT
  const tokenStaking = await hre.ethers.deployContract("TokenStaking");
  await tokenStaking.waitForDeployment();
  //TOKEN CONTRACT
  const springTokens = await hre.ethers.deployContract("SpringTokens");
  await springTokens.waitForDeployment();
  //CONTRACT ADDRESS
  console.log(tokenStaking.target);
  console.log(springTokens.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
