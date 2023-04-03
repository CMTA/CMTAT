const { expectRevert } = require('@openzeppelin/test-helpers')
const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const { ZERO_ADDRESS } = require('../utils')
contract(
  'CMTAT - Deployment',
  function ([_], admin) {
    it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert(deployProxy(CMTAT, [true, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_, true, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag]
      }), 'Address 0 not allowed')
    })
    it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
      this.flag = 5

      // Act + Assert
      await expectRevert(CMTAT.new(_, false, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: admin }), 'Address 0 not allowed')
    })
  }
)
