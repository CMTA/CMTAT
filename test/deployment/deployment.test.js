const { expectRevert } = require('@openzeppelin/test-helpers')
const CMTAT_BASE = artifacts.require('CMTAT_BASE')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const { ZERO_ADDRESS } = require('../utils')
contract(
  'CMTAT - Deployment',
  function () {
    it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert.unspecified(deployProxy(CMTAT_BASE, [ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag]))
    })
  }
)
