const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()

const {
  deployProxy,
  upgradeProxy,
  erc1967
} = require('@openzeppelin/truffle-upgrades')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG } = require('../../deploymentUtils')
const { ethers, upgrades } = require('hardhat')
contract(
  'Proxy - Security Test',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
      // Contract to deploy: CMTAT
      this.CMTAT_PROXY = await deployCMTATProxy(_, admin, deployerAddress)
      const implementationContractAddress =
        await upgrades.erc1967.getImplementationAddress(
          this.CMTAT_PROXY.address,
          { from: admin }
        )
      this.implementationContract = await CMTAT.at(
        implementationContractAddress
      )
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeTakenControlByAttacker1', async function () {
        await expectRevertCustomError(
          this.implementationContract.initialize(
            attacker,
            'CMTA Token',
            'CMTAT',
            DECIMAL,
            'CMTAT_ISIN',
            'https://cmta.ch',
            ZERO_ADDRESS,
            'CMTAT_info',
            DEPLOYMENT_FLAG,
            { from: attacker }
          ),
          'AlreadyInitialized',
          []
        )
        await expectRevertCustomError(
          this.implementationContract.kill({ from: attacker }),
          'AccessControlUnauthorizedAccount',
          [attacker, DEFAULT_ADMIN_ROLE]
        )
      })
      // Here the argument to indicate if it is deployed with a proxy, set at true by the attacker
      it('testCannotBeTakenControlByAttacker2', async function () {
        await expectRevertCustomError(
          this.implementationContract.initialize(
            attacker,
            'CMTA Token',
            'CMTAT',
            DECIMAL,
            'CMTAT_ISIN',
            'https://cmta.ch',
            ZERO_ADDRESS,
            'CMTAT_info',
            DEPLOYMENT_FLAG,
            { from: attacker }
          ),
          'AlreadyInitialized',
          []
        )
        await expectRevertCustomError(
          this.implementationContract.kill({ from: attacker }),
          'AccessControlUnauthorizedAccount',
          [attacker, DEFAULT_ADMIN_ROLE]
        )
      })
    })
    context('Admin', function () {
      it('testCannotKillTheImplementationContractByAdmin', async function () {
        await expectRevertCustomError(
          this.implementationContract.kill({ from: admin }),
          'AccessControlUnauthorizedAccount',
          [admin, DEFAULT_ADMIN_ROLE]
        );
        (await this.implementationContract.terms()).should.equal('')
      })
    })
  }
)
