const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const TransferAdminshipCommon = require('../common/TransferAdminshipCommon')

contract(
  'Standard - TransferAdminship',
  function ([_, oldAdmin, newAdmin, attacker]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
        initializer: 'initialize',
        constructorArgs: [_, true, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
      })
    })

    TransferAdminshipCommon(oldAdmin, newAdmin, attacker)
  }
)
