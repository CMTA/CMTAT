const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const PauseModuleCommon = require('../../common/PauseModuleCommon')

contract('Proxy - PauseModule', function ([_, admin, address1, address2, address3]) {
  beforeEach(async function () {
    this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
      initializer: 'initialize',
      constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
    })
    // Mint tokens to test the transfer
    await this.cmtat.mint(address1, 20, {
      from: admin
    })
  })

  PauseModuleCommon(admin, address1, address2, address3)
})
