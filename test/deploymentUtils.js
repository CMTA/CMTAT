const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { ZERO_ADDRESS } = require('./utils')
const { ethers, upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0n
// hash = keccak256("doc1Hash");
const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
async function fixture () {
  const [
    _,
    admin,
    address1,
    address2,
    address3,
    deployerAddress,
    fakeRuleEngine,
    ruleEngine,
    attacker
  ] = await ethers.getSigners()
  return {
    _,
    admin,
    address1,
    address2,
    address3,
    deployerAddress,
    fakeRuleEngine,
    ruleEngine,
    attacker
  }
}
async function deployCMTATStandalone (forwarder, admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTATStandalone', [
    forwarder,
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
  ])
  return cmtat
}

async function deployCMTATERC7551Standalone (forwarder, admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTATStandaloneERC7551', [
    forwarder,
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
  ])
  return cmtat
}

async function deployCMTATDebtStandalone (_, admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTATStandaloneDebt', [
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
  ])
  return cmtat
}

async function deployCMTATERC1363Standalone (forwarder, admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTATStandaloneERC1363', [
    forwarder,
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
  ])
  return cmtat
}

async function deployCMTATLightStandalone (admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTATStandaloneLight', [
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL]
  ])
  return cmtat
}

async function deployCMTATAllowlistStandalone (
  forwarder,
  admin,
  deployerAddress
) {
  const cmtat = await ethers.deployContract('CMTATStandaloneAllowlist', [
    forwarder,
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    ZERO_ADDRESS,
    ZERO_ADDRESS
  ])
  return cmtat
}

async function deployCMTATProxyImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await ethers.deployContract('CMTATUpgradeable', [
    forwarderIrrevocable
  ])
  return cmtat
}

async function deployCMTATProxyUUPSImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await ethers.deployContract('CMTATUpgradeableUUPS', [
    forwarderIrrevocable
  ])
  return cmtat
}

async function deployCMTATStandaloneWithParameter (
  deployerAddress,
  forwarderIrrevocable,
  admin,
  nameIrrevocable,
  symbolIrrevocable,
  decimalsIrrevocable,
  tokenId_,
  terms_,
  information_,
  engines
) {
  const cmtat = await ethers.deployContract('CMTATStandalone', [
    forwarderIrrevocable,
    admin,
    [nameIrrevocable, symbolIrrevocable, decimalsIrrevocable],
    [tokenId_, terms_, information_],
    engines
  ])
  return cmtat
}

async function deployCMTATERC1363Proxy (forwarder, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableERC1363'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarder],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATAllowlistProxy (forwarder, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableAllowlist'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      ZERO_ADDRESS,
      ZERO_ADDRESS
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarder],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATLightProxy (admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableLight'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [admin, ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL]],
    {
      initializer: 'initialize',
      constructorArgs: [],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATERC7551Proxy (forwarder, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableERC7551'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarder],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATProxy (forwarder, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeable'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarder],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATDebtProxy (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableDebt'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ],
    {
      initializer: 'initialize',
      constructorArgs: [],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATUUPSProxy (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeableUUPS'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ],
    {
      initializer: 'initialize',
      constructorArgs: [_],
      from: deployerAddress
    }
  )
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATProxyWithParameter (
  deployerAddress,
  forwarderIrrevocable,
  admin,
  nameIrrevocable,
  symbolIrrevocable,
  decimalsIrrevocable,
  tokenId_,
  terms_,
  information_,
  engines
) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTATUpgradeable'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      [nameIrrevocable, symbolIrrevocable, decimalsIrrevocable],
      [tokenId_, terms_, information_],
      engines
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarderIrrevocable],
      from: deployerAddress
    }
  )
  // return ETHERS_CMTAT_PROXY.getAddress()
  return ETHERS_CMTAT_PROXY
}

module.exports = {
  deployCMTATStandalone,
  deployCMTATProxy,
  deployCMTATLightStandalone,
  deployCMTATLightProxy,
  deployCMTATAllowlistStandalone,
  deployCMTATAllowlistProxy,
  deployCMTATDebtStandalone,
  deployCMTATDebtProxy,
  deployCMTATERC1363Proxy,
  deployCMTATERC1363Standalone,
  deployCMTATERC7551Proxy,
  deployCMTATERC7551Standalone,
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  DEPLOYMENT_DECIMAL,
  TERMS,
  deployCMTATUUPSProxy,
  deployCMTATProxyImplementation,
  deployCMTATProxyUUPSImplementation,
  fixture,
  loadFixture
}
