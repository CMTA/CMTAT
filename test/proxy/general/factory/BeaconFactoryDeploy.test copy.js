const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation
} = require('../../../deploymentUtils.js')
describe(
  'Deploy Beacon with Factory',
  function () {
    beforeEach(async function () {
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        _,
        deployerAddress
      )
    })
    context('BeaconDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ZERO_ADDRESS, admin, admin]),
          'CMTAT_Factory_AddressZeroNotAllowedForLogicContract',
          []
        )
      })
      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.address,
            ZERO_ADDRESS,
            admin]
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin',
          []
        )
      })
      it('testCannotDeployIfBeaconOwnerIsZero', async function () {
        await expectRevertCustomError(
          ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.address,
            admin,
            ZERO_ADDRESS]
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner',
          []
        )
      })
    })
  }
)
