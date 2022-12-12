const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()

const { deployProxy, upgradeProxy, erc1967 } = require('@openzeppelin/truffle-upgrades')
const CMTAT1 = artifacts.require('CMTAT')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const CMTAT = artifacts.require('CMTAT')
contract(
  'Proxy - Security Test',
  function ([_, admin, attacker]) {
    beforeEach(async function () {
      this.CMTAT_PROXY = await deployProxy(CMTAT1, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'] })
      const implementationContractAddress = await erc1967.getImplementationAddress(this.CMTAT_PROXY.address, { from: admin })
      this.implementationContract = await CMTAT.at(implementationContractAddress)
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeTakenControlByAttacker1', async function () {
        await expectRevert(
          this.implementationContract.initialize(false, attacker, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: attacker }),
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
          this.implementationContract.initialize(true, attacker, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: attacker }),
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
