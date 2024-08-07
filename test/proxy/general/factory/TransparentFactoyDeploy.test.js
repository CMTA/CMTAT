const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation,
  fixture, loadFixture 
} = require('../../../deploymentUtils.js')
describe(
  'Deploy TP with Factory',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        this._.address,
        this.deployerAddress.address
      )
      // this.FACTORY = await CMTAT_TP_FACTORY.new(this.CMTAT_PROXY_IMPL.address, admin)
    })

    context('FactoryDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract('CMTAT_TP_FACTORY',[
            ZERO_ADDRESS, this.admin
          ]),
          'CMTAT_Factory_AddressZeroNotAllowedForLogicContract',
          []
        )
      })

      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract('CMTAT_TP_FACTORY', [
            this.CMTAT_PROXY_IMPL.target, ZERO_ADDRESS
          ]),
          'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin',
          []
        )
      })
    })
  }
)
