/**
 * We use a different version of the CMTAT where we have removed the check of access control on the kill function
 * The goal is to verify if the modifier onlyDelegateCall works as intended
 *
*/
const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ZERO_ADDRESS } = require('../../utils')
const {
  deployProxy,
  erc1967
} = require('@openzeppelin/truffle-upgrades')

const CMTAT_KILL_TEST = artifacts.require('CMTAT_KILL_TEST')

contract('Proxy - Security Test', function ([_, admin]) {
  beforeEach(async function () {
    this.flag = 5
    this.CMTAT_PROXY = await deployProxy(
      CMTAT_KILL_TEST,
      [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag],
      {
        initializer: 'initialize',
        constructorArgs: [
          _
        ]
      }
    )
    const implementationContractAddress =
      await erc1967.getImplementationAddress(this.CMTAT_PROXY.address, {
        from: admin
      })
    this.implementationContract = await CMTAT_KILL_TEST.at(
      implementationContractAddress
    )
  })
  context('Implementation contract', function () {
    it('testCannotKillTheImplementationContract', async function () {
      await expectRevert(
        this.implementationContract.kill({ from: admin }),
        'Direct call to the implementation not allowed'
      )
    })
  })
})
