const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract('Proxy - PauseModule', function ([_, admin, address1, address2, address3]) {
  beforeEach(async function () {
    this.flag = 5
    this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
      initializer: 'initialize',
      constructorArgs: [_]
    })
    // Mint tokens to test the transfer
    await this.cmtat.mint(address1, 20, {
      from: admin
    })
  })

  PauseModuleCommon(admin, address1, address2, address3)
})
