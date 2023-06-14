const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_BASE')
const PauseModuleCommon = require('../../common/PauseModuleCommon')

contract('Proxy - PauseModule', function ([_, admin, address1, address2, address3]) {
  beforeEach(async function () {
    this.flag = 5
    this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag])
    // Mint tokens to test the transfer
    await this.cmtat.mint(address1, 20, {
      from: admin
    })
  })

  PauseModuleCommon(admin, address1, address2, address3)
})
