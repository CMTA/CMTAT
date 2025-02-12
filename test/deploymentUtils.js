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
async function deployCMTATStandalone (_, admin, deployerAddress) {
  const cmtat = await ethers.deployContract('CMTAT_STANDALONE', [
    _,
    admin,
    ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
    ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
    [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
  ])
  return cmtat
}

async function deployCMTATProxyImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await ethers.deployContract('CMTAT_PROXY', [
    forwarderIrrevocable
  ])
  return cmtat
}

async function deployCMTATProxyUUPSImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await ethers.deployContract('CMTAT_PROXY_UUPS', [
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
  const cmtat = await ethers.deployContract('CMTAT_STANDALONE', [
    forwarderIrrevocable,
    admin,
    [nameIrrevocable, symbolIrrevocable, decimalsIrrevocable],
    [tokenId_, terms_, information_],
    engines
  ])
  return cmtat
}

async function deployCMTATProxy (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_PROXY'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
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
    'CMTAT_PROXY'
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
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  DEPLOYMENT_DECIMAL,
  TERMS,
  deployCMTATProxyImplementation,
  deployCMTATProxyUUPSImplementation,
  fixture,
  loadFixture
}
