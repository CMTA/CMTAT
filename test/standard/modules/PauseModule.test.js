const CMTAT = artifacts.require('CMTAT')
const PauseModuleCommon = require('../../common/PauseModuleCommon')

contract(
  'Standard - PauseModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
      // Mint tokens to test the transfer
      await this.cmtat.mint(address1, 20, {
        from: admin
      })
    })

    PauseModuleCommon(admin, address1, address2, address3)
  }
)
