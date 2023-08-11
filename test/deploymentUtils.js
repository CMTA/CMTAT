const { ZERO_ADDRESS } = require('./utils')
const CMTAT_STANDALONE = artifacts.require('CMTAT_STANDALONE')
const CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const { ethers, upgrades } = require("hardhat");
//const { ethers, upgrades } = require('@nomicfoundation/hardhat-ethers');
const DEPLOYMENT_FLAG = 5
const DEPLOYMENT_DECIMAL = 0




async function deployCMTATStandalone (_, admin, deployerAddress) {
  const cmtat = await CMTAT_STANDALONE.new(_, admin, 'CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', DEPLOYMENT_FLAG, { from: deployerAddress })
  return cmtat
}

async function deployCMTATProxy (_, admin, deployerAddress) {

  /*const cmtat = await deployProxy(CMTAT_PROXY, [admin, 'CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', DEPLOYMENT_FLAG], {
    initializer: 'initialize',
    constructorArgs: [_],
    from: deployerAddress
  })*/
  const Contract2Ethers = await ethers.getContractFactory('CMTAT_PROXY');
  const contract2ethers = await upgrades.deployProxy(Contract2Ethers, [admin, 'CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', DEPLOYMENT_FLAG], {
    initializer: 'initialize',
    constructorArgs: [_],
    from: deployerAddress
  });
  const Contract2Truffle = artifacts.require('CMTAT_PROXY')
  const contract2truffle = await Contract2Truffle.at(await contract2ethers.getAddress());
  return contract2truffle
}

module.exports = { deployCMTATStandalone, deployCMTATProxy, DEPLOYMENT_FLAG, DEPLOYMENT_DECIMAL }
