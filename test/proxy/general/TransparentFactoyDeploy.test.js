const CMTAT_TP_FACTORY = artifacts.require('CMTAT_TP_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const {
  DEFAULT_ADMIN_ROLE,
  PAUSER_ROLE,
  CMTAT_DEPLOYER_ROLE
} = require('../../utils.js')
const { ZERO_ADDRESS } = require('../../utils.js')
const DECIMAL = 0
const {
  deployCMTATProxy,
  DEPLOYMENT_FLAG,
  deployCMTATProxyImplementation
} = require('../../deploymentUtils.js')
const { upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
const { BN, expectEvent } = require('@openzeppelin/test-helpers')
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
