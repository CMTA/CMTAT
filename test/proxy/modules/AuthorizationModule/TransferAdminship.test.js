const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const TransferAdminshipCommon = require('../../../common/AuthorizationModule/TransferAdminshipCommon')
const { ZERO_ADDRESS } = require('../../../utils')

contract(
  'Proxy - TransferAdminship',
  function ([_, oldAdmin, newAdmin, attacker]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [true, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_, true, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag]
      })
    })

    TransferAdminshipCommon(oldAdmin, newAdmin, attacker)
  }
)
