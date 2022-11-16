const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
contract('Proxy - PauseModule', function ([_, owner, address1, address2, address3]) {
  beforeEach(async function () {
    this.cmtat = await deployProxy(CMTAT, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [_] })
    // Mint tokens to test the transfer
    await this.cmtat.mint(address1, 20, {
      from: owner
    })
  })

  PauseModuleCommon(owner, address1, address2, address3)
})
