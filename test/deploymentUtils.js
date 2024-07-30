const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { ZERO_ADDRESS } = require('./utils')
const { ethers, upgrades } = require('hardhat')
const DEPLOYMENT_FLAG = 5n
const DEPLOYMENT_DECIMAL = 0n
async function fixture() {
  const [_, admin, address1, address2, address3, deployerAddress, fakeRuleEngine] = await ethers.getSigners()
  return {_, admin, address1, address2, address3, deployerAddress, fakeRuleEngine };
}
async function deployCMTATStandalone (_, admin, deployerAddress) {
  const cmtat = await ethers.deployContract("CMTAT_STANDALONE", [ _,
    admin,
    ZERO_ADDRESS,
    'CMTA Token',
    'CMTAT',
    DEPLOYMENT_DECIMAL,
    'CMTAT_ISIN',
    'https://cmta.ch',
    ZERO_ADDRESS,
    'CMTAT_info',
    DEPLOYMENT_FLAG]);
  return cmtat
}

async function deployCMTATProxyImplementation (
  deployerAddress,
  forwarderIrrevocable
) {
  const cmtat = await ethers.deployContract('CMTAT_PROXY',[forwarderIrrevocable])
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
  const cmtat = await ethers.deployContract('CMTAT_STANDALONE',[
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
  ])
  return cmtat
}

async function deployCMTATStandaloneWithSnapshot (_, admin, deployerAddress) {
  const cmtat = await ethers.deployContract(
    'CMTAT_STANDALONE',[ _,
      admin,
      ZERO_ADDRESS,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      ZERO_ADDRESS,
      'CMTAT_info',
      DEPLOYMENT_FLAG]
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
      admin.address,
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
      constructorArgs: [_.address],
      from: deployerAddress
    }
  )
  /*const TRUFFLE_CMTAT_PROXY_ADDRESS = await CMTAT_PROXY_SNAPSHOT_TRUFFLE.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )*/
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATProxyWithSnapshot (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_PROXY'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin.address,
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
      constructorArgs: [_.address],
      from: deployerAddress.address
    }
  )
  /*const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )*/
  return ETHERS_CMTAT_PROXY
}

async function deployCMTATProxyWithKillTest (_, admin, deployerAddress) {
  // Ref: https://forum.openzeppelin.com/t/upgrades-hardhat-truffle5/30883/3
  const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
    'CMTAT_KILL_TEST'
  )
  const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
    ETHERS_CMTAT_PROXY_FACTORY,
    [
      admin.address,
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
      constructorArgs: [_.address],
      from: deployerAddress
    }
  )
  /*const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_KILL_TEST')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await ETHERS_CMTAT_PROXY.getAddress()
  )*/
  return ETHERS_CMTAT_PROXY
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
      admin.address,
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
      constructorArgs: [forwarderIrrevocable.address],
      from: deployerAddress
    }
  )
  /*const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
  const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
    await 
  )*/
  return ETHERS_CMTAT_PROXY.getAddress()
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
  deployCMTATProxyImplementation,
  fixture,
  loadFixture
}
