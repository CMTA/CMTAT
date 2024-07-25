const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../../deploymentUtils')
describe(
  'Standard - ValidationModule',
  function () {
    //[_, admin, address1, address2, address3, deployerAddress] =  ethers.getSigners();
    beforeEach(async function () {
      this.ADDRESS1_INITIAL_BALANCE = 31n
      this.ADDRESS2_INITIAL_BALANCE = 32n
      this.ADDRESS3_INITIAL_BALANCE = 33n
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._, this.admin, this.deployerAddress)
      await this.cmtat.connect(this.admin).mint(this.address1, this.ADDRESS1_INITIAL_BALANCE)
      await this.cmtat.connect(this.admin).mint(this.address2, this.ADDRESS2_INITIAL_BALANCE)
      await this.cmtat.connect(this.admin).mint(this.address3, this.ADDRESS3_INITIAL_BALANCE)
    })
    ValidationModuleCommon()
  }
)
