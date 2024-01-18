const CMTAT_BEACON_FACTORY = artifacts.require(
  'CMTAT_BEACON_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE, CMTAT_DEPLOYER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const { DEPLOYMENT_FLAG, deployCMTATProxyImplementation } = require('../../deploymentUtils')
const { upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
const { BN, expectEvent } = require('@openzeppelin/test-helpers')
contract(
  'Proxy - Security Test',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.CMTAT_PROXY = await deployCMTATProxyImplementation(_, deployerAddress)
      this.FACTORY = await CMTAT_BEACON_FACTORY.new(this.CMTAT_PROXY.address, admin, admin)
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeDeployedByAttacker', async function () {
      // Act
        await expectRevertCustomError(
          this.FACTORY.deployCMTAT(
            admin,
            ZERO_ADDRESS,
            'CMTA Token',
            'CMTAT',
            DEPLOYMENT_DECIMAL,
            'CMTAT_ISIN',
            'https://cmta.ch',
            ZERO_ADDRESS,
            'CMTAT_info',
            DEPLOYMENT_FLAG, { from: attacker }),
          'AccessControlUnauthorizedAccount',
          [attacker, CMTAT_DEPLOYER_ROLE]
        )
      })
    })

    context('Deploy CMTAT with Factory', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCanDeployCMTATWithFactory', async function () {
        // Act
        this.logs = await this.FACTORY.deployCMTAT(
          admin,
          ZERO_ADDRESS,
          'CMTA Token',
          'CMTAT',
          DEPLOYMENT_DECIMAL,
          'CMTAT_ISIN',
          'https://cmta.ch',
          ZERO_ADDRESS,
          'CMTAT_info',
          DEPLOYMENT_FLAG, {
            from: admin
          });
        // Check Id increment
        (this.logs.logs[1].args[1]).should.be.bignumber.equal(BN(0))
        // Assert
        const CMTAT_ADDRESS = this.logs.logs[1].args[0]
        const CMTAT_TRUFFLE = await CMTAT.at(CMTAT_ADDRESS)
        // Act + Assert
        await CMTAT_TRUFFLE.mint(admin, 100, {
          from: admin
        })
        this.logs = await this.FACTORY.deployCMTAT(
          admin,
          ZERO_ADDRESS,
          'CMTA Token',
          'CMTAT',
          DEPLOYMENT_DECIMAL,
          'CMTAT_ISIN',
          'https://cmta.ch',
          ZERO_ADDRESS,
          'CMTAT_info',
          DEPLOYMENT_FLAG, {
            from: admin
          });
        // Check Id increment
        (this.logs.logs[1].args[1]).should.be.bignumber.equal(BN(1))
      })
    })
  }
)