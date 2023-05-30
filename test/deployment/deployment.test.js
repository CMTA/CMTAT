const { expectRevert } = require('@openzeppelin/test-helpers')
const CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const { ZERO_ADDRESS } = require('../utils')
contract(
  'CMTAT - Deployment',
  function () {
    it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert.unspecified(deployProxy(CMTAT_PROXY, [ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag]))
    })
  }
)
