const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()

const { deployProxy, upgradeProxy, erc1967 } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG } = require('../../deploymentUtils')

contract(
  'Proxy - Security Test',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
         // Contract to deploy: CMTAT
      this.CMTAT_PROXY = await deployCMTATProxy(_, admin, deployerAddress)
      const implementationContractAddress = await erc1967.getImplementationAddress(this.CMTAT_PROXY.address, { from: admin })
      this.implementationContract = await CMTAT.at(implementationContractAddress)
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeTakenControlByAttacker1', async function () {
        await expectRevert(
          this.implementationContract.initialize(attacker, 'CMTA Token', 'CMTAT', DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', DEPLOYMENT_FLAG, { from: attacker }),
          'Initializable: contract is already initialized'
        )
        await expectRevert(
          this.implementationContract.kill({ from: attacker }),
          'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        )
      })
      // Here the argument to indicate if it is deployed with a proxy, set at true by the attacker
      it('testCannotBeTakenControlByAttacker2', async function () {
        await expectRevert(
          this.implementationContract.initialize(attacker, 'CMTA Token', 'CMTAT', DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', DEPLOYMENT_FLAG, { from: attacker }),
          'Initializable: contract is already initialized'
        )
        await expectRevert(
          this.implementationContract.kill({ from: attacker }),
          'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        )
      })
    })
    context('Admin', function () {
      it('testCannotKillTheImplementationContractByAdmin', async function () {
        await expectRevert(
          this.implementationContract.kill({ from: admin }),
          'AccessControl: account ' +
          admin.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        );
        (await this.implementationContract.terms()).should.equal('')
      })
    })
  })
