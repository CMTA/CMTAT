const CMTAT_BEACON_FACTORY = artifacts.require('CMTAT_BEACON_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE, CMTAT_DEPLOYER_ROLE } = require('../../utils.js')
const { ZERO_ADDRESS } = require('../../utils.js')
const {
  DEPLOYMENT_FLAG,
  deployCMTATProxyImplementation
} = require('../../deploymentUtils.js')
const { upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
const { BN, expectEvent } = require('@openzeppelin/test-helpers')
contract(
  'Deploy Beacon with Factory',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        _,
        deployerAddress
      )
    })

    context('BeaconDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expectRevertCustomError(
          CMTAT_BEACON_FACTORY.new(ZERO_ADDRESS, admin, admin, { from: admin }),
          'CMTAT_Factory_AddressZeroNotAllowedForLogicContract',
          []
        )
      })
      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expectRevertCustomError(
          CMTAT_BEACON_FACTORY.new(
            this.CMTAT_PROXY_IMPL.address,
            ZERO_ADDRESS,
            admin,
            { from: admin }
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin',
          []
        )
      })
      it('testCannotDeployIfBeaconOwnerIsZero', async function () {
        await expectRevertCustomError(
          CMTAT_BEACON_FACTORY.new(
            this.CMTAT_PROXY_IMPL.address,
            admin,
            ZERO_ADDRESS,
            { from: admin }
          ),
          'CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner',
          []
        )
      })
    })
  }
)
