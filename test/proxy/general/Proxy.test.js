const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE, PAUSER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG } = require('../../deploymentUtils')
const { upgrades } = require('hardhat')
contract(
  'Proxy - Security Test',
  function () {
    beforeEach(async function () {
      this.flag = 5
      // Contract to deploy: CMTAT
      this.CMTAT_PROXY = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
      const implementationContractAddress =
        await upgrades.erc1967.getImplementationAddress(
          this.CMTAT_PROXY.address
        )
      this.implementationContract = await CMTAT.at(
        implementationContractAddress
      )
    })

    context('Attacker', function () {
      it('testCannotBeTakenControlByAttacker', async function () {
        // Act
        await expectRevertCustomError(
          this.implementationContract.connect(this.attacker).initialize(
            attacker,
            ZERO_ADDRESS,
            'CMTA Token',
            'CMTAT',
            DECIMAL,
            'CMTAT_ISIN',
            'https://cmta.ch',
            ZERO_ADDRESS,
            'CMTAT_info',
            DEPLOYMENT_FLAG
          ),
          'InvalidInitialization',
          []
        )
        // act + assert
        await expectRevertCustomError(
          this.implementationContract.connect(this.attacker).pause(),
          'AccessControlUnauthorizedAccount',
          [attacker, PAUSER_ROLE]
        )
      })
    })
  }
)
