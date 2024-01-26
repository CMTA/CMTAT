const CMTAT_TP_FACTORY = artifacts.require(
  'CMTAT_TP_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE, PAUSER_ROLE, CMTAT_DEPLOYER_ROLE } = require('../../utils.js')
const { ZERO_ADDRESS } = require('../../utils.js')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG, deployCMTATProxyImplementation,  } = require('../../deploymentUtils.js')
const { upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
const { BN, expectEvent } = require('@openzeppelin/test-helpers')
contract(
  'Proxy - Security Test',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(_, deployerAddress)
      this.FACTORY = await CMTAT_TP_FACTORY.new(this.CMTAT_PROXY_IMPL.address, admin)
    })

    context('FactoryDeployment', function () {
      it('testCanReturnTheRightImplementation', async function () {
         // Act + Assert
        (await this.FACTORY.logic()).should.equal(this.CMTAT_PROXY_IMPL.address)
      })
    })

    context('Deploy CMTAT with Factory', function () {
      it('testCannotBeDeployedByAttacker', async function () {
        // Act
        await expectRevertCustomError(
          this.FACTORY.deployCMTAT(
            admin,
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
        )})
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCanDeployCMTATWithFactory', async function () {
        // Act
        this.logs = await this.FACTORY.deployCMTAT(
          admin,
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
        // Assert
        // Check  Id
        (this.logs.logs[1].args[1]).should.be.bignumber.equal(BN(0))
        const CMTAT_ADDRESS = this.logs.logs[1].args[0];
        //Check address with ID
        (await this.FACTORY.getAddress(0)).should.equal(CMTAT_ADDRESS)
        const CMTAT_TRUFFLE = await CMTAT.at(CMTAT_ADDRESS)
        await CMTAT_TRUFFLE.mint(admin, 100, {
          from: admin
        })
        // Second deployment
        this.logs = await this.FACTORY.deployCMTAT(
          admin,
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
