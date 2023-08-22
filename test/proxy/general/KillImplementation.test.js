/**
 * We use a different version of the CMTAT where we have removed the check of access control on the kill function
 * The goal is to verify if the modifier onlyDelegateCall works as intended
 *
*/
const { expectRevert } = require('@openzeppelin/test-helpers')
const {deployCMTATProxyWithKillTest} = require('../../deploymentUtils')
const { should } = require('chai').should()
const {
  deployProxy,
  erc1967
} = require('@openzeppelin/truffle-upgrades')
const { ethers, upgrades } = require("hardhat");
const CMTAT_KILL_TEST = artifacts.require('CMTAT_KILL_TEST')

contract('Proxy - Security Test', function ([_, admin, deployerAddress]) {
  beforeEach(async function () {
    this.flag = 5
    // Contract to deploy: CMTAT_KILL_TEST
    this.CMTAT_PROXY = await deployCMTATProxyWithKillTest(_, admin, deployerAddress)
    const implementationContractAddress =
      await upgrades.erc1967.getImplementationAddress(this.CMTAT_PROXY.address, {
        from: admin
      })
    this.implementationContract = await CMTAT_KILL_TEST.at(
      implementationContractAddress
    )
  })
  context('Implementation contract', function () {
    it('testCannotKillTheImplementationContract', async function () {
      await expectRevert.unspecified(
        this.implementationContract.kill({ from: admin })
      )
    })
  })
})
