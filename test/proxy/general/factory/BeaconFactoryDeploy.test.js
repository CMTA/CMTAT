const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation,
  fixture, loadFixture 
} = require('../../../deploymentUtils.js')
describe(
  'Deploy Beacon with Factory',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        this._.address,
        this.deployerAddress.address
      )
    })
    context('BeaconDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ZERO_ADDRESS, this.admin.address, this.admin.address]),
          'CMTAT_Factory_AddressZeroNotAllowedForLogicContract',
          []
        )
      })
      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.target,
            ZERO_ADDRESS,
            this.admin.address]
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin',
          []
        )
      })
      it('testCannotDeployIfBeaconOwnerIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.target,
            this.admin.address,
            ZERO_ADDRESS]
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner',
          []
        )
      })
    })
  }
)
