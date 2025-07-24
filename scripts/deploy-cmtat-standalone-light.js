/**
 * Script example - do not use it for production
 */

const { ethers } = require("hardhat");

async function main() {
  // Admin address (you can use a test address for local deployment)
  const admin = "0x1000000000000000000000000000000000000001";

  // ERC20 attributes for the light version
  const ERC20Attributes = {
    name: "Light Token",
    symbol: "LTK",
    decimalsIrrevocable: 0 
  };

  // Get contract factory and deploy
  const CMTATLight = await ethers.getContractFactory("CMTATStandaloneLight");
  const lightInstance = await CMTATLight.deploy(admin, ERC20Attributes);

  await lightInstance.waitForDeployment();

  const address = await lightInstance.getAddress();
  console.log("CMTATStandaloneLight deployed to:", address);
}

main().catch((error) => {
  console.error("Deployment failed:", error);
  process.exit(1);
});
