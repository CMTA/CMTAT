const CMTAT_TP_FACTORY = artifacts.require('CMTAT_TP_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation
} = require('../../../deploymentUtils.js')
contract(
  'Deploy TP with Factory',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        _,
        deployerAddress
      )
      // this.FACTORY = await CMTAT_TP_FACTORY.new(this.CMTAT_PROXY_IMPL.address, admin)
    })

    context('FactoryDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expectRevertCustomError(
          CMTAT_TP_FACTORY.new(ZERO_ADDRESS, admin, { from: admin }),
          'CMTAT_Factory_AddressZeroNotAllowedForLogicContract',
          []
        )
      })

      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expectRevertCustomError(
          CMTAT_TP_FACTORY.new(this.CMTAT_PROXY_IMPL.address, ZERO_ADDRESS, {
            from: admin
          }),
          'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin',
          []
        )
      })
    })
  }
)
