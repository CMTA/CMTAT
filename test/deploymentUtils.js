const { ZERO_ADDRESS } = require('./utils')
const CMTAT_STANDALONE = artifacts.require('CMTAT_STANDALONE')
const CMTAT_STANDALONE_SNAPSHOT = artifacts.require('CMTAT_STANDALONE')
const CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
// const CMTAT_PROXY_SNAPSHOT_TRUFFLE = artifacts.require('CMTATSnapshotProxyTest')
const CMTAT_PROXY_SNAPSHOT_TRUFFLE = artifacts.require('CMTAT_PROXY')
const { ethers, upgrades } = require('hardhat')
const DEPLOYMENT_FLAG = 5
const DEPLOYMENT_DECIMAL = 0

async function deployCMTATStandalone (_, admin, deployerAddress) {
  const cmtat = await CMTAT_STANDALONE.new(
    _,
    admin,
    ZERO_ADDRESS,
    'CMTA Token',
    'CMTAT',
    DEPLOYMENT_DECIMAL,
    'CMTAT_ISIN',
    'https://cmta.ch',
    ZERO_ADDRESS,
    'CMTAT_info',
    DEPLOYMENT_FLAG,
    { from: deployerAddress }
  )
  return cmtat
}

async function deployCMTATProxyImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await CMTAT_PROXY.new(forwarderIrrevocable, {
    from: deployerAddress
  })
  return cmtat
}

async function deployCMTATStandaloneWithParameter (
  deployerAddress,
  forwarderIrrevocable,
  admin,
  authorizationEngine,
  nameIrrevocable,
  symbolIrrevocable,
  decimalsIrrevocable,
  tokenId_,
  terms_,
  ruleEngine_,
  information_,
  flag_
) {
  const cmtat = await CMTAT_STANDALONE.new(
    forwarderIrrevocable,
    admin,
    authorizationEngine,
    nameIrrevocable,
    symbolIrrevocable,
    decimalsIrrevocable,
    tokenId_,
    terms_,
    ruleEngine_,
    information_,
    flag_,
    { from: deployerAddress }
  )
  return cmtat
}

async function deployCMTATStandaloneWithSnapshot (_, admin, deployerAddress) {
  const cmtat = await CMTAT_STANDALONE_SNAPSHOT.new(
    _,
    admin,
    ZERO_ADDRESS,
    'CMTA Token',
    'CMTAT',
    DEPLOYMENT_DECIMAL,
    'CMTAT_ISIN',
    'https://cmta.ch',
    ZERO_ADDRESS,
    'CMTAT_info',
    DEPLOYMENT_FLAG,
    { from: deployerAddress }
  )
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
      ZERO_ADDRESS,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      ZERO_ADDRESS,
      'CMTAT_info',
      DEPLOYMENT_FLAG
    ],
    {
      initializer: 'initialize',
      constructorArgs: [_],
      from: deployerAddress
    }
  )
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await CMTAT_PROXY_SNAPSHOT_TRUFFLE.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )
  return TRUFFLE_CMTAT_PROXY_ADDRESS
}

async function deployCMTATProxyWithSnapshot (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_PROXY'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ZERO_ADDRESS,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      ZERO_ADDRESS,
      'CMTAT_info',
      DEPLOYMENT_FLAG
    ],
    {
      initializer: 'initialize',
      constructorArgs: [_],
      from: deployerAddress
    }
  )
  const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )
  return TRUFFLE_CMTAT_PROXY_ADDRESS
}

async function deployCMTATProxyWithKillTest (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_KILL_TEST'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      ZERO_ADDRESS,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      ZERO_ADDRESS,
      'CMTAT_info',
      DEPLOYMENT_FLAG
    ],
    {
      initializer: 'initialize',
      constructorArgs: [_],
      from: deployerAddress
    }
  )
  const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_KILL_TEST')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )
  return TRUFFLE_CMTAT_PROXY_ADDRESS
}

async function deployCMTATProxyWithParameter (
  deployerAddress,
  forwarderIrrevocable,
  admin,
  authorizationEngine,
  nameIrrevocable,
  symbolIrrevocable,
  decimalsIrrevocable,
  tokenId_,
  terms_,
  ruleEngine_,
  information_,
  flag_
) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_PROXY'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin,
      authorizationEngine,
      nameIrrevocable,
      symbolIrrevocable,
      decimalsIrrevocable,
      tokenId_,
      terms_,
      ruleEngine_,
      information_,
      flag_
    ],
    {
      initializer: 'initialize',
      constructorArgs: [forwarderIrrevocable],
      from: deployerAddress
    }
  )
  const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )
  return TRUFFLE_CMTAT_PROXY_ADDRESS
}

module.exports = {
  deployCMTATStandalone,
  deployCMTATStandaloneWithSnapshot,
  deployCMTATProxy,
  deployCMTATProxyWithSnapshot,
  deployCMTATProxyWithKillTest,
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  DEPLOYMENT_FLAG,
  DEPLOYMENT_DECIMAL,
  deployCMTATProxyImplementation
}
