const { ethers } = require('hardhat')

async function main () {
  // Deploy ExampleRuleEngineERC165
  const RuleEngineFactory = await ethers.getContractFactory('ExampleRuleEngineERC165')
  const ruleEngine = await RuleEngineFactory.deploy()
  await ruleEngine.waitForDeployment()
  const ruleEngineInterfaceId = await ruleEngine.getInterfaceId()
  console.log('IRuleEngine interfaceId:', ruleEngineInterfaceId)

  // Deploy ExampleERC1404ExtendERC165
  const ERC1404Factory = await ethers.getContractFactory('ExampleERC1404ExtendERC165')
  const erc1404 = await ERC1404Factory.deploy()
  await erc1404.waitForDeployment()
  const erc1404InterfaceId = await erc1404.getInterfaceId()
  console.log('IERC1404Extend interfaceId:', erc1404InterfaceId)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
