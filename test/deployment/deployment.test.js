const { expectRevert } = require('@openzeppelin/test-helpers')
const CMTAT_STANDALONE = artifacts.require('CMTAT_STANDALONE')
const CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const { ZERO_ADDRESS } = require('../utils')
contract(
  'CMTAT - Deployment',
  function ([_], admin) {
    it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert.unspecified(deployProxy(CMTAT_PROXY, [ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      }))
    })
    it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert.unspecified(CMTAT_STANDALONE.new(_, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: admin }))
    })
  }
)
