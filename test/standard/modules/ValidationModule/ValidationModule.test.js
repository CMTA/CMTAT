const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const {deployCMTATStandalone} = require('../../../deploymentUtils')
const ADDRESS1_INITIAL_BALANCE = 31
const ADDRESS2_INITIAL_BALANCE = 32
const ADDRESS3_INITIAL_BALANCE = 33
contract(
  'Standard - ValidationModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_BALANCE, { from: admin })
    })
    ValidationModuleCommon(admin, address1, address2, address3, ADDRESS1_INITIAL_BALANCE, ADDRESS2_INITIAL_BALANCE, ADDRESS3_INITIAL_BALANCE)
  }
)
