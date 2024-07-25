const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { ZERO_ADDRESS, CMTAT_DEPLOYER_ROLE } = require('../../../utils.js')
const {
  DEPLOYMENT_FLAG,
  deployCMTATProxyImplementation
} = require('../../../deploymentUtils.js')
const { ethers } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
const { BN } = require('@openzeppelin/test-helpers')
describe(
  'Deploy TP with Factory',
  function () {
    beforeEach(async function () {
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        _,
        deployerAddress
      )
      this.FACTORY =  await ethers.deployContract('CMTAT_TP_FACTORY',[
        this.CMTAT_PROXY_IMPL.address,
        admin,
        true
      ])
      this.CMTATArg = [
        admin,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        DEPLOYMENT_FLAG
      ]
    })

    context('FactoryDeployment', function () {
      it('testCanReturnTheRightImplementation', async function () {
        // Act + Assert
        (await this.FACTORY.logic()).should.equal(
          this.CMTAT_PROXY_IMPL.address
        )
      })
    })

    context('Deploy CMTAT with Factory', function () {
      it('testCannotBeDeployedByAttacker', async function () {
        // Act
        await expectRevertCustomError(
          this.FACTORY.deployCMTAT(
            ethers.encodeBytes32String('test'),
            admin,
            this.CMTATArg,
            { from: attacker }
          ),
          'AccessControlUnauthorizedAccount',
          [attacker, CMTAT_DEPLOYER_ROLE]
        )
      })
      it('testCanDeployCMTATWithFactory', async function () {
        // Act
        this.logs = await this.FACTORY.deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin,
          this.CMTATArg,
          {
            from: admin
          }
        )
        // Assert
        // Check  Id
        this.logs.logs[1].args[1].should.be.bignumber.equal(BN(0))
        const CMTAT_ADDRESS = this.logs.logs[1].args[0];
        // Check address with ID
        (await this.FACTORY.CMTATProxyAddress(0)).should.equal(CMTAT_ADDRESS)
        const CMTAT_TRUFFLE = await CMTAT.at(CMTAT_ADDRESS)
        await CMTAT_TRUFFLE.mint(admin, 100, {
          from: admin
        })
        // Second deployment
        this.logs = await this.FACTORY.deployCMTAT(
          ethers.encodeBytes32String('test2'),
          admin,
          this.CMTATArg,
          {
            from: admin
          }
        )
        // Check Id increment
        this.logs.logs[1].args[1].should.be.bignumber.equal(BN(1))
        // Revert
        await expectRevertCustomError(this.FACTORY.deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin,
          this.CMTATArg,
          {
            from: admin
          }
        ),
        'CMTAT_Factory_SaltAlreadyUsed',
        [])
      })
      it('testCannotDeployCMTATWithFactoryWithSaltAlreadyUsed', async function () {
        // Arrange
        await this.FACTORY.deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin,
          this.CMTATArg,
          {
            from: admin
          }
        )
       
        // Act with Revert
        await expectRevertCustomError(this.FACTORY.deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin,
          this.CMTATArg,
          {
            from: admin
          }
        ),
        'CMTAT_Factory_SaltAlreadyUsed',
        [])
      })
    })
  }
)
